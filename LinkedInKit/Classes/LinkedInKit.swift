import Foundation
import Alamofire

public class LinkedInKit {
    
    public static var isAuthorized: Bool {
        return LinkedInAuthenticator.sharedInstance.isAuthorized
    }
    
    public static var isLinkedInAppInstalled: Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: Constants.linkedInScheme)!)
    }
    
    public static var isTokenFromMobileSDK: Bool {
        return LinkedInAuthenticator.sharedInstance.accessToken?.isSDK ?? false
    }
    
    static public var authViewControllerDelegate: LinkedInAuthorizationViewControllerDelegate? {
        set { LinkedInRequestProvider.sharedProvider.httpClient?.viewControllerDelegate = newValue }
        get { return LinkedInRequestProvider.sharedProvider.httpClient?.viewControllerDelegate }
    }
    
    public class func setup(withConfiguration configuration: LinkedInConfiguration) {
        let httpClient = LinkedInHTTPClient(linkedInConfiguration: configuration)
        LinkedInRequestProvider.sharedProvider.httpClient = httpClient
    }
    
    public class func authenticate(success: LinkedInAuthSuccessCallback?,
                                   failure: LinkedInAuthFailureCallback?) {
        LinkedInAuthenticator.sharedInstance.authenticate(success,
                                                          failure: failure)
    }
    
    public class func requestUrl(urlString: String,
                                 method: Alamofire.Method,
                                 parameters: [String: AnyObject]?,
                                 success: LinkedInRequestSuccessCallback?,
                                 failure: LinkedInRequestFailureCallback?) {
        
        LinkedInRequestProvider.sharedProvider.apiRequestWithUrl(urlString,
                                                                 method: method,
                                                                 parameters: parameters,
                                                                 success: success,
                                                                 failure: failure)
    }
    
    public class func openProfileWithMemberId(id: String,
                                              success: ((success: Bool) -> ())?,
                                              failure: ((error: NSError) -> ())?) {
        LinkedInDeeplinkHandler.openProfileWithMemberId(id,
                                                        success: success,
                                                        failure: failure)
    }
    
    public class func signOut() {
        LISDKAPIHelper.sharedInstance().cancelCalls()
        LISDKSessionManager.clearSession()
        LinkedInAuthenticator.sharedInstance.accessToken = nil
        LinkedInAuthenticator.sharedInstance.clearLinkedInCookies()
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
}