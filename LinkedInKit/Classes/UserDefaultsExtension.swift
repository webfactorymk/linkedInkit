import Foundation

extension UserDefaults {
    
    fileprivate static let linkedInTokenKey = "wf.linkedInKit.accessTokenKey"
    
    class func lik_saveLinkedInAccessToken(_ token: LinkedInAccessToken?) {
        if let token = token {
            standard.set(NSKeyedArchiver.archivedData(withRootObject: token),
                                             forKey: linkedInTokenKey)
        } else {
            standard.removeObject(forKey: linkedInTokenKey)
        }
        standard.synchronize()
    }
    
    class func lik_getLinkedInAccessToken() -> LinkedInAccessToken? {
        if let data = standard.object(forKey: linkedInTokenKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? LinkedInAccessToken
        }
        
        return nil
    }
}
