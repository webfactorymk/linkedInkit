import Foundation

class LinkedInDeeplinkHandler {
    
    class func openProfileWithMemberId(id: String,
                                       success: ((success: Bool) -> ())?,
                                       failure: ((error: NSError) -> ())?) {
        if LinkedInAuthenticator.sharedInstance.isAuthorized {
            if LinkedInKit.isTokenFromMobileSDK {
                sdk_openProfileWithMemberId(id, success: success, failure: failure)
            } else {
                rest_openProfileWithMemberId(id, success: success, failure: failure)
            }
        } else {
            failure?(error: NSError.error(withErrorDomain: .NotAuthenticated))
        }
    }
    
    private class func sdk_openProfileWithMemberId(id: String,
                                                   success: ((success: Bool) -> ())?,
                                                   failure: ((error: NSError) -> ())?) {
        let customState = "openProfileWithMemberId"
        LISDKDeeplinkHelper.sharedInstance().viewOtherProfile(
            id,
            withState: customState,
            showGoToAppStoreDialog: false,
            success: { (state) in
                success?(success: state == customState)
            }, error: { (error, state) in
                failure?(error: error)
        })
    }
    
    private class func rest_openProfileWithMemberId(id: String,
                                                    success: ((success: Bool) -> ())?,
                                                    failure: ((error: NSError) -> ())?) {
        let route = NSString(format: ApiRoutes.profileDetailsRoute, id)
        
        // Get user details in order to acquire linkedIn profile url
        LinkedInRequestProvider.sharedProvider.apiRequestWithUrl(
            route as String,
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
}