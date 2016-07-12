import Foundation
import LinkedInKit

class DesignManager: NSObject, LinkedInAuthorizationViewControllerDelegate {
    
    static let sharedManager = DesignManager()
    
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView? {
        return CustomLoadingView()
    }
}
