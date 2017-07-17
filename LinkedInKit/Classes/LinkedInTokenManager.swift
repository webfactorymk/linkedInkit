class LinkedInTokenManager {
    
    static let sharedManager = LinkedInTokenManager()
    
    fileprivate var storedToken: LinkedInAccessToken?
    
    var accessToken: LinkedInAccessToken? {
        set {
            storedToken = newValue
            UserDefaults.lik_saveLinkedInAccessToken(newValue)
        }
        get {
            if let _ = storedToken { return storedToken }
            storedToken = UserDefaults.lik_getLinkedInAccessToken()
            return storedToken
        }
    }
    
    var hasValidAccessToken: Bool {
        var isConsistent = true
        if let accessToken = accessToken, accessToken.isSDK == true {
            isConsistent = LinkedInKit.isLinkedInAppInstalled
        }
        
        if let accessToken = accessToken,
            let expireDate = accessToken.expireDate {
            return expireDate > Date() && isConsistent
        }
        return false
    }
    
    var isAuthorized: Bool {
        if let accessToken = accessToken, accessToken.isSDK == true {
            return hasValidAccessToken && LISDKSessionManager.sharedInstance().session.isValid()
        }
        
        return hasValidAccessToken
    }
}

