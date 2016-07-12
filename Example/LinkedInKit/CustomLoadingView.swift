import UIKit
import LinkedInKit

class CustomLoadingView: LinkedInLoadingView {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let screenFrame = UIScreen.mainScreen().bounds
        activityIndicator.frame = CGRect(x: (screenFrame.width - 100)/2,
                                         y: (screenFrame.height - 100)/2,
                                         width: 100,
                                         height: 100)
        addSubview(activityIndicator)
    }
    
    override func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    override func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
