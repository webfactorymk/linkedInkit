import UIKit
import LinkedInKit

class ViewController: UIViewController {
    
    var authenticator: LinkedInAuthenticator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let configuration = LinkedInConfiguration(withClientID: "77zcp4j2f9sver", clientSecret: "svXOeAMVjqfvyvM7", state: "qwertyuiop", permissions: ["r_basicprofile","r_emailaddress"], redirectURL: "http://www.macedonia2025.com", appID: "4428373")
        let client = LinkedInHTTPClient(linkedInConfiguration: configuration, presentingViewController: self)
        client.viewControllerDelegate = self
        
        authenticator = LinkedInAuthenticator(configuration: configuration, httpClient: client)
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
        authenticator?.authenticate({ (token) in
            
            }, failure: { (error) in
                
        })
    }
}
