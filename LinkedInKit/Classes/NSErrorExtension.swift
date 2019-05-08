import Foundation

enum LIHTTPErrorCode: Int {
    case noInternetConnection = 2
    case cancelationLinkedIn = 3
    case approvedLinkedInInstall = 6
    case unauthorized = 401
    case unknown = -1
    
    init(value: Int) {
        let codes = [2, 3, 6, 401]
        if codes.contains(value) {
            self = LIHTTPErrorCode(rawValue: value)!
        } else {
            self = .unknown
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
            return CustomErrorDescription.authCancelledError
        case .SetupFailure:
            return CustomErrorDescription.kitSetupFailureError
        case .NotAuthenticated:
            return CustomErrorDescription.notSignedInError
        default:
            return ""
        }
    }
    
    public var statusCode: Int {
        let code = 10000
        
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
    
    var customDomain: LinkedInErrorDomain {
        if let tempDomain = LinkedInErrorDomain(rawValue: self.domain) {
            return tempDomain
        }
        return .Default
    }
    
    class func error(withLIError error: NSError) -> NSError {
        
        let errorType = LIHTTPErrorCode(value: error.code)
        
        if errorType == .cancelationLinkedIn {
            if let errorInfo = error.userInfo[Constants.Parameters.errorInfo] as? String {
                if errorInfo == Constants.ErrorReasons.userCancelled {
                    return NSError.error(withErrorDomain: .AppPermissionDenied)
                }
            }
            return NSError.error(withErrorDomain: .AuthCanceled)
        } else if errorType == .approvedLinkedInInstall {
            return NSError.error(withErrorDomain: .ApprovedLinkedInInstall)
        } else if errorType == .noInternetConnection {
            return NSError.error(withErrorDomain: .NoInternetConnection)
        } else if let  networkErrorCode = CFNetworkErrors(rawValue: Int32(error.code)), networkErrorCode == CFNetworkErrors.cfurlErrorNotConnectedToInternet {
            return NSError.error(withErrorDomain: .NoInternetConnection)
        }
        return error
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain) -> NSError {
        return NSError.error(withErrorDomain: errorDomain, customDescription: nil)
    }
    
    class func error(withErrorDomain errorDomain: LinkedInErrorDomain,
                                     customDescription: String?) -> NSError {
        return NSError(domain: errorDomain.rawValue ,
                       code: errorDomain.statusCode,
                       userInfo: [NSLocalizedDescriptionKey: customDescription ?? errorDomain.description])
    }
}
