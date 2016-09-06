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
    
    var button: UIButton!
    var shareButton: UIButton!
    
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
        button = UIButton(frame: frame)
        shareButton = UIButton(frame: CGRectMake(frame.origin.x, frame.origin.y + 50, frame.width, frame.height))
        
        if !LinkedInKit.isAuthorized {
            button.setTitle("Sign In", forState: .Normal)
        } else {
            button.setTitle("Sign Out", forState: .Normal)
        }
        
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.onButton),  forControlEvents: .TouchUpInside)
        
        shareButton.setTitle("Share", forState: .Normal)
        shareButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        shareButton.addTarget(self, action: #selector(ViewController.onShareButton), forControlEvents: .TouchUpInside)
        
        view.addSubview(button)
        view.addSubview(shareButton)
    }
    
    func onButton() {
        if !LinkedInKit.isAuthorized {
            LinkedInKit.authenticate({ [weak self] (token) in
                if !LinkedInKit.isAuthorized {
                    self?.button.setTitle("Sign In", forState: .Normal)
                } else {
                    self?.button.setTitle("Sign Out", forState: .Normal)
                }
                
                LinkedInKit.requestUrl(linkedInProfileUrl,
                    method: .GET,
                    parameters: nil,
                    success: { (response) in
                        print("Success")
                    }, failure: nil)
            }) { error in
                
            }
        } else {
            LinkedInKit.signOut()
            button.setTitle("Sign In", forState: .Normal)
        }
    }
    
    func onShareButton() {
        let testParameters = ["comment": "ds fsdf gdfgfdg fs",
                              "content": ["title": "LinkedIn Developers Resources",
                                "description": "Leverage LinkedIn's APIs to maximize engagement",
                                "submitted-url": "https://developer.linkedin.com",
                                "submitted-image-url": "https://example.com/logo.png"],
                              "visibility": ["code": "anyone"]]
        
        LinkedInKit.requestUrl("https://api.linkedin.com/v1/people/~/shares?format=json",
                               method: .POST,
                               parameters: testParameters,
                               success: { (response) in
                                UIAlertView(title: nil, message: String(response?.jsonObject), delegate: nil, cancelButtonTitle: "Ok").show()
                                print(response?.jsonObject)
            }, failure: { (error) in
                UIAlertView(title: nil, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
        })
    }
}
