import Foundation

struct Constants {
    static let linkedInScheme = "linkedin://"
    static let linkedInDomain = "linkedin"
    
    struct Parameters {
        static let error = "error"
        static let errorInfo = "erroInfo"
        static let state = "state"
        static let code = "code"
        
        static let accessToken = "access_token"
        static let expiresIn = "expires_in"
    }
    
    struct HttpHeaderKeys {
        static let authorization = "Authorization"
        static let format = "x-li-format"
        static let contentType = "Content-Type"
    }
    
    struct HttpHeaderValues {
        static let authorization = "Bearer %@"
        static let format = "json"
        static let contentType = "application/json"
    }
    
    struct ErrorReasons {
        static let userCancelled = "USER_CANCELLED"
        static let loginCancelled = "user_cancelled_login"
    }
}

struct CustomErrorDescription {
    static let authCancelledError = "The user cancelled the sign in process"
    static let kitSetupFailureError = "The LinkedInKit is not set up properly. Please see the docs for set up instructions."
    static let notSignedInError = "The user is not signed in"
    static let authFailureError = "An error occured during the authorization code retrieval process"
}

struct ApiRoutes {
    static let authorizationRoute = "https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=%@&state=%@&redirect_uri=%@&scope=%@"
    static let accessTokenRoute = "http://www.linkedin.com/oauth/v2/accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@"
}

let iPadWebjs = "var meta = document.createElement('meta'); meta.setAttribute( 'name', 'viewport' ); meta.setAttribute( 'content', 'width = 540px, initial-scale = 1.0, user-scalable = yes' ); document.getElementsByTagName('head')[0].appendChild(meta)"