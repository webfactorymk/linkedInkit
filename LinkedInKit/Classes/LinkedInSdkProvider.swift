import Foundation
import Alamofire

class LinkedInSdkProvider: LinkedInProvider {
    
    static let sharedProvider = LinkedInSdkProvider()
    var linkedInConfiguration: LinkedInConfiguration?
    
    func signIn(success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?) {
        let session = LISDKSessionManager.sharedInstance().session
        let accessToken = LinkedInAuthenticator.tokenFromSDKSession(session)
        
        if session.isValid() && LinkedInAuthenticator.sharedInstance.hasValidAccessToken {
            success?(token: accessToken)
        }  else {
            if let client = LinkedInRequestProvider.sharedProvider.httpClient {
                LISDKSessionManager.createSessionWithAuth(client.linkedInConfiguration.permissions,
                                                          state: client.linkedInConfiguration.state,
                                                          showGoToAppStoreDialog: false,
                                                          successBlock:
                    { [weak self] (response) in
//                        self?.accessToken = LinkedInAuthenticator.tokenFromSDKSession(LISDKSessionManager.sharedInstance().session)
//                        success?(token: self?.accessToken)
                    }, errorBlock: { (error) in
                        failure?(error: NSError.error(withLIError: error))
                })
            } else {
                failure?(error: NSError.error(withErrorDomain: .SetupFailure, customDescription: ""))
            }
        }
    }
    
    func requestUrl(urlString: String,
                    method: Alamofire.Method,
                    parameters: [String : AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?) {
        
        var requestBody: NSData?
        var requestUrlString = urlString
        
        if let parameters = parameters where (method == .POST || method == .PUT) {
            // add params as request body
            do {
                requestBody = try NSJSONSerialization.dataWithJSONObject(parameters,
                                                                         options: NSJSONWritingOptions.PrettyPrinted)
            } catch { }
        } else {
            // append params to url
            if let requestURL = NSURL(string: urlString), parameters = parameters {
                let urlComponents = NSURLComponents(URL: requestURL, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = urlComponents?.queryItems ?? [NSURLQueryItem]()
                for item in parameters {
                    if let value = item.1 as? String {
                        let queryItem = NSURLQueryItem(name: item.0, value: value)
                        urlComponents?.queryItems?.append(queryItem)
                    }
                }
                requestUrlString = String(requestURL)
            }
        }
        
        LISDKAPIHelper.sharedInstance().apiRequest(
            requestUrlString,
            method: method.rawValue,
            body: requestBody,
            success: { (response) in
                
                if let dataFromString = response.data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    success?(response: LinkedInSDKResponse(withData: dataFromString,
                        statusCode: Int(response.statusCode)))
                } else {
                    success?(response: nil)
                }
            }, error: { (error) in
                failure?(error: NSError.error(withLIError: error))
        })
    }
    
    func openProfileWithMemberId(id: String,
                                 success: ((success: Bool) -> ())?,
                                 failure: ((error: NSError) -> ())?) {
        let customState = "openProfileWithMemberId"
        LISDKDeeplinkHelper.sharedInstance().viewOtherProfile(
            id,
            withState: customState,
            showGoToAppStoreDialog: false,
            success: { (state) in
                success?(success: state == customState)
            }, error: { (error, state) in
                failure?(error: error)
        })
    }
    
    func signOut() {
        LISDKAPIHelper.sharedInstance().cancelCalls()
        LISDKSessionManager.clearSession()
        LinkedInAuthenticator.sharedInstance.accessToken = nil
    }
}