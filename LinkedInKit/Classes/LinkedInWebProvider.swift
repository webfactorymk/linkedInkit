import Foundation
import Alamofire

class LinkedInWebProvider: LinkedInProvider {
    
    static let sharedProvider = LinkedInWebProvider()

    var authViewDelegate: LinkedInAuthorizationViewControllerDelegate?
    var linkedInConfiguration: LinkedInConfiguration?
    var presentingViewController: UIViewController?
    
    weak var viewControllerDelegate: LinkedInAuthorizationViewControllerDelegate?
    fileprivate var requestManager: Alamofire.SessionManager
    
    init() {
        requestManager = SessionManager(configuration: URLSessionConfiguration.default)
    }
    
    func signIn(_ success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?) {
        getAuthorizationCode(withSuccessCallback: { [weak self] (code) in
            self?.getAccessToken(forAuthorizationCode: code,
                success: { (token) in
                    LinkedInTokenManager.sharedManager.accessToken = token
                    success?(token)
                }, failure: { (error) in
                    if let error = error {
                        failure?(NSError.error(withLIError: error))
                    } else {
                        failure?(error)
                    }
            })
            }, cancelCallback: {
                failure?(NSError.error(withErrorDomain: .AuthCanceled, customDescription: ""))
            }, failureCallback: { (error) in
                if let error = error {
                    failure?(NSError.error(withLIError: error))
                } else {
                    failure?(error)
                }
        })
    }
    
    func requestUrl(_ urlString: String,
                    method: Alamofire.HTTPMethod,
                    parameters: [String: AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?) {
        
        if LinkedInTokenManager.sharedManager.hasValidAccessToken {
            let token = LinkedInTokenManager.sharedManager.accessToken!.accessToken!
            let authHeaderValue = NSString(format: Constants.HttpHeaderValues.authorization as NSString, token) as String
            let headers = [Constants.HttpHeaderKeys.authorization: authHeaderValue,
                           Constants.HttpHeaderKeys.format: Constants.HttpHeaderValues.format,
                           Constants.HttpHeaderKeys.contentType: Constants.HttpHeaderValues.contentType]
            let encoding: ParameterEncoding = (method == .get) ? URLEncoding.default : JSONEncoding.default
            
            _ = requestManager.request(urlString,
                                       method: method,
                                       parameters: parameters,
                                       encoding: encoding,
                                       headers: headers).validate().responseJSON(completionHandler: { response in
                    switch response.result {
                    case .success(let JSON):
                        let sdkResponse = LinkedInSDKResponse()
                        sdkResponse.jsonObject = (JSON as! [String: AnyObject])
                        sdkResponse.statusCode = 200
                        
                        success?(sdkResponse)
                    case .failure(let error):
                        failure?(NSError.error(withLIError: error as NSError))
                    }
                })
        } else {
            failure?(NSError.error(withErrorDomain: LinkedInErrorDomain.NotAuthenticated))
        }
    }
    
    func openProfileWithMemberId(_ id: String,
                                 success: ((_ success: Bool) -> ())?,
                                 failure: ((_ error: NSError) -> ())?) {
        let route = NSString(format: ApiRoutes.profileDetailsRoute as NSString, id)
        
        // Get user details in order to acquire linkedIn profile url
        requestUrl(route as String,
                   method: .get,
                   parameters: nil,
                   success: { (response) in
                    
                    var memberURL: URL? = nil
                    if let json = response?.jsonObject, let urlJSON = json[Constants.Parameters.profileUrl] as? [String: AnyObject] {
                        if let urlString = urlJSON[Constants.Parameters.url] as? String {
                            memberURL = URL(string: urlString)
                        }
                    }
                    
                    if let memberURL = memberURL, UIApplication.shared.canOpenURL(memberURL) {
                        UIApplication.shared.openURL(memberURL)
                        success?(true)
                    } else {
                        failure?(NSError.error(withErrorDomain: .ParseFailure))
                    }
                    
            }, failure: { (error) in
                let failureError = error ?? NSError.error(withErrorDomain: .RESTFailure)
                failure?(failureError)
        })
    }
    
    func signOut() {
        LinkedInTokenManager.sharedManager.accessToken = nil
        clearLinkedInCookies()
    }
    
    //MARK: Helper methods
    fileprivate func clearLinkedInCookies() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                if cookie.domain.contains(Constants.linkedInDomain) {
                    storage.deleteCookie(cookie)
                }
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    //MARK: 
    func getAuthorizationCode(withSuccessCallback successCallback: LinkedInAuthCodeSuccessCallback?,
                                                  cancelCallback: LinkedInAuthCodeCancelCallback?,
                                                  failureCallback: LinkedInAuthFailureCallback?) {
        if let linkedInConfiguration = linkedInConfiguration {
            let viewController = LinkedInAuthorizationViewController (
                configuration: linkedInConfiguration,
                successCallback: { [weak self] (code) in
                    self?.hideAuthorizationViewController()
                    successCallback?(code)
                }, cancelCallback: { [weak self] in
                    self?.hideAuthorizationViewController()
                    cancelCallback?()
            }) { [weak self] (error) in
                self?.hideAuthorizationViewController()
                failureCallback?(error)
            }
            viewController.delegate = viewControllerDelegate
            showAuthorizationViewController(viewController)
        } else {
            failureCallback?(NSError.error(withErrorDomain: .SetupFailure, customDescription: ""))
        }
    }
    
    func getAccessToken(forAuthorizationCode code: String,
                                             success: @escaping LinkedInAuthSuccessCallback,
                                             failure: @escaping LinkedInAuthFailureCallback) {
        if let linkedInConfiguration = linkedInConfiguration {
            let redirectURL = linkedInConfiguration.redirectURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let accessTokenURL = NSString(format: ApiRoutes.accessTokenRoute as NSString,
                                          code, redirectURL,
                                          linkedInConfiguration.clientID,
                                          linkedInConfiguration.clientSecret)
            requestManager.request(
                accessTokenURL as String,
                method: .post,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: nil)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let JSON):
                        if let json = JSON as? [String: AnyObject] {
                            if let accessToken = json[Constants.Parameters.accessToken] as? String,
                                let expireTimestamp = json[Constants.Parameters.expiresIn] as? Double {
                                let expireDate = Date(timeIntervalSinceNow: TimeInterval(expireTimestamp / 1000))
                                let token = LinkedInAccessToken(withAccessToken: accessToken,
                                    expireDate: expireDate,
                                    isSDK: false)
                                
                                success(token)
                            } else {
                                failure(NSError.error(withErrorDomain: .ParseFailure))
                            }
                        } else {
                            failure(NSError.error(withErrorDomain: .ParseFailure))
                        }
                    case .failure(let error):
                        failure(error as NSError)
                    }
            }
        } else {
            failure(NSError.error(withErrorDomain: .SetupFailure, customDescription: ""))
        }
    }
    
    //Helper methods
    func showAuthorizationViewController(_ viewController: LinkedInAuthorizationViewController) {
        presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        }
        
        presentingViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func hideAuthorizationViewController() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
