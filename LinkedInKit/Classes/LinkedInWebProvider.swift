import Foundation
import Alamofire

class LinkedInWebProvider: LinkedInProvider {
    
    static let sharedProvider = LinkedInWebProvider()

    var authViewDelegate: LinkedInAuthorizationViewControllerDelegate?
    var linkedInConfiguration: LinkedInConfiguration?
    var presentingViewController: UIViewController?
    
    public var viewControllerDelegate: LinkedInAuthorizationViewControllerDelegate?
    private var requestManager: Alamofire.Manager
    
    init() {
        requestManager = Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    func signIn(success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?) {
        
        getAuthorizationCode(withSuccessCallback: { [weak self] (code) in
            self?.getAccessToken(forAuthorizationCode: code,
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
            
            let request = requestManager.request(
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
    
    //MARK: 
    func getAuthorizationCode(withSuccessCallback successCallback: LinkedInAuthCodeSuccessCallback?,
                                                  cancelCallback: LinkedInAuthCodeCancelCallback?,
                                                  failureCallback: LinkedInAuthFailureCallback?) {
        if let linkedInConfiguration = linkedInConfiguration {
            let viewController = LinkedInAuthorizationViewController(
                configuration: linkedInConfiguration,
                successCallback: { [weak self] (code) in
                    
                    self?.hideAuthorizationViewController()
                    successCallback?(code: code)
                    
                }, cancelCallback: { [weak self] in
                    self?.hideAuthorizationViewController()
                    cancelCallback?()
                    
            }) { [weak self] (error) in
                self?.hideAuthorizationViewController()
                failureCallback?(error: error)
            }
            viewController.delegate = viewControllerDelegate
            showAuthorizationViewController(viewController)
        } else {
            assert(linkedInConfiguration == nil, "LinkedInKit is not configured properly. See LinkedInConfiguration")
        }
    }
    
    func getAccessToken(forAuthorizationCode code: String,
                                             success: LinkedInAuthSuccessCallback,
                                             failure: LinkedInAuthFailureCallback) {
        if let linkedInConfiguration = linkedInConfiguration {
            let redirectURL = linkedInConfiguration.redirectURL.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
            let accessTokenURL = NSString(format: ApiRoutes.accessTokenRoute,
                                          code, redirectURL,
                                          linkedInConfiguration.clientID,
                                          linkedInConfiguration.clientSecret)
            
            requestManager.request(.POST,
                accessTokenURL as String,
                parameters: nil,
                encoding: .URL,
                headers: nil)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success(let JSON):
                        if let json = JSON as? [String: AnyObject] {
                            if let accessToken = json[Constants.Parameters.accessToken] as? String,
                                expireTimestamp = json[Constants.Parameters.expiresIn] as? Double {
                                
                                let expireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(expireTimestamp/1000))
                                let token = LinkedInAccessToken(withAccessToken: accessToken,
                                    expireDate: expireDate,
                                    isSDK: false)
                                
                                success(token: token)
                            } else {
                                failure(error: NSError.error(withErrorDomain: .ParseFailure))
                            }
                        } else {
                            failure(error: NSError.error(withErrorDomain: .ParseFailure))
                        }
                    case .Failure(let error):
                        failure(error: error)
                    }
            }
        } else {
            assert(linkedInConfiguration == nil, "LinkedInKit is not configured properly. See LinkedInConfiguration")
        }
    }
    
    //Helper methods
    func showAuthorizationViewController(viewController: LinkedInAuthorizationViewController) {
        presentingViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            navigationController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        }
        presentingViewController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func hideAuthorizationViewController() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}