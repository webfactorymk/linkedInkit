import Foundation
import Alamofire

open class LinkedInHTTPClient: Alamofire.SessionManager {
    
    let linkedInConfiguration: LinkedInConfiguration
    var presentingViewController: UIViewController?
    
    open var viewControllerDelegate: LinkedInAuthorizationViewControllerDelegate?
    
    public init(linkedInConfiguration: LinkedInConfiguration) {
        self.linkedInConfiguration = linkedInConfiguration
        super.init(configuration: URLSessionConfiguration.default)
    }
    
    func getAuthorizationCode(withsuccessCallback successCallback: LinkedInAuthCodeSuccessCallback?,
                                                 cancelCallback: LinkedInAuthCodeCancelCallback?,
                                                 failureCallback: LinkedInAuthFailureCallback?) {
        let viewController = LinkedInAuthorizationViewController(configuration: linkedInConfiguration, successCallback: { [weak self] (code) in
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
    }
    
    func getAccessToken(forAuthorizationCode code: String,
                                             success: @escaping LinkedInAuthSuccessCallback,
                                             failure: @escaping LinkedInAuthFailureCallback) {
        let redirectURL = linkedInConfiguration.redirectURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let accessTokenURL = NSString(format: ApiRoutes.accessTokenRoute as NSString, code, redirectURL, linkedInConfiguration.clientID, linkedInConfiguration.clientSecret)
        
        self.request(accessTokenURL as String, method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(let JSON):
                if let json = JSON as? [String: AnyObject] {
                    if let accessToken = json[Constants.Parameters.accessToken] as? String,
                        let expireTimestamp = json[Constants.Parameters.expiresIn] as? Double {
                        
                        let expireDate = NSDate(timeIntervalSinceNow: TimeInterval(expireTimestamp/1000))
                        let token = LinkedInAccessToken(withAccessToken: accessToken,
                            expireDate: expireDate as Date,
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
    }
    
    //Helper methods
    func showAuthorizationViewController(_ viewController: LinkedInAuthorizationViewController) {
        presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        let navigationController = UINavigationController(rootViewController: viewController)
        presentingViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func hideAuthorizationViewController() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
