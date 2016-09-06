import Foundation
import Alamofire

class LinkedInWebProvider: LinkedInProvider {
    
    static let sharedProvider = LinkedInWebProvider()
    
    var httpClient: LinkedInHTTPClient?
    var authViewDelegate: LinkedInAuthorizationViewControllerDelegate?
    
    func signIn(success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?) {
        
        if let httpClient = httpClient {
            httpClient.getAuthorizationCode(withsuccessCallback: { [weak self] (code) in
                httpClient.getAccessToken(forAuthorizationCode: code,
                    success: { [weak self] (token) in
                        LinkedInTokenManager.sharedManager.accessToken = token
                        success?(token: token)
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
    
    func requestUrl(urlString: String,
                    method: Alamofire.Method,
                    parameters: [String : AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?) {
        if LinkedInTokenManager.sharedManager.hasValidAccessToken {
            let token = LinkedInTokenManager.sharedManager.accessToken!.accessToken!
            let headers = [Constants.HttpHeaderKeys.authorization: NSString(format: Constants.HttpHeaderValues.authorization, token) as String,
                           Constants.HttpHeaderKeys.format: Constants.HttpHeaderValues.format,
                           Constants.HttpHeaderKeys.contentType: Constants.HttpHeaderValues.contentType]
            let encoding = (method == .GET) ? Alamofire.ParameterEncoding.URL : Alamofire.ParameterEncoding.JSON
            
            let request = httpClient?.request(
                method,
                urlString,
                parameters: parameters,
                encoding: encoding,
                headers: headers).validate().responseJSON(completionHandler: { response in
                    switch response.result {
                    case .Success(let JSON):
                        let sdkResponse = LinkedInSDKResponse()
                        sdkResponse.jsonObject = JSON as! [String : AnyObject]
                        sdkResponse.statusCode = 200
                        
                        success?(response: sdkResponse)
                    case .Failure(let error):
                        failure?(error: NSError.error(withLIError: error))
                    }
                })
        } else {
            failure?(error: NSError.error(withErrorDomain: LinkedInErrorDomain.NotAuthenticated))
        }
    }
    
    func openProfileWithMemberId(id: String,
                                 success: ((success: Bool) -> ())?,
                                 failure: ((error: NSError) -> ())?) {
        let route = NSString(format: ApiRoutes.profileDetailsRoute, id)
        
        // Get user details in order to acquire linkedIn profile url
        requestUrl(route as String,
                   method: .GET,
                   parameters: nil,
                   success: { (response) in
                    var memberURL: NSURL? = nil
                    if let json = response?.jsonObject, urlJSON = json[Constants.Parameters.profileUrl] as? [String: AnyObject] {
                        if let urlString = urlJSON[Constants.Parameters.url] as? String {
                            memberURL = NSURL(string: urlString)
                        }
                    }
                    
                    if let memberURL = memberURL where UIApplication.sharedApplication().canOpenURL(memberURL) {
                        UIApplication.sharedApplication().openURL(memberURL)
                        success?(success: true)
                    } else {
                        failure?(error: NSError.error(withErrorDomain: .ParseFailure))
                    }
                    
            }, failure: { (error) in
                let failureError = error ?? NSError.error(withErrorDomain: .RESTFailure)
                failure?(error: failureError)
        })
    }
    
    func signOut() {
        LinkedInTokenManager.sharedManager.accessToken = nil
        clearLinkedInCookies()
    }
    
    //MARK: Helper methods
    private func clearLinkedInCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                if cookie.domain.containsString(Constants.linkedInDomain) {
                    storage.deleteCookie(cookie)
                }
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}