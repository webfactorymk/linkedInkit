import Foundation
import Alamofire

class LinkedInRequestProvider {
    
    static let sharedProvider = LinkedInRequestProvider()
    
    var httpClient: LinkedInHTTPClient?
    
    func apiRequestWithUrl(url: String,
                           method: Alamofire.Method,
                           parameters: [String: AnyObject]?,
                           success: LinkedInRequestSuccessCallback?,
                           failure: LinkedInRequestFailureCallback?) {
        
        if LinkedInAuthenticator.sharedInstance.hasValidAccessToken {
            if LinkedInKit.isTokenFromMobileSDK {
                sdkRequest(url, method: method, parameters: parameters, success: success, failure: failure)
            } else {
                restRequest(url, method: method, parameters: parameters, success: success, failure: failure)
            }
        } else {
            failure?(error: NSError.error(withErrorDomain: LinkedInErrorDomain.NotAuthenticated))
        }
    }
    
    private func sdkRequest(url: String,
                            method: Alamofire.Method,
                            parameters: [String: AnyObject]?,
                            success: LinkedInRequestSuccessCallback?,
                            failure: LinkedInRequestFailureCallback?) {
        
        var requestBody: NSData?
        var requestUrlString = url
        
        if let parameters = parameters where (method == .POST || method == .PUT) {
            // add params as request body
            do {
                requestBody = try NSJSONSerialization.dataWithJSONObject(parameters,
                                                                         options: NSJSONWritingOptions.PrettyPrinted)
            } catch { }
        } else {
            // append params to url
            if let requestURL = NSURL(string: url), parameters = parameters {
                let urlComponents = NSURLComponents(URL: requestURL, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = urlComponents?.queryItems ?? [NSURLQueryItem]()
                for item in parameters {
                    if let value = item.1 as? String {
                        let queryItem = NSURLQueryItem(name: item.0, value: value)
                        urlComponents?.queryItems?.append(queryItem)
                    }
                }
                requestUrlString = String(requestURL)
            }
        }
        
        LISDKAPIHelper.sharedInstance().apiRequest(
            requestUrlString,
            method: method.rawValue,
            body: requestBody,
            success: { (response) in
                
                if let dataFromString = response.data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    success?(response: LinkedInSDKResponse(withData: dataFromString,
                        statusCode: Int(response.statusCode)))
                } else {
                    success?(response: nil)
                }
            }, error: { (error) in
                failure?(error: NSError.error(withLIError: error))
        })
    }
    
    private func restRequest(url: String,
                             method: Alamofire.Method,
                             parameters: [String: AnyObject]?,
                             success: LinkedInRequestSuccessCallback?,
                             failure: LinkedInRequestFailureCallback?) {
        let token = LinkedInAuthenticator.sharedInstance.accessToken!.accessToken!
        let headers = [Constants.HttpHeaderKeys.authorization: NSString(format: Constants.HttpHeaderValues.authorization, token) as String,
                       Constants.HttpHeaderKeys.format: Constants.HttpHeaderValues.format,
                       Constants.HttpHeaderKeys.contentType: Constants.HttpHeaderValues.contentType]
        let encoding = (method == .GET) ? Alamofire.ParameterEncoding.URL : Alamofire.ParameterEncoding.JSON
        
        let request = httpClient?.request(
            method,
            url,
            parameters: parameters,
            encoding: encoding,
            headers: headers).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .Success(let JSON):
                    let sdkResponse = LinkedInSDKResponse()
                    sdkResponse.jsonObject = JSON as! [String : AnyObject]
                    sdkResponse.statusCode = 200
                    
                    success?(response: sdkResponse)
                case .Failure(let error):
                    failure?(error: NSError.error(withLIError: error))
                }
            })
    }
}