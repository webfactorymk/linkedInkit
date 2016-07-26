# LinkedInKit

[![CI Status](http://img.shields.io/travis/Mariana/LinkedInKit.svg?style=flat)](https://travis-ci.org/Mariana/LinkedInKit)
[![Version](https://img.shields.io/cocoapods/v/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)
[![License](https://img.shields.io/cocoapods/l/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)
[![Platform](https://img.shields.io/cocoapods/p/LinkedInKit.svg?style=flat)](http://cocoapods.org/pods/LinkedInKit)


A simple wrapper for linkedIn-sdk & linkedIn REST Api written in Swift


## Example

To run the example project, clone the repo, and run `pod install` from the **Example** directory first.

## Requirements
iOS 8.0+

## Installation

LinkedInKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LinkedInKit', :git => 'http://git.wf.mk/wf-pods/LinkedInKit.git'
```

## Usage

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

### GET requests
```swift
    LinkedInKit.requestUrl(linkedInProfileUrl,
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

## License

LinkedInKit is available under the MIT license. See the LICENSE file for more info.
