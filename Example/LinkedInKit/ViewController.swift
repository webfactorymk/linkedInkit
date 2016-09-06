import UIKit
import LinkedInKit

typealias LinkedInAuthCallback = (success: Bool, user: [String: AnyObject]?, error: NSError?) -> ()

let baseUrl = "https://api.linkedin.com/v1/people/~"
let profileInfo = "id,formatted-name,email-address,public-profile-url"
let pictureParams = "picture-url,picture-urls::(original)"
let locationParams = "location:(country:(code))"
let companyParams = "positions:(title,company:(name))"
let summaryParams = "summary"
let formatParams = "format=json"

let linkedInProfileUrl = "\(baseUrl):(\(profileInfo),\(pictureParams),\(locationParams),\(companyParams),\(summaryParams))?\(formatParams)"

class ViewController: UIViewController {
    
    let profileView = ProfileView()
    var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applicationDidBecomeActive() {
        if !LinkedInKit.isAuthorized {
            signOut()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupViews() {
        let defaultOffset: CGFloat = 10.0
        let mainScreenBounds = UIScreen.mainScreen().bounds
        
        profileView.frame = CGRect(x: 0, y: 20.0, width: mainScreenBounds.width, height: 200.0)
        view.addSubview(profileView)
        
        let frame = CGRect(x: defaultOffset,
                           y: mainScreenBounds.height - 40 - defaultOffset,
                           width: mainScreenBounds.width - 2 * defaultOffset,
                           height: 40.0)
        button = UIButton(frame: frame)
        
        if !LinkedInKit.isAuthorized {
            button.setTitle("Sign In", forState: .Normal)
            profileView.hidden = true
        } else {
            getUserProfile()
            button.setTitle("Sign Out", forState: .Normal)
        }
        
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        button.addTarget(self, action: #selector(ViewController.onButton),  forControlEvents: .TouchUpInside)
        
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
                
                self?.getUserProfile()
            }) { error in
            }
        } else {
            signOut()
        }
    }
    
    func signOut() {
        LinkedInKit.signOut()
        profileView.hidden = true
        button.setTitle("Sign In", forState: .Normal)
    }
    
    func getUserProfile() {
        LinkedInKit.requestUrl(linkedInProfileUrl,
                               method: .GET,
                               parameters: nil,
                               success: { [weak self] (response) in
                                if let json = response?.jsonObject {
                                    print(json)
                                    let name = json["formattedName"] as? String
                                    var jobTitle: String? = ""
                                    var profileImageURL: String?
                                    
                                    if let positionJson = json["positions"] as? [String: AnyObject] {
                                        if let positionsArray = positionJson["values"] as? [[String: AnyObject]] {
                                            let mostRecentPosition = positionsArray[0]
                                            jobTitle = mostRecentPosition["title"] as? String
                                        }
                                    }
                                    
                                    if let pictureURLs = json["pictureUrls"],
                                        values = pictureURLs["values"] as? [String] {
                                        profileImageURL = values[0]
                                    }
                                    
                                    self?.profileView.updateInfoWith(name: name,
                                        position: jobTitle,
                                        profileImageURL: profileImageURL)
                                    self?.profileView.hidden = false
                                }
            }, failure: { [weak self] error in
                self?.profileView.hidden = true
        })
    }
}
