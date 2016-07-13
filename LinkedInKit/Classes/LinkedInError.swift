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
    case AppPermissionDenied = "LinkedInKitErrorDomain.AppPermissionDenied"
    case NoInternetConnection = "LinkedInKitErrorDomain.NoInternetConnection"
    case ApprovedLinkedInInstall = "LinkedInKitErrorDomain.ApprovedLinkedInInstall"
    
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
            return code + 3
        case .SetupFailure:
            return code + 4
        case .AppPermissionDenied:
            return code + 5
        case .NoInternetConnection:
            return code + 6
        case .ApprovedLinkedInInstall:
            return code + 7
        default:
            return code
        }
    }
}

public class LinkedInError: NSError {
    
    class func error(withSDKError error: NSError) -> LinkedInError {
        
        let errorType = LIHTTPErrorCode(value: error.code)
        
        if errorType == .CancelationLinkedIn {
            if let errorInfo = error.userInfo["errorInfo"] as? String {
                if errorInfo == "USER_CANCELLED" {
                    return LinkedInError.error(withErrorDomain: .AppPermissionDenied)
                }
            }
            return LinkedInError.error(withErrorDomain: .AuthCanceled)
        } else if errorType == .ApprovedLinkedInInstall {
            return LinkedInError.error(withErrorDomain: .ApprovedLinkedInInstall)
        } else if errorType == .NoInternetConnection {
            return LinkedInError.error(withErrorDomain: .NoInternetConnection)
        }
        
        return error as! LinkedInError
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain) -> LinkedInError {
        return LinkedInError.error(withErrorDomain: errorDomain, customDescription: nil)
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain, customDescription: String?) -> LinkedInError {
        return LinkedInError(domain: errorDomain.rawValue ,
                             code: errorDomain.statusCode,
                             userInfo: [NSLocalizedDescriptionKey: customDescription ?? errorDomain.description])
    }
}
