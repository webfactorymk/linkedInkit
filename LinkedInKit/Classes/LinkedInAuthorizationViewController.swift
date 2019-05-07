import UIKit

typealias LinkedInAuthCodeSuccessCallback = (_ code: String) -> ()
typealias LinkedInAuthCodeCancelCallback = () -> ()

public protocol LinkedInAuthorizationViewControllerDelegate: class {
    func linkedInViewControllerNavigationBarColor() -> UIColor?
    func linkedInViewControllerTitleAttributtedString() -> NSAttributedString?
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString?
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView?
}

public extension LinkedInAuthorizationViewControllerDelegate {
    func linkedInViewControllerNavigationBarColor() -> UIColor? {
        return UIColor.white
    }
    
    func linkedInViewControllerTitleAttributtedString() -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        return NSAttributedString(string: "Sign In", attributes: attributes)
    }
    
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString? {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
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
    
    fileprivate let webView = UIWebView()
    fileprivate var loadingView: LinkedInLoadingView?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.endEditing(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let redirectURL = configuration.redirectURL
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = NSString(format: ApiRoutes.authorizationRoute as NSString,
                                 configuration.clientID,
                                 configuration.state,
                                 redirectURL!,
                                 configuration.formattedPermissions() ?? "")
        
        webView.loadRequest(URLRequest(url: URL(string: urlString as String)!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 15.0))
    }
    
    func setupViews() {
        automaticallyAdjustsScrollViewInsets = false
        
        navigationController?.navigationBar.isTranslucent =  true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController?.view.backgroundColor  = UIColor.clear
        
        let navBarColor = delegate?.linkedInViewControllerNavigationBarColor()
        view.backgroundColor = navBarColor
        
        let label = UILabel()
        if let titleAttrString = delegate?.linkedInViewControllerTitleAttributtedString() {
            label.attributedText = titleAttrString
        } else {
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            label.attributedText = NSAttributedString(string: "Sign In", attributes: attributes)
        }
        label.sizeToFit()
        navigationItem.titleView = label
        
        let customButton = UIButton()
        if let cancelAttrString = delegate?.linkedInViewControllerCancelAttributtedString() {
            customButton.setAttributedTitle(cancelAttrString,
                                            for: .normal)
        } else {
            let attributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            let attributedTitle = NSAttributedString(string: "Cancel", attributes: attributes)
            customButton.setAttributedTitle(attributedTitle,
                                            for: .normal)
        }
        customButton.sizeToFit()
        customButton.addTarget(self,
                               action: #selector(LinkedInAuthorizationViewController.cancelTapped),
                               for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItems = [barButtonItem]
        
        webView.frame = CGRect(x: 0,
                               y: 64.0,
                               width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height - 64.0)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.backgroundColor = UIColor.white
        view.addSubview(webView)
    }
    
    @objc func cancelTapped() {
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
        
        loadingView?.isHidden = false
        loadingView?.startAnimating()
    }
    
    func hideLoadingView() {
        loadingView?.isHidden = true
        loadingView?.startAnimating()
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: ""),
            style: .default) { [weak self] (action) in
                self?.cancelCallback?()
            })
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension LinkedInAuthorizationViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                                            navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!.absoluteString
        isHandlingRedirectURL = url.hasPrefix(configuration.redirectURL)
        
        if isHandlingRedirectURL {
            if let _ = url.range(of: Constants.Parameters.error) {
                if let _ = url.range(of: Constants.ErrorReasons.loginCancelled) {
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.AuthCanceled)
                    failureCallback?(error)
                } else {
                    let errorDescription = getParameter(withName: Constants.Parameters.error,
                                                        fromURLRequest: request)
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                              customDescription: errorDescription)
                    failureCallback?(error)
                }
            } else {
                if let receivedState = getParameter(withName: Constants.Parameters.state,
                                                    fromURLRequest: request),
                    let authorizationCode = getParameter(withName: Constants.Parameters.code,
                                                     fromURLRequest: request), receivedState == configuration.state {
                    successCallback?(authorizationCode)
                } else {
                    let error = NSError.error(withErrorDomain: LinkedInErrorDomain.RESTFailure,
                                              customDescription: CustomErrorDescription.authFailureError)
                    failureCallback?(error)
                }
            }
        }
        
        if !isHandlingRedirectURL { showLoadingView() }
        
        return !isHandlingRedirectURL
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideLoadingView()
        
        if !isHandlingRedirectURL {
            if let networkErrorCode = CFNetworkErrors(rawValue: Int32(error._code)), networkErrorCode == CFNetworkErrors.cfurlErrorNotConnectedToInternet {
                showAlert(withTitle: NSLocalizedString("Network error", comment: ""),
                          message: error.localizedDescription)
                return
            }
            
            failureCallback?(error as NSError)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoadingView()
        
        //Test this out on an iPad
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            webView.stringByEvaluatingJavaScript(from: iPadWebjs)
        }
    }
    
    func getParameter(withName name: String, fromURLRequest request: URLRequest) -> String? {
        let urlComponents = URLComponents(url: request.url!,
                                            resolvingAgainstBaseURL: false)
        for item in (urlComponents?.queryItems)! {
            if item.name == name {
                return item.value
            }
        }
        
        return nil
    }
}
