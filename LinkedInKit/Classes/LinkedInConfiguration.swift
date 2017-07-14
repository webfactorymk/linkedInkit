import Foundation

public class LinkedInConfiguration: NSObject {
    
    var clientID: String
    var clientSecret: String
    var state: String
    var permissions: [String]?
    var redirectURL: String
    var appID: String
    
    public init(withClientID clientID: String,
                      clientSecret: String,
                      state: String,
                      permissions: [String]?,
                      redirectURL: String,
                      appID: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.state = state
        self.permissions = permissions
        self.redirectURL = redirectURL
        self.appID = appID
        
        super.init()
    }
    
    func formattedPermissions() -> String? {
        return permissions?.joinWithSeparator(" ")
            .stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) ?? ""
    }
}