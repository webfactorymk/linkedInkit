import Foundation
import Alamofire

public class LinkedInKit {
    
    public static var isAuthorized: Bool {
        return LinkedInTokenManager.sharedManager.isAuthorized
    }
    
    public static var isLinkedInAppInstalled: Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: Constants.linkedInScheme)!)
    }
    
    public static var isTokenFromMobileSDK: Bool {
        return LinkedInTokenManager.sharedManager.accessToken?.isSDK ?? false
    }
    
    static public var authViewControllerDelegate: LinkedInAuthorizationViewControllerDelegate? {
        set { LinkedInWebProvider.sharedProvider.viewControllerDelegate = newValue }
        get { return LinkedInWebProvider.sharedProvider.viewControllerDelegate }

    }
    
    public class func setup(withConfiguration configuration: LinkedInConfiguration) {
        LinkedInSdkProvider.sharedProvider.linkedInConfiguration = configuration
        LinkedInWebProvider.sharedProvider.linkedInConfiguration = configuration
    }
    
    public class func authenticate(success: LinkedInAuthSuccessCallback?,
                                   failure: LinkedInAuthFailureCallback?) {
        if LinkedInTokenManager.sharedManager.isAuthorized {
            success?(token: LinkedInTokenManager.sharedManager.accessToken)
        } else {
            linkedInProvider().signIn(success, failure: failure)
        }
    }
    
    public class func requestUrl(urlString: String,
                                 method: Alamofire.Method,
                                 parameters: [String: AnyObject]?,
                                 success: LinkedInRequestSuccessCallback?,
                                 failure: LinkedInRequestFailureCallback?) {
        linkedInProvider().requestUrl(urlString,
                                      method: method,
                                      parameters: parameters,
                                      success: success,
                                      failure: failure)
    }
    
    public class func openProfileWithMemberId(id: String,
                                              success: ((success: Bool) -> ())?,
                                              failure: ((error: NSError) -> ())?) {
        linkedInProvider().openProfileWithMemberId(id, success: success, failure: failure)
    }
    
    public class func signOut() {
        linkedInProvider().signOut()
    }
       
    public class func shouldHandleUrl(url: NSURL) -> Bool {
        return isLinkedInAppInstalled && LISDKCallbackHandler.shouldHandleUrl(url)
    }
    
    public class func application(application: UIApplication,
                                  openURL url: NSURL,
                                          sourceApplication: String?,
                                          annotation: AnyObject) -> Bool {
        return isLinkedInAppInstalled && LISDKCallbackHandler.application(application,
                                                                          openURL: url,
                                                                          sourceApplication: sourceApplication,
                                                                          annotation: annotation)
    }
    
    class func linkedInProvider() -> LinkedInProvider {
        if isAuthorized {
            if isLinkedInAppInstalled && isTokenFromMobileSDK {
                return LinkedInSdkProvider.sharedProvider
            }
            return LinkedInWebProvider.sharedProvider
            
        } else if isLinkedInAppInstalled {
            return LinkedInSdkProvider.sharedProvider
        }
        return LinkedInWebProvider.sharedProvider
    }
}