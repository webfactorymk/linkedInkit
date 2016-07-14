import UIKit

typealias LinkedInAuthCodeSuccessCallback = (code: String) -> ()
typealias LinkedInAuthCodeCancelCallback = () -> ()

public protocol LinkedInAuthorizationViewControllerDelegate: class {
    func linkedInViewControllerNavigationBarColor() -> UIColor?
    func linkedInViewControllerTitleAttributtedString() -> NSAttributedString?
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString?
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView?
}

public extension LinkedInAuthorizationViewControllerDelegate {
    func linkedInViewControllerNavigationBarColor() -> UIColor? {
        return UIColor.whiteColor()
    }
    
    func linkedInViewControllerTitleAttributtedString() -> NSAttributedString? {
        let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedTitle = NSAttributedString(string: "Sign In", attributes: attributes)
        
        return attributedTitle
    }
    
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString? {
        let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedTitle = NSAttributedString(string: "Cancel", attributes: attributes)
        
        return attributedTitle
    }
    
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView? {
        return nil
    }
}

class LinkedInAuthorizationViewController: UIViewController {
    
    weak var delegate: LinkedInAuthorizationViewControllerDelegate?
    
    let configuration: LinkedInConfiguration
    let successCalback: LinkedInAuthCodeSuccessCallback?
    let cancelCalback: LinkedInAuthCodeCancelCallback?
    let failureCalback: LinkedInAuthFailureCallback?
    var isHandlingRedirectURL = false
    
    private let webView = UIWebView()
    private var loadingView: LinkedInLoadingView?
    
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
        
        setupViews()
        showLoadingView()
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
        let navBarColor = delegate?.linkedInViewControllerNavigationBarColor()
        navigationController?.navigationBar.barTintColor = navBarColor
        
        let label = UILabel()
        if let titleAttrString = delegate?.linkedInViewControllerTitleAttributtedString() {
            label.attributedText = titleAttrString
        } else {
            let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            label.attributedText = NSAttributedString(string: "Sign In", attributes: attributes)
        }
        label.sizeToFit()
        navigationItem.titleView = label
        
        let customButton = UIButton()
        if let cancelAttrString = delegate?.linkedInViewControllerCancelAttributtedString() {
            customButton.setAttributedTitle(cancelAttrString,
                                            forState: .Normal)
        } else {
            let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
            let attributedTitle = NSAttributedString(string: "Cancel", attributes: attributes)
            customButton.setAttributedTitle(attributedTitle,
                                            forState: .Normal)
        }
        customButton.sizeToFit()
        customButton.addTarget(self,
                               action: #selector(LinkedInAuthorizationViewController.cancelTapped),
                               forControlEvents: .TouchUpInside)
        let barButtonItem = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItems = [barButtonItem]
        
        webView.frame = CGRect(x: 0,
                               y: 0,
                               width: UIScreen.mainScreen().bounds.width,
                               height: UIScreen.mainScreen().bounds.height)
        webView.delegate = self
        webView.scalesPageToFit = true
        view.addSubview(webView)
    }
    
    func cancelTapped() {
        cancelCalback?()
    }

    func showLoadingView() {
        if loadingView == nil {
            loadingView = delegate?.linkedInViewControllerLoadingView()
            if let loadingView = loadingView {
                loadingView.frame = view.frame
                view.addSubview(loadingView)
            }
        }
        
        loadingView?.hidden = false
        loadingView?.startAnimating()
    }
    
    func hideLoadingView() {
        loadingView?.hidden = true
        loadingView?.startAnimating()
    }
}

extension LinkedInAuthorizationViewController: UIWebViewDelegate {
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let kLinkedInDeniedByUser = "user_cancelled_login"
        
        let url = request.URL!.absoluteString
        isHandlingRedirectURL = url.hasPrefix(configuration.redirectURL)
        
        if isHandlingRedirectURL {
            if let _ = url.rangeOfString("error") {
                if let _ = url.rangeOfString(kLinkedInDeniedByUser) {
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.AuthCanceled)
                    failureCalback?(error: error)
                } else {
                    let errorDescription = getParameter(withName: "error", fromURLRequest: request)
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                                    customDescription: errorDescription)
                    failureCalback?(error: error)
                }
            } else {
                if let receivedState = getParameter(withName: "state", fromURLRequest: request),
                    authorizationCode = getParameter(withName: "code", fromURLRequest: request)
                    where receivedState == configuration.state {
                    successCalback?(code: authorizationCode)
                } else {
                    let errorDescription = getParameter(withName: "error", fromURLRequest: request)
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                                    customDescription: "An error occured during the authorization code retrieval process")
                    failureCalback?(error: error)
                }
            }
        }
        
        if !isHandlingRedirectURL {
            showLoadingView()
        }
        
        return !isHandlingRedirectURL
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        hideLoadingView()
        
        if !isHandlingRedirectURL {
            cancelCalback?()
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideLoadingView()
        
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
