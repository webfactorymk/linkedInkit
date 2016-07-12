import UIKit

public protocol LinkedInLoadingViewProtocol {
    func startAnimating()
    func stopAnimating()
}

public class LinkedInLoadingView: UIView, LinkedInLoadingViewProtocol {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Override this methods
    public func startAnimating() { }

    public func stopAnimating() { }
}
