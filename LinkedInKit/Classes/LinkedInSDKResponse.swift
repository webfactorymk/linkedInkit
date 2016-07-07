import Foundation

class LinkedInSDKResponse: NSObject {
    
    var statusCode: Int?
    var jsonObject: [String: AnyObject]?
    
    init(withData data: NSData, statusCode: Int) {
        super.init()
        self.statusCode = statusCode
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            if let json = json as? [String: AnyObject] {
                self.jsonObject = json
            }
        } catch { }
    }
    
    init(withDictionary dictionary: [String: AnyObject]?, statusCode: Int) {
        super.init()
        self.statusCode = statusCode
        self.jsonObject = dictionary
    }
}