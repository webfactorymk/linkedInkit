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
        return NSAttributedString(string: "Sign In", attributes: attributes)
    }
    
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString? {
        let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        return NSAttributedString(string: "Cancel", attributes: attributes)
    }
    
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView? {
        return nil
    }
}

class LinkedInAuthorizationViewController: UIViewController {
    
    weak var delegate: LinkedInAuthorizationViewControllerDelegate?
    
    let configuration: LinkedInConfiguration
    let successCallback: LinkedInAuthCodeSuccessCallback?
    let cancelCallback: LinkedInAuthCodeCancelCallback?
    let failureCallback: LinkedInAuthFailureCallback?
    var isHandlingRedirectURL = false
    
    private let webView = UIWebView()
    private var loadingView: LinkedInLoadingView?
    
    init(configuration: LinkedInConfiguration,
         successCallback: LinkedInAuthCodeSuccessCallback?,
         cancelCallback: LinkedInAuthCodeCancelCallback?,
         failureCallback: LinkedInAuthFailureCallback?) {
        self.configuration = configuration
        self.successCallback = successCallback
        self.cancelCallback = cancelCallback
        self.failureCallback = failureCallback
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.endEditing(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let redirectURL = configuration.redirectURL
            .stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let urlString = NSString(format: ApiRoutes.authorizationRoute,
                                 configuration.clientID,
                                 configuration.state,
                                 redirectURL!,
                                 configuration.formattedPermissions() ?? "")
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: urlString as String)!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0))
    }
    
    func setupViews() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationController?.navigationBar.translucent =  true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.view.backgroundColor  = UIColor.clearColor()
        
        let navBarColor = delegate?.linkedInViewControllerNavigationBarColor()
        view.backgroundColor = navBarColor
        
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
                               y: 64.0,
                               width: UIScreen.mainScreen().bounds.width,
                               height: UIScreen.mainScreen().bounds.height - 64.0)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.backgroundColor = UIColor.whiteColor()
        view.addSubview(webView)
    }
    
    func cancelTapped() {
        cancelCallback?()
    }
    
    func showLoadingView() {
        if loadingView == nil {
            loadingView = delegate?.linkedInViewControllerLoadingView()
            if let loadingView = loadingView {
                loadingView.frame = CGRect(x: 0,
                                           y: 64.0,
                                           width: view.frame.size.width,
                                           height: view.frame.size.height)
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
    
    func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .Alert)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .Default) { [weak self] (action) in
                self?.cancelCallback?()
            })
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension LinkedInAuthorizationViewController: UIWebViewDelegate {
    func webView(webView: UIWebView,
                 shouldStartLoadWithRequest request: NSURLRequest,
                                            navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL!.absoluteString
        isHandlingRedirectURL = url.hasPrefix(configuration.redirectURL)
        
        if isHandlingRedirectURL {
            if let _ = url.rangeOfString(Constants.Parameters.error) {
                if let _ = url.rangeOfString(Constants.ErrorReasons.loginCancelled) {
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.AuthCanceled)
                    failureCallback?(error: error)
                } else {
                    let errorDescription = getParameter(withName: Constants.Parameters.error,
                                                        fromURLRequest: request)
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                              customDescription: errorDescription)
                    failureCallback?(error: error)
                }
            } else {
                if let receivedState = getParameter(withName: Constants.Parameters.state,
                                                    fromURLRequest: request),
                    authorizationCode = getParameter(withName: Constants.Parameters.code,
                                                     fromURLRequest: request)
                    where receivedState == configuration.state {
                    successCallback?(code: authorizationCode)
                } else {
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                              customDescription: CustomErrorDescription.authFailureError)
                    failureCallback?(error: error)
                }
            }
        }
        
        if !isHandlingRedirectURL { showLoadingView() }
        
        return !isHandlingRedirectURL
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        hideLoadingView()
        
        if !isHandlingRedirectURL {
            if let errorCode = error?.code,
                networkErrorCode = CFNetworkErrors(rawValue: Int32(errorCode))
                where networkErrorCode == CFNetworkErrors.CFURLErrorNotConnectedToInternet {
                showAlert(withTitle: NSLocalizedString("Network error", comment: ""),
                          message: error!.localizedDescription)
                return
            }
            
            failureCallback?(error: error)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        hideLoadingView()
        
        //Test this out on an iPad
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            webView.stringByEvaluatingJavaScriptFromString(iPadWebjs)
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
