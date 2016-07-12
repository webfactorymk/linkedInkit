import Foundation

public class LinkedInKit {
    
    public static var isAuthorized: Bool {
        return LinkedInAuthenticator.sharedInstance.isAuthorized
    }
    
    public static var isLinkedInAppInstalled: Bool {
        return UIApplication.sharedApplication().canOpenURL(NSURL(string: "linkedin://")!)
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
    
    public class func logout() {
        LISDKAPIHelper.sharedInstance().cancelCalls()
        LISDKSessionManager.clearSession()
        LinkedInAuthenticator.sharedInstance.accessToken = nil
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