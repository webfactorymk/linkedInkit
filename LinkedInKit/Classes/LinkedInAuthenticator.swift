import Foundation

public typealias LinkedInAuthSuccessCallback = (token: LinkedInAccessToken?) -> ()
public typealias LinkedInAuthFailureCallback = (error: NSError?) -> ()
public typealias LinkedInRequestSuccessCallback = (response: LinkedInSDKResponse?) -> ()
public typealias LinkedInRequestFailureCallback = (error: NSError?) -> ()

class LinkedInAuthenticator: NSObject {
    
    static let sharedInstance = LinkedInAuthenticator()
    
    private var storedToken: LinkedInAccessToken?
    
    var accessToken: LinkedInAccessToken? {
        set {
            storedToken = newValue
            NSUserDefaults.lik_saveLinkedInAccessToken(newValue)
        }
        get {
            return storedToken ?? NSUserDefaults.lik_getLinkedInAccessToken()
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
    
    func clearLinkedInCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                if cookie.domain.containsString("linkedin") {
                    storage.deleteCookie(cookie)
                }
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: Authentication
    func authenticate(success: LinkedInAuthSuccessCallback?,
                      failure: LinkedInAuthFailureCallback?) {
        
        // Check if previous token is still in memory and is valid
        if isAuthorized {
            success?(token: accessToken)
        } else {
            if LinkedInKit.isLinkedInAppInstalled {
                // Use LinkedInSDK if app is installed
                authThroughSDK(success, failure: failure)
            } else {
                authThroughWeb(success, failure: failure)
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
    
    private func authThroughWeb(success: LinkedInAuthSuccessCallback?,
                                failure: LinkedInAuthFailureCallback?) {
        if let httpClient = LinkedInRequestProvider.sharedProvider.httpClient {
            httpClient.getAuthorizationCode(withSuccessCalback: { [weak self] (code) in
                httpClient.getAccessToken(forAuthorizationCode: code,
                    success: { [weak self] (token) in
                        self?.accessToken = token
                        success?(token: self?.accessToken)
                    }, failure: { (error) in
                        if let error = error {
                            failure?(error: NSError.error(withLIError: error))
                        } else {
                            failure?(error: error)
                        }
                })
                }, cancelCallback: {
                    failure?(error: NSError.error(withErrorDomain: .AuthCanceled, customDescription: ""))
                }, failureCallback: { (error) in
                    if let error = error {
                        failure?(error: NSError.error(withLIError: error))
                    } else {
                        failure?(error: error)
                    }
            })
        } else {
            failure?(error: NSError.error(withErrorDomain: .SetupFailure))
        }
    }
    
    private func authThroughSDK(success: LinkedInAuthSuccessCallback?,
                                failure: LinkedInAuthFailureCallback?) {
        let session = LISDKSessionManager.sharedInstance().session
        accessToken = LinkedInAuthenticator.tokenFromSDKSession(session)
        
        if session.isValid() && hasValidAccessToken {
            success?(token: accessToken)
        }  else {
            if let client = LinkedInRequestProvider.sharedProvider.httpClient {
                LISDKSessionManager.createSessionWithAuth(client.linkedInConfiguration.permissions,
                                                          state: client.linkedInConfiguration.state,
                                                          showGoToAppStoreDialog: false,
                                                          successBlock:
                    { [weak self] (response) in
                        self?.accessToken = LinkedInAuthenticator.tokenFromSDKSession(LISDKSessionManager.sharedInstance().session)
                        success?(token: self?.accessToken)
                    }, errorBlock: { (error) in
                        failure?(error: NSError.error(withLIError: error))
                })
            } else {
                failure?(error: NSError.error(withErrorDomain: .SetupFailure, customDescription: ""))
            }
        }
    }
}
