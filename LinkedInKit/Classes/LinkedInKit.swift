import Foundation
import Alamofire

open class LinkedInKit {
    
    public static var isAuthorized: Bool {
        return LinkedInTokenManager.sharedManager.isAuthorized
    }
    
    public static var isLinkedInAppInstalled: Bool {
        return UIApplication.shared.canOpenURL(URL(string: Constants.linkedInScheme)!)
    }
    
    public static var isTokenFromMobileSDK: Bool {
        return LinkedInTokenManager.sharedManager.accessToken?.isSDK ?? false
    }
    
    public static var authViewControllerDelegate: LinkedInAuthorizationViewControllerDelegate? {
        set { LinkedInWebProvider.sharedProvider.viewControllerDelegate = newValue }
        get { return LinkedInWebProvider.sharedProvider.viewControllerDelegate }

    }
    
    open class func setup(withConfiguration configuration: LinkedInConfiguration) {
        LinkedInSdkProvider.sharedProvider.linkedInConfiguration = configuration
        LinkedInWebProvider.sharedProvider.linkedInConfiguration = configuration
    }
    
    open class func authenticate(_ success: LinkedInAuthSuccessCallback?,
                                   failure: LinkedInAuthFailureCallback?) {
        if LinkedInTokenManager.sharedManager.isAuthorized {
            success?(LinkedInTokenManager.sharedManager.accessToken)
        } else {
            linkedInProvider().signIn(success, failure: failure)
        }
    }
    
    open class func requestUrl(_ urlString: String,
                                 method: Alamofire.HTTPMethod,
                                 parameters: [String: AnyObject]?,
                                 success: LinkedInRequestSuccessCallback?,
                                 failure: LinkedInRequestFailureCallback?) {
        linkedInProvider().requestUrl(urlString,
                                      method: method,
                                      parameters: parameters,
                                      success: success,
                                      failure: failure)
    }
    
    open class func openProfileWithMemberId(_ id: String,
                                              success: ((_ success: Bool) -> ())?,
                                              failure: ((_ error: NSError) -> ())?) {
        linkedInProvider().openProfileWithMemberId(id, success: success, failure: failure)
    }
    
    open class func signOut() {
        linkedInProvider().signOut()
    }
       
    open class func shouldHandleUrl(_ url: URL) -> Bool {
        return isLinkedInAppInstalled && LISDKCallbackHandler.shouldHandle(url)
    }
    
    open class func application(_ application: UIApplication,
                                  openURL url: URL,
                                          sourceApplication: String?,
                                          annotation: AnyObject) -> Bool {
        return isLinkedInAppInstalled && LISDKCallbackHandler.application(application,
                                                                          open: url,
                                                                          sourceApplication: sourceApplication,
                                                                          annotation: annotation)
    }
    
    class func linkedInProvider() -> LinkedInProvider {
        if isAuthorized {
            if isLinkedInAppInstalled && isTokenFromMobileSDK { return LinkedInSdkProvider.sharedProvider }
            
            return LinkedInWebProvider.sharedProvider
        } else if isLinkedInAppInstalled {
            return LinkedInSdkProvider.sharedProvider
        }
        
        return LinkedInWebProvider.sharedProvider
    }
}

