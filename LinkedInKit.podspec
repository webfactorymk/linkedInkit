Pod::Spec.new do |s|
  s.name             = 'LinkedInKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LinkedInKit.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/LinkedInKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mariana' => 'mariana.ristovska@webfactory.mk' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/LinkedInKit.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

s.preserve_paths      = 'linkedin-sdk.framework'
s.vendored_frameworks = 'linkedin-sdk.framework'
s.source_files =  ['LinkedInKit/Classes/**/*', 'linkedin-sdk.framework/Headers/LISDKAccessToken.h', 'linkedin-sdk.framework/Headers/LISDKAPIError.h', 'linkedin-sdk.framework/Headers/LISDKAPIHelper.h', 'linkedin-sdk.framework/Headers/LISDKAPIResponse.h', 'linkedin-sdk.framework/Headers/LISDKCallbackHandler.h', 'linkedin-sdk.framework/Headers/LISDKDeeplinkHelper.h', 'linkedin-sdk.framework/Headers/LISDKErrorCode.h', 'linkedin-sdk.framework/Headers/LISDKPermission.h', 'linkedin-sdk.framework/Headers/LISDKSession.h', 'linkedin-sdk.framework/Headers/LISDKSessionManager.h']
# s.public_header_files = 'linkedin-sdk.framework/Headers/*.h'

s.xcconfig = { "HEADER_SEARCH_PATHS" => "./linkedin-sdk.framework/Headers/LISDK.h" }

  s.dependency 'Alamofire'

end
