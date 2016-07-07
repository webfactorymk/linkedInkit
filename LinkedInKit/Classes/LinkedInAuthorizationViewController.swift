import UIKit

typealias LinkedInAuthCodeSuccessCallback = (code: String) -> ()
typealias LinkedInAuthCodeCancelCallback = () -> ()

protocol LinkedInAuthorizationViewControllerDelegate: class {
    func linkedInViewControllerNavigationBarColors() -> (background: UIColor?, foreground: UIColor?)
    func linkedInViewControllerNavigationBarFonts() -> (titleFont: UIFont?, buttonFont: UIFont?)
    func linkedInViewControllerNavigationBarTitles() -> (mainTitle: String?, buttonTitle: String?)
}

class LinkedInAuthorizationViewController: UIViewController {
    
    weak var delegate: LinkedInAuthorizationViewControllerDelegate?
    
    let configuration: LinkedInConfiguration
    let successCalback: LinkedInAuthCodeSuccessCallback?
    let cancelCalback: LinkedInAuthCodeCancelCallback?
    let failureCalback: LinkedInAuthFailureCallback?
    var isHandlingRedirectURL = false
    
    private let webView = UIWebView()
    
    init(configuration: LinkedInConfiguration,
         successCalback: LinkedInAuthCodeSuccessCallback?,
         cancelCalback: LinkedInAuthCodeCancelCallback?,
         failureCalback: LinkedInAuthFailureCallback?) {
        
        self.configuration = configuration
        self.successCalback = successCalback
        self.cancelCalback = cancelCalback
        self.failureCalback = failureCalback
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        clearLinkedInCookies()
        
        setupViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let redirectURL = configuration.redirectURL.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        var urlString = "https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=\(configuration.clientID)&state=\(configuration.state)&redirect_uri=\(redirectURL!)"
        
        if let permissions = configuration.formattedPermissions() {
            urlString.appendContentsOf("&scope=\(permissions)")
        }
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString)!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0))
    }
    
    func setupViews() {
        let navBarColors = delegate?.linkedInViewControllerNavigationBarColors()
        let navBarTitles = delegate?.linkedInViewControllerNavigationBarTitles()
        let navBarFonts = delegate?.linkedInViewControllerNavigationBarFonts()
        
        title = navBarTitles?.mainTitle ?? "Sign In"
        navigationController?.navigationBar.barTintColor = navBarColors?.background
        if let titleFont = navBarFonts?.titleFont {
            navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: titleFont]
        }
        if let titleColor = navBarColors?.foreground {
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        }
        
        webView.frame = CGRect(x: 0,
                               y: 0,
                               width: UIScreen.mainScreen().bounds.width,
                               height: UIScreen.mainScreen().bounds.height)
        webView.delegate = self
        webView.scalesPageToFit = true
        view.addSubview(webView)
        
        let customButton = UIButton()
        customButton.setTitle(navBarTitles?.buttonTitle ?? "Cancel", forState: .Normal)
        customButton.setTitleColor(navBarColors?.foreground ?? UIColor.blackColor(), forState: .Normal)
        customButton.titleLabel?.font = navBarFonts?.buttonFont
        customButton.addTarget(self,
                               action: #selector(LinkedInAuthorizationViewController.cancelTapped),
                               forControlEvents: .TouchUpInside)
        customButton.sizeToFit()
        let barButtonItem = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItems = [barButtonItem]
    }
    
    func cancelTapped() {
        cancelCalback?()
    }
    
    func clearLinkedInCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                if cookie.domain.containsString("linkedin") {
                    storage.deleteCookie(cookie)
                }
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

extension LinkedInAuthorizationViewController: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let kLinkedInErrorDomain = "LinkedInError"
        let kLinkedInDeniedByUser = "user_cancelled_login"
        
        let url = request.URL!.absoluteString
        isHandlingRedirectURL = url.hasPrefix(configuration.redirectURL)
        
        if isHandlingRedirectURL {
            if let _ = url.rangeOfString("error") {
                if let _ = url.rangeOfString(kLinkedInDeniedByUser) {
                    cancelCalback?()
                } else {
                    //Send a more descriptive error
                    failureCalback?(error: NSError(domain: kLinkedInErrorDomain, code: 1, userInfo: nil))
                }
            } else {
                if let receivedState = getParameter(withName: "state", fromURLRequest: request),
                    authorizationCode = getParameter(withName: "code", fromURLRequest: request)
                    where receivedState == configuration.state {
                    successCalback?(code: authorizationCode)
                } else {
                    //Send a more descriptive error
                    failureCalback?(error: NSError(domain: kLinkedInErrorDomain, code: 2, userInfo: nil))
                }
            }
        }
        
        return !isHandlingRedirectURL
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if !isHandlingRedirectURL {
            cancelCalback?()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //Test this out on an iPad
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            let js = "var meta = document.createElement('meta'); "
            "meta.setAttribute( 'name', 'viewport' ); "
            "meta.setAttribute( 'content', 'width = 540px, initial-scale = 1.0, user-scalable = yes' ); "
            "document.getElementsByTagName('head')[0].appendChild(meta)"
            
            webView.stringByEvaluatingJavaScriptFromString(js)
        }
    }
    
    func getParameter(withName name: String, fromURLRequest request: NSURLRequest) -> String? {
        let urlComponents = NSURLComponents(URL: request.URL!,
                                            resolvingAgainstBaseURL: false)
        for item in (urlComponents?.queryItems)! {
            if item.name == name {
                return item.value
            }
        }
        
        return nil
    }
}
