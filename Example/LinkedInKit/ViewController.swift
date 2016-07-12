import UIKit
import LinkedInKit

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
            
            }, failure: { (error) in
                
        })
    }
}
