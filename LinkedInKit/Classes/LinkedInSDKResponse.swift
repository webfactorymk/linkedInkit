import Foundation

public class LinkedInSDKResponse: NSObject {
    
    public var statusCode: Int?
    public var jsonObject: [String: AnyObject]?
    
    public init(withData data: NSData, statusCode: Int) {
        super.init()
        self.statusCode = statusCode
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if let json = json as? [String: AnyObject] {
                self.jsonObject = json
            }
        } catch { }
    }
    
    public override init() {
        super.init()
    }
    
    init(withDictionary dictionary: [String: AnyObject]?, statusCode: Int) {
        super.init()
        
        self.statusCode = statusCode
        self.jsonObject = dictionary
    }
}