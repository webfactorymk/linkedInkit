import Foundation

public class LinkedInAccessToken: NSObject, NSCoding {

    private static let AccessTokenKey = "WF.LinkedIn.accessTokenKey"
    private static let ExpireDateKey = "WF.LinkedIn.expireDateKey"
    private static let IsMobileSDKKey = "WF.LinkedIn.mobileSDKKey"
    
    var accessToken: String?
    var expireDate: NSDate?
    var isSDK: Bool?
    
    init(withAccessToken accessToken: String?, expireDate: NSDate?, isSDK: Bool?) {
        super.init()
        
        self.accessToken = accessToken
        self.expireDate = expireDate
        self.isSDK = isSDK
    }
    
    required public init?(coder aDecoder: NSCoder) {
        accessToken = aDecoder.decodeObjectForKey(LinkedInAccessToken.AccessTokenKey) as? String
        expireDate = aDecoder.decodeObjectForKey(LinkedInAccessToken.ExpireDateKey) as? NSDate
        isSDK = aDecoder.decodeObjectForKey(LinkedInAccessToken.IsMobileSDKKey) as? Bool
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessToken, forKey: LinkedInAccessToken.AccessTokenKey)
        aCoder.encodeObject(expireDate, forKey: LinkedInAccessToken.ExpireDateKey)
        aCoder.encodeObject(isSDK, forKey: LinkedInAccessToken.IsMobileSDKKey)
    }
}
