import Foundation
import Alamofire

public class LinkedInHTTPClient: Alamofire.Manager {
    
    let linkedInConfiguration: LinkedInConfiguration
    var presentingViewController: UIViewController?
    
    public var viewControllerDelegate: LinkedInAuthorizationViewControllerDelegate?
    
    public init(linkedInConfiguration: LinkedInConfiguration) {
        self.linkedInConfiguration = linkedInConfiguration
        super.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    func getAuthorizationCode(withsuccessCallback successCallback: LinkedInAuthCodeSuccessCallback?,
                                                 cancelCallback: LinkedInAuthCodeCancelCallback?,
                                                 failureCallback: LinkedInAuthFailureCallback?) {
        let viewController = LinkedInAuthorizationViewController(configuration: linkedInConfiguration, successCallback: { [weak self] (code) in
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
    }
    
    func getAccessToken(forAuthorizationCode code: String,
                                             success: LinkedInAuthSuccessCallback,
                                             failure: LinkedInAuthFailureCallback) {
        let redirectURL = linkedInConfiguration.redirectURL.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let accessTokenURL = NSString(format: ApiRoutes.accessTokenRoute, code, redirectURL, linkedInConfiguration.clientID, linkedInConfiguration.clientSecret)
        
        self.request(.POST, accessTokenURL as String, parameters: nil, encoding: .URL, headers: nil).validate().responseJSON { response in
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
