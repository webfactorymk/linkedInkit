import Foundation
import Alamofire

class LinkedInSdkProvider: LinkedInProvider {
    
    static let sharedProvider = LinkedInSdkProvider()
    var linkedInConfiguration: LinkedInConfiguration?
    
    func signIn(_ success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?) {        
        if let linkedInConfiguration = linkedInConfiguration {
            LISDKSessionManager.createSession(withAuth: linkedInConfiguration.permissions,
                                              state: linkedInConfiguration.state,
                                              showGoToAppStoreDialog: false,
                                              successBlock:
                { [weak self] (response) in
                    let accessToken = self?.tokenFromSDKSession(LISDKSessionManager.sharedInstance().session)
                    LinkedInTokenManager.sharedManager.accessToken = accessToken
                    success?(accessToken)
                }, errorBlock: { (error: Error?) in
                    failure?(error as NSError?)
            })
        } else {
            failure?(NSError.error(withErrorDomain: .SetupFailure, customDescription: ""))
        }
    }
    
    func requestUrl(_ urlString: String,
                    method: Alamofire.HTTPMethod,
                    parameters: [String: AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?) {
        if LinkedInTokenManager.sharedManager.hasValidAccessToken {
            var requestBody: Data?
            var requestUrlString = urlString
            
            if let parameters = parameters, (method == .post || method == .put) {
                // add params as request body
                do {
                    requestBody = try JSONSerialization.data(withJSONObject: parameters,
                                                                             options: JSONSerialization.WritingOptions.prettyPrinted)
                } catch { }
            } else {
                // append params to url
                if let requestURL = URL(string: urlString), let parameters = parameters {
                    var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
                    let queryItems = urlComponents?.queryItems
                    urlComponents?.queryItems = queryItems ?? [URLQueryItem]()
                    
                    for item in parameters {
                        if let value = item.1 as? String {
                            let queryItem = URLQueryItem(name: item.0, value: value)
                            urlComponents?.queryItems?.append(queryItem)
                        }
                    }
                    requestUrlString = String(describing: requestURL)
                }
            }
            
            LISDKAPIHelper.sharedInstance().apiRequest(
                requestUrlString,
                method: method.rawValue,
                body: requestBody,
                success: { (response) in
                    if let statusCode = response?.statusCode,
                        let dataFromString = response?.data.data(using: String.Encoding.utf8,
                                                                allowLossyConversion: false) {
                        success?(LinkedInSDKResponse(withData: dataFromString,
                                                     statusCode: Int(statusCode)))
                    } else {
                        success?(nil)
                    }
            }, error: { (error) in
                failure?(error)
            })
        } else {
            failure?(NSError.error(withErrorDomain: LinkedInErrorDomain.NotAuthenticated))
        }
    }
    
    func openProfileWithMemberId(_ id: String,
                                 success: ((_ success: Bool) -> ())?,
                                 failure: ((_ error: NSError) -> ())?) {
        let customState = "openProfileWithMemberId"
    
        LISDKDeeplinkHelper.sharedInstance().viewOtherProfile(
            id,
            withState: customState,
            showGoToAppStoreDialog: false,
            success: { (state) in
                success?(state == customState)
        }, error: { (error: Error?, state: String?) in
            if let error = error as NSError? {
                failure?(error as NSError)
            }
        })
    }
    
    func signOut() {
        LISDKAPIHelper.sharedInstance().cancelCalls()
        LISDKSessionManager.clearSession()
        LinkedInTokenManager.sharedManager.accessToken = nil
    }
    
    //MARK: Helper methods
    fileprivate func tokenFromSDKSession(_ session: LISDKSession) -> LinkedInAccessToken? {
        if let session = LISDKSessionManager.sharedInstance().session, session.isValid() {
            return LinkedInAccessToken(withAccessToken: session.accessToken.accessTokenValue,
                                       expireDate: session.accessToken.expiration,
                                       isSDK: true)
        }
        
        return nil
    }
}
