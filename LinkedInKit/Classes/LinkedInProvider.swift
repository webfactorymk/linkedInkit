import Foundation
import Alamofire

public typealias LinkedInRequestSuccessCallback = (response: LinkedInSDKResponse?) -> ()
public typealias LinkedInRequestFailureCallback = (error: NSError?) -> ()

protocol LinkedInProvider {
        
    func signIn(success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?)
    
    func requestUrl(urlString: String,
                    method: Alamofire.Method,
                    parameters: [String: AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?)
    
    func openProfileWithMemberId(id: String,
                                 success: ((success: Bool) -> ())?,
                                 failure: ((error: NSError) -> ())?)
    
    func signOut()
}