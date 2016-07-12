import Foundation

public typealias LinkedInAuthSuccessCallback = (token: LinkedInAccessToken?) -> ()
public typealias LinkedInAuthFailureCallback = (error: NSError?) -> ()
public typealias LinkedInRequestSuccessCallback = (response: LinkedInSDKResponse?) -> ()
public typealias LinkedInRequestFailureCallback = (error: LISDKAPIError?) -> ()

class LinkedInAuthenticator: NSObject {
    
    static let sharedInstance = LinkedInAuthenticator()
    
    var httpClient: LinkedInHTTPClient?
    
    private let linkedInKeychainKey = "wf.linkedInKit.accessToken"
    private var storedToken: LinkedInAccessToken?
    
    var accessToken: LinkedInAccessToken? {
        set {
            storedToken = newValue
            if let accessToken = accessToken {
                KeychainWrapper.setObject(accessToken, forKey: linkedInKeychainKey)
            } else {
                KeychainWrapper.removeObjectForKey(linkedInKeychainKey)
            }
        }
        get {
            return storedToken ?? KeychainWrapper.objectForKey(linkedInKeychainKey) as? LinkedInAccessToken
        }
    }
    
    var hasValidAccessToken: Bool {
        return accessToken != nil && accessToken?.expireDate > NSDate()
    }
    
    var isAuthorized: Bool {
        return hasValidAccessToken && LISDKSessionManager.sharedInstance().session.isValid()
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
            if LinkedInKit.isLinkedInAppInstalled {
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
            }
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
