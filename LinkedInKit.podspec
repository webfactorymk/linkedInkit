Pod::Spec.new do |s|
  s.name             = 'LinkedInKit'
  s.version          = '1.2.1'
  s.summary          = 'LinkedInKit - Framework for LinkedIn authentication'
  s.description      = <<-DESC
LinkedInKit is a framework for LinkedIn authentication both through the LinkedIn app or with the Browser OAuth 2 authentication. It is built as a simple wrapper for linkedIn-sdk & linkedIn REST API written in Swift. Based on https://github.com/tonyli508/LinkedinSwift
                       DESC

  s.homepage         = 'https://github.com/WebFactoryMk/linkedInkit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mariana' => 'mariana.ristovska@webfactory.mk', 'Gordan' => 'gordan.cvetkovski@webfactory.mk' }
  s.source           = { :git => 'https://github.com/WebFactoryMk/linkedInkit.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.ios.deployment_target = '9.0'

  s.vendored_frameworks = 'linkedin-sdk.framework'
  s.source_files = 'LinkedInKit/Classes/**/*', 'linkedin-sdk.framework/Headers/LISDKAccessToken.h', 'linkedin-sdk.framework/Headers/LISDKAPIError.h', 'linkedin-sdk.framework/Headers/LISDKAPIHelper.h', 'linkedin-sdk.framework/Headers/LISDKAPIResponse.h', 'linkedin-sdk.framework/Headers/LISDKCallbackHandler.h', 'linkedin-sdk.framework/Headers/LISDKDeeplinkHelper.h', 'linkedin-sdk.framework/Headers/LISDKErrorCode.h', 'linkedin-sdk.framework/Headers/LISDKPermission.h', 'linkedin-sdk.framework/Headers/LISDKSession.h', 'linkedin-sdk.framework/Headers/LISDKSessionManager.h'
  s.public_header_files = 'linkedin-sdk.framework/Headers/LISDKAccessToken.h', 'linkedin-sdk.framework/Headers/LISDKAPIError.h', 'linkedin-sdk.framework/Headers/LISDKAPIHelper.h', 'linkedin-sdk.framework/Headers/LISDKAPIResponse.h', 'linkedin-sdk.framework/Headers/LISDKCallbackHandler.h', 'linkedin-sdk.framework/Headers/LISDKDeeplinkHelper.h', 'linkedin-sdk.framework/Headers/LISDKErrorCode.h', 'linkedin-sdk.framework/Headers/LISDKPermission.h', 'linkedin-sdk.framework/Headers/LISDKSession.h', 'linkedin-sdk.framework/Headers/LISDKSessionManager.h'
  s.dependency 'Alamofire'

end
