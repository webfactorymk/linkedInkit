import Foundation
import Alamofire

public typealias LinkedInRequestSuccessCallback = (_ response: LinkedInSDKResponse?) -> ()
public typealias LinkedInRequestFailureCallback = (_ error: NSError?) -> ()

protocol LinkedInProvider {
    func signIn(_ success: LinkedInAuthSuccessCallback?,
                failure: LinkedInAuthFailureCallback?)
    func requestUrl(_ urlString: String,
                    method: Alamofire.HTTPMethod,
                    parameters: [String: AnyObject]?,
                    success: LinkedInRequestSuccessCallback?,
                    failure: LinkedInRequestFailureCallback?)
    func openProfileWithMemberId(_ id: String,
                                 success: ((_ success: Bool) -> ())?,
                                 failure: ((_ error: NSError) -> ())?)
    func signOut()
}
