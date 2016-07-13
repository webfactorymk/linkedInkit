import Foundation

public class LinkedInKit {
    
    public static var isAuthorized: Bool {
        return LinkedInAuthenticator.sharedInstance.isAuthorized
    }
    
    public static var isLinkedInAppInstalled: Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "linkedin://")!)
    }
    
    public static var isTokenFromMobileSDK: Bool {
        return LinkedInAuthenticator.sharedInstance.accessToken?.isSDK ?? false
    }
    
    static public var authViewControllerDelegate: LinkedInAuthorizationViewControllerDelegate? {
        set { LinkedInAuthenticator.sharedInstance.httpClient?.viewControllerDelegate = newValue }
        get { return LinkedInAuthenticator.sharedInstance.httpClient?.viewControllerDelegate }
    }
    
    public class func setup(withConfiguration configuration: LinkedInConfiguration) {
        let httpClient = LinkedInHTTPClient(linkedInConfiguration: configuration)
        
        LinkedInAuthenticator.sharedInstance.httpClient = httpClient
    }
    
    public class func authenticate(success: LinkedInAuthSuccessCallback?,
                                   failure: LinkedInAuthFailureCallback?) {
        
        LinkedInAuthenticator.sharedInstance.authenticate(success,
                                                          failure: failure)
    }
    
    public class func requestUrl(urlString: String,
                                 success: LinkedInRequestSuccessCallback?,
                                 failure: LinkedInRequestFailureCallback?) {
        
        LinkedInAuthenticator.sharedInstance.requestUrl(urlString,
                                                        success: success,
                                                        failure: failure)
    }
    
    public class func signOut() {
        LISDKAPIHelper.sharedInstance().cancelCalls()
        LISDKSessionManager.clearSession()
        LinkedInAuthenticator.sharedInstance.accessToken = nil
        LinkedInAuthenticator.sharedInstance.clearLinkedInCookies()
    }
    
    public class func openProfile(withUrl url: NSURL) {
        
    }
    
    // TODO: add method for opening profile with linkedIn id
    
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
}