# LinkedInKit

[![CI Status](http://img.shields.io/travis/Mariana/LinkedInKit.svg?style=flat)](https://travis-ci.org/Mariana/LinkedInKit)
[![Version](https://img.shields.io/cocoapods/v/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)
[![License](https://img.shields.io/cocoapods/l/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)
[![Platform](https://img.shields.io/cocoapods/p/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)

A simple wrapper for linkedIn-sdk & linkedIn REST Api written in Swift.
Based on https://github.com/tonyli508/LinkedinSwift

**Using LinkedIn SDK 1.0.7**


## Example

To run the example project, clone the repo, and run `pod install` from the **Example** directory first.

## Requirements
iOS 8.0+

## Installation

LinkedInKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LinkedInKit'
```

#### Backwards compatibility

For Swift 2.3 use:
```ruby
pod 'LinkedInKit', :git => 'https://github.com/webfactorymk/linkedInkit.git', :branch => 'swift2.3'
```

For Swift 2.2 use:
```ruby
pod 'LinkedInKit', :git => 'https://github.com/webfactorymk/linkedInkit.git', :branch => 'swift2.2'
```

## Usage

For project setup please see [Getting Started with the Mobile SDK for iOS](https://developer.linkedin.com/docs/ios-sdk) and [Getting started with the REST API
](https://developer.linkedin.com/docs/rest-api). LinkedIn sdk is already imported.

### Setup
```swift
    LinkedInKit.setup(withConfiguration: LinkedInConfiguration(withClientID: "your_client_id",
                                                               clientSecret: "your_client_secret",
                                                               state: "custom_state_string",
                                                               permissions: [LISDK_BASIC_PROFILE_PERMISSION, LISDK_EMAILADDRESS_PERMISSION],
                                                               redirectURL: "any_valid_url",
                                                               appID: "your_linked_in_app_id"))
```
> `redirect_url` param needs to be any valid url so the API calls and responses can be intercepted (if using REST api)


### Authentication
```swift
    LinkedInKit.authenticate({ (token) in
        print(token)
    }) { (error) in
        print(error)
    }
```


### API requests

```swift
    LinkedInKit.openProfileWithMemberId("member_id", success: { (success) in
                    print(success)
                }) { (error) in
                    print(error)
        }
```


```swift
    LinkedInKit.requestUrl("https://api.linkedin.com/v1/people/~/shares?format=json",
                            method: .POST,
                            parameters: parameters,
                            success: { (response) in
                                print("response data: \(response?.jsonObject)")
                         }, failure: { (error) in
                                print(error)
        })
```

### Customizing Web View appearance 


```swift
    LinkedInKit.authViewControllerDelegate = DesignManager.sharedInstance
```

#### LinkedInAuthorizationViewControllerDelegate methods


```swift 
    func linkedInViewControllerNavigationBarColor() -> UIColor? {
        /* return UIColor for customizing the navigation bar */
    }
    
    func linkedInViewControllerTitleAttributtedString() -> NSAttributedString? {
        /* return NSAttributtedString for formating the navigation bar title */
    }
    
    func linkedInViewControllerCancelAttributtedString() -> NSAttributedString? {
        /* return NSAttributtedString for formating 'Cancel' button label */
    }
    
    func linkedInViewControllerLoadingView() -> LinkedInLoadingView? {
        /* return a view conforming the LinkedInLoadingView protocol */
    }
```

## License

LinkedInKit is available under the MIT license. See the LICENSE file for more info.
