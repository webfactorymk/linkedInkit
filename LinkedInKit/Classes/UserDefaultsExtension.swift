import Foundation

extension NSUserDefaults {
    
    private static let linkedInTokenKey = "wf.linkedInKit.accessTokenKey"
    
    class func saveApiToken(token: LinkedInAccessToken?) {
        if let token = token {
            standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(token),
                                             forKey: linkedInTokenKey)
        } else {
            standardUserDefaults().removeObjectForKey(linkedInTokenKey)
        }
        standardUserDefaults().synchronize()
    }
    
    class func getApiToken() -> LinkedInAccessToken? {
        if let data = standardUserDefaults().objectForKey(linkedInTokenKey) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? LinkedInAccessToken
        }
        return nil
    }
}