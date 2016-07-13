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
        if !LinkedInKit.isAuthorized {
            button.setTitle("Sign In", forState: .Normal)
        } else {
            
            button.setTitle("Sign Out", forState: .Normal)
        }
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.onButton), forControlEvents: .TouchUpInside)
        view.addSubview(button)
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
                    success: { (response) in
                        print("Success")
                        
                    }, failure: { (error) in
                      
                })
            }) { error in
                
            }
        } else {
            LinkedInKit.signOut()
            button.setTitle("Sign In", forState: .Normal)
        }
    }
}
