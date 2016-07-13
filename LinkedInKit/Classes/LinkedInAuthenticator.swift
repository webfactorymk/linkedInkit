import Foundation

public typealias LinkedInAuthSuccessCallback = (token: LinkedInAccessToken?) -> ()
public typealias LinkedInAuthFailureCallback = (error: NSError?) -> ()
public typealias LinkedInRequestSuccessCallback = (response: LinkedInSDKResponse?) -> ()
public typealias LinkedInRequestFailureCallback = (error: LISDKAPIError?) -> ()

class LinkedInAuthenticator: NSObject {
    
    static let sharedInstance = LinkedInAuthenticator()
    
    var httpClient: LinkedInHTTPClient?
    
    private let linkedInKeychainKey = "wf.linkedInKit.accessTokenKey"
    private var storedToken: LinkedInAccessToken?
    
    var accessToken: LinkedInAccessToken? {
        set {
            storedToken = newValue
            if let token = newValue {
                KeychainWrapper.setObject(token, forKey: linkedInKeychainKey)
            } else {
                KeychainWrapper.removeObjectForKey(linkedInKeychainKey)
            }
        }
        get {
            return storedToken ?? KeychainWrapper.objectForKey(linkedInKeychainKey) as? LinkedInAccessToken
        }
    }
    
    var hasValidAccessToken: Bool {
        var isConsistent = true
        if let accessToken = accessToken where accessToken.isSDK == true {
            isConsistent = LinkedInKit.isLinkedInAppInstalled
        }
        return accessToken != nil && accessToken?.expireDate > NSDate() && isConsistent
    }
    
    var isAuthorized: Bool {
        if let accessToken = accessToken where accessToken.isSDK == true {
            return hasValidAccessToken && LISDKSessionManager.sharedInstance().session.isValid()
        }
        return hasValidAccessToken
    }
    
    // MARK: Authentication
    func authenticate(success: LinkedInAuthSuccessCallback?,
                      failure: LinkedInAuthFailureCallback?) {
        
        // Check if previous token is still in memory and is valid
        if hasValidAccessToken {
            success?(token: accessToken)
        } else {
            
            // Use LinkedInSDK if app is installed
            if LinkedInKit.isLinkedInAppInstalled {
                
                let session = LISDKSessionManager.sharedInstance().session
                accessToken = LinkedInAuthenticator.tokenFromSDKSession(session)
                
                if session.isValid() && hasValidAccessToken {
                    success?(token: accessToken)
                }  else {
                    //Authorize through SDK
                    if let client = httpClient {
                        LISDKSessionManager.createSessionWithAuth(client.linkedInConfiguration.permissions,
                                                                  state: client.linkedInConfiguration.state,
                                                                  showGoToAppStoreDialog: false,
                                                                  successBlock:
                            { [weak self] (response) in
                                self?.accessToken = LinkedInAuthenticator.tokenFromSDKSession(LISDKSessionManager.sharedInstance().session)
                                success?(token: self?.accessToken)
                            }, errorBlock: { (error) in
                                failure?(error: error)
                        })
                    } else {
                        //TODO: Define custom error
                        failure?(error: nil)
                    }
                    
                }
            } else {
                if let httpClient = httpClient {
                    httpClient.getAuthorizationCode(withSuccessCalback: { [weak self] (code) in
                        self?.httpClient?.getAccessToken(forAuthorizationCode: code, success: { [weak self] (token) in
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
                } else {
                    //TODO: Define custom error
                    failure?(error: nil)
                }
            }
        }
    }
    
    //MARK: - Requests
    func requestUrl(urlString: String, success: LinkedInRequestSuccessCallback?, failure: LinkedInRequestFailureCallback?) {
        
        // **NOTE** Only GET request
        
        if hasValidAccessToken {
            if LinkedInKit.isTokenFromMobileSDK {
                LISDKAPIHelper.sharedInstance().getRequest(urlString,
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
            } else {
                let headers = ["Authorization": "Bearer \(accessToken!.accessToken!)"]
                httpClient?.request(.GET, urlString,
                    parameters: nil,
                    encoding: .URL,
                    headers: headers).validate().responseJSON(completionHandler: { response in
                        
                        switch response.result {
                        case .Success(let JSON):
                            let sdkResponse = LinkedInSDKResponse()
                            sdkResponse.jsonObject = JSON as! [String : AnyObject]
                            sdkResponse.statusCode = 200
                            
                            success?(response: sdkResponse)
                        case .Failure(let error):
                            print("asdfasd")
                            failure?(error: LISDKAPIError.errorWithError(error) as! LISDKAPIError)
                        }
                    })
            }
        } else {
            // TODO: handle sign out
        }
    }
    
    //MARK: - Helper methods
    private static func tokenFromSDKSession(session: LISDKSession) -> LinkedInAccessToken? {
        if let session = LISDKSessionManager.sharedInstance().session where session.isValid() {
            return LinkedInAccessToken(withAccessToken: session.accessToken.accessTokenValue,
                                       expireDate: session.accessToken.expiration,
                                       isSDK: true)
        }
        return nil
    }
}
