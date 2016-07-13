import Foundation

public enum LinkedInErrorDomain: String, CustomStringConvertible {
    case AuthCanceled = "LinkedInKitErrorDomain.AuthCanceled"
    case RESTFailure = "LinkedInKitErrorDomain.RESTFailure"
    case SDKFailure = "LinkedInKitErrorDomain.SDKFailure"
    case SetupFailure = "LinkedInKitErrorDomain.SetupFailure"
    
    public var description: String {
        switch self {
        case .AuthCanceled:
            return "The user cancelled the sign in process."
        case .SetupFailure:
            return "The LinkedInKit is not set up properly. Please see the docs for set up instructions."
        default:
            return ""
        }
    }
    
    public var statusCode: Int {
        var code = 10000
        
        switch self {
        case .AuthCanceled:
            return code + 1
        case .RESTFailure:
            return code + 2
        case .SDKFailure:
            return code + 4
        case .SetupFailure:
            return code + 3
        default:
            return code
        }
    }
}

public class LinkedInError: NSError {
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain) -> LinkedInError {
        return LinkedInError.error(withErrorDomain: errorDomain, customDescription: nil)
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain, customDescription: String?) -> LinkedInError {
        return LinkedInError(domain: errorDomain.rawValue ,
                             code: errorDomain.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: customDescription ?? errorDomain.description])
    }
}
