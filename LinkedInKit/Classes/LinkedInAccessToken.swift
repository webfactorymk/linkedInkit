import Foundation

open class LinkedInAccessToken: NSObject, NSCoding {

    fileprivate static let AccessTokenKey = "WF.LinkedIn.accessTokenKey"
    fileprivate static let ExpireDateKey = "WF.LinkedIn.expireDateKey"
    fileprivate static let IsMobileSDKKey = "WF.LinkedIn.mobileSDKKey"
    
    open var accessToken: String?
    open var expireDate: Date?
    open var isSDK: Bool?
    
    init(withAccessToken accessToken: String?, expireDate: Date?, isSDK: Bool?) {
        super.init()
        
        self.accessToken = accessToken
        self.expireDate = expireDate
        self.isSDK = isSDK
    }
    
    required public init?(coder aDecoder: NSCoder) {
        accessToken = aDecoder.decodeObject(forKey: LinkedInAccessToken.AccessTokenKey) as? String
        expireDate = aDecoder.decodeObject(forKey: LinkedInAccessToken.ExpireDateKey) as? Date
        isSDK = aDecoder.decodeObject(forKey: LinkedInAccessToken.IsMobileSDKKey) as? Bool
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: LinkedInAccessToken.AccessTokenKey)
        aCoder.encode(expireDate, forKey: LinkedInAccessToken.ExpireDateKey)
        aCoder.encode(isSDK, forKey: LinkedInAccessToken.IsMobileSDKKey)
    }
}
