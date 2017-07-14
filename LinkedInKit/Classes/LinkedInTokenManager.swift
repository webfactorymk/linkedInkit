import Foundation

class LinkedInTokenManager {
    
    static let sharedManager = LinkedInTokenManager()
    
    private var storedToken: LinkedInAccessToken?
    
    var accessToken: LinkedInAccessToken? {
        set {
            storedToken = newValue
            NSUserDefaults.lik_saveLinkedInAccessToken(newValue)
        }
        get {
            if let _ = storedToken { return storedToken }
            storedToken = NSUserDefaults.lik_getLinkedInAccessToken()
            return storedToken
        }
    }
    
    var hasValidAccessToken: Bool {
        var isConsistent = true
        if let accessToken = accessToken where accessToken.isSDK == true {
            isConsistent = LinkedInKit.isLinkedInAppInstalled
        }
        
        return accessToken != nil && accessToken?.expireDate > NSDate() && isConsistent
    }
    
    var isAuthorized: Bool {
        if let accessToken = accessToken where accessToken.isSDK == true {
            return hasValidAccessToken && LISDKSessionManager.sharedInstance().session.isValid()
        }
        
        return hasValidAccessToken
    }
}