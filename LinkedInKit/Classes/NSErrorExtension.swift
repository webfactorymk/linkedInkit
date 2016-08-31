import Foundation

enum LIHTTPErrorCode: Int {
    case NoInternetConnection = 2
    case CancelationLinkedIn = 3
    case ApprovedLinkedInInstall = 6
    case Unauthorized = 401
    case Unknown = -1
    
    init(value: Int) {
        let codes = [2, 3, 6, 401]
        if codes.contains(value) {
            self = LIHTTPErrorCode(rawValue: value)!
        } else {
            self = .Unknown
        }
    }
}

public enum LinkedInErrorDomain: String, CustomStringConvertible {
    case AuthCanceled = "LinkedInKitErrorDomain.AuthCanceled"
    case RESTFailure = "LinkedInKitErrorDomain.RESTFailure"
    case SDKFailure = "LinkedInKitErrorDomain.SDKFailure"
    case SetupFailure = "LinkedInKitErrorDomain.SetupFailure"
    case ParseFailure = "LinkedInKitErrorDomain.ParseFailure"
    case AppPermissionDenied = "LinkedInKitErrorDomain.AppPermissionDenied"
    case NoInternetConnection = "LinkedInKitErrorDomain.NoInternetConnection"
    case ApprovedLinkedInInstall = "LinkedInKitErrorDomain.ApprovedLinkedInInstall"
    case NotAuthenticated = "LinkedInKitErrorDomain.NotAuthenticated"
    case Default = "LinkedInKitErrorDomain.Default"
    
    public var description: String {
        switch self {
        case .AuthCanceled:
            return "The user cancelled the sign in process."
        case .SetupFailure:
            return "The LinkedInKit is not set up properly. Please see the docs for set up instructions."
        case .NotAuthenticated:
            return "The user is not signed in"
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
            return code + 3
        case .SetupFailure:
            return code + 4
        case .ParseFailure:
            return code + 5
        case .AppPermissionDenied:
            return code + 6
        case .NoInternetConnection:
            return code + 7
        case .ApprovedLinkedInInstall:
            return code + 8
        case .NotAuthenticated:
            return code + 9
        default:
            return code
        }
    }
}

public extension NSError {
    
    public var customDomain: LinkedInErrorDomain {
        if let tempDomain = LinkedInErrorDomain(rawValue: self.domain) {
            return tempDomain
        }
        return .Default
    }
    
    class func error(withLIError error: NSError) -> NSError {
        
        let errorType = LIHTTPErrorCode(value: error.code)
        
        if errorType == .CancelationLinkedIn {
            if let errorInfo = error.userInfo["errorInfo"] as? String {
                if errorInfo == "USER_CANCELLED" {
                    return NSError.error(withErrorDomain: .AppPermissionDenied)
                }
            }
            return NSError.error(withErrorDomain: .AuthCanceled)
        } else if errorType == .ApprovedLinkedInInstall {
            return NSError.error(withErrorDomain: .ApprovedLinkedInInstall)
        } else if errorType == .NoInternetConnection {
            return NSError.error(withErrorDomain: .NoInternetConnection)
        } else if let  networkErrorCode = CFNetworkErrors(rawValue: Int32(error.code))
            where networkErrorCode == CFNetworkErrors.CFURLErrorNotConnectedToInternet {
            return NSError.error(withErrorDomain: .NoInternetConnection)
        }
        
        return error
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain) -> NSError {
        return NSError.error(withErrorDomain: errorDomain, customDescription: nil)
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain, customDescription: String?) -> NSError {
        return NSError(domain: errorDomain.rawValue ,
                             code: errorDomain.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: customDescription ?? errorDomain.description])
    }
}
