import Foundation

typealias LinkedInAuthSuccessCallback = (token: LinkedInAccessToken?) -> ()
typealias LinkedInAuthFailureCallback = (error: NSError?) -> ()
typealias LinkedInRequestSuccessCallback = (response: LinkedInSDKResponse?) -> ()
typealias LinkedInRequestFailureCallback = (error: LISDKAPIError?) -> ()

class LinkedInKit: NSObject {
    
    private let configuration: LinkedInConfiguration
    private let httpClient: LinkedInHTTPClient
    
    var accessToken: LinkedInAccessToken?
    var hasValidAccessToken: Bool {
        return accessToken != nil && accessToken?.expireDate > NSDate()
    }
    
    init(configuration: LinkedInConfiguration, httpClient: LinkedInHTTPClient) {
        self.configuration = configuration
        self.httpClient = httpClient
        super.init()
    }
    
    // MARK: Authentication
    func authenticate(success: LinkedInAuthSuccessCallback?,
                      failure: LinkedInAuthFailureCallback?) {
        
        // Check if previous token is still in memory and is valid
        if let accessToken = accessToken where accessToken.expireDate > NSDate() {
            success?(token: accessToken)
        } else {
            
            // Use LinkedInSDK if app is installed
            if LinkedInKit.isLinkedInAppInstalled {
                
                let session = LISDKSessionManager.sharedInstance().session
                accessToken = LinkedInKit.tokenFromSDKSession(session)
                
                if session.isValid() && hasValidAccessToken {
                    success?(token: accessToken)
                }  else {
                    //Authorize through SDK
                    LISDKSessionManager.createSessionWithAuth(configuration.permissions,
                                                              state: configuration.state,
                                                              showGoToAppStoreDialog: false,
                                                              successBlock:
                        { [weak self] (response) in
                            self?.accessToken = LinkedInKit.tokenFromSDKSession(LISDKSessionManager.sharedInstance().session)
                            success?(token: self?.accessToken)
                        }, errorBlock: { (error) in
                            failure?(error: error)
                    })
                }
            } else {
                httpClient.getAuthorizationCode(withSuccessCalback: { [weak self] (code) in
                    self?.httpClient.getAccessToken(forAuthorizationCode: code, success: { [weak self] (token) in
                        self?.accessToken = token
                        success?(token: self?.accessToken)
                        }, failure: { (error) in
                            failure?(error: error)
                    })
                    }, cancelCallback: {
                        //TODO: Send appropirate error
                    }, failureCallback: { (error) in
                        failure?(error: error)
                })
            }
        }
    }
    
    private static func tokenFromSDKSession(session: LISDKSession) -> LinkedInAccessToken {
        let session = LISDKSessionManager.sharedInstance().session
        return LinkedInAccessToken(withAccessToken: session.accessToken.accessTokenValue,
                                   expireDate: session.accessToken.expiration,
                                   isSDK: true)
    }
    
    //MARK: - Requests 
    func requestUrl(url: NSURL, success: LinkedInRequestSuccessCallback?, failure: LinkedInRequestFailureCallback?) {
        
        // **NOTE** Only GET request 
        
        if hasValidAccessToken {
            if LinkedInKit.isLinkedInAppInstalled {
                LISDKAPIHelper.sharedInstance().getRequest("",
                                                           success:
                    { (response) in
                        
                        if let dataFromString = response.data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            success?(response: LinkedInSDKResponse(withData: dataFromString, statusCode: Int(response.statusCode)))
                        } else {
                            success?(response: nil)
                        }
                        
                    }, error: { (error) in
                        failure?(error: error)
                })
            }
        }
    }
}

//MARK: - Static methods
extension LinkedInKit {
    
    static var isLinkedInAppInstalled: Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "linkedin://")!)
    }
    
    static func shouldHandleUrl(url: NSURL) -> Bool {
        return isLinkedInAppInstalled && LISDKCallbackHandler.shouldHandleUrl(url)
    }
    
    static func application(application: UIApplication,
                            openURL url: NSURL,
                            sourceApplication: String,
                            annotation: AnyObject) -> Bool {
        
        return isLinkedInAppInstalled && LISDKCallbackHandler.application(application,
                                                                            openURL: url,
                                                                            sourceApplication: sourceApplication,
                                                                            annotation: annotation)
    }
}