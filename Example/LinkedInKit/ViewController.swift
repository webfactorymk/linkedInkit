import UIKit
import LinkedInKit

let baseUrl = "https://api.linkedin.com/v1/people/~"
let profileInfo = "id,formatted-name,email-address,public-profile-url"
let pictureParams = "picture-url,picture-urls::(original)"
let locationParams = "location:(country:(code))"
let companyParams = "positions:(title,company:(name))"
let summaryParams = "summary"
let formatParams = "format=json"

let linkedInProfileUrl = "\(baseUrl):(\(profileInfo),\(pictureParams),\(locationParams),\(companyParams),\(summaryParams))?\(formatParams)"

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func setupViews() {
        
        let mainScreen = UIScreen.mainScreen().bounds
        let frame = CGRect(x: (mainScreen.width - 100) / 2,
                           y: (mainScreen.height - 40) / 2,
                           width: 100.0,
                           height: 40.0)
        let button = UIButton(frame: frame)
        button.setTitle("Sign In", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.onSignIn), forControlEvents: .TouchUpInside)
        view.addSubview(button)
    }
    
    func onSignIn() {
        LinkedInKit.authenticate({ (token) in
            
            LinkedInKit.requestUrl(linkedInProfileUrl,
                success: { (response) in
                    
                    print("sadfasdf")
//                    crashlytics_log("response data: \(response?.jsonObject)")
//                    
//                    if let json = response?.jsonObject {
//                        let linkedInUser = CurrentUser(parsedObject: LinkedInParser(parameters: json))
//                        completion?(success: true, user: linkedInUser, error: nil)
//                    } else {
//                        completion?(success: true, user: nil, error: nil)
//                    }
                    
                }, failure: { (error) in
                    print("asdfasd")
                    
                    
//                    if let code = error?.code where LIHTTPErrorCode(rawValue: code) == .Unauthorized {
//                        UserManager.sharedManager.updateCurrentUser(nil)
//                    } else if let description = error?.description {
//                        AlertFactory.showOkAlert(description)
//                    }
//                    completion?(success: false, user: nil, error: error)
            })
            
            }, failure: { (error) in
                print(error?.localizedDescription)
        })
    }
}
