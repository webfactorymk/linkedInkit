import Foundation

open class LinkedInSDKResponse: NSObject {
    
    open var statusCode: Int?
    open var jsonObject: [String: AnyObject]?
    
    public init(withData data: Data, statusCode: Int) {
        super.init()
        self.statusCode = statusCode
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
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
