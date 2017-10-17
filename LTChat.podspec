
Pod::Spec.new do |s|
  s.name         = "LTChat"
  s.version      = "0.0.1"
  s.summary      = "Chat use XMPP framework and WebRTC framework."
  s.description  = <<-DESC
Base on XMPP framework and WebRTC framework. First release.
                   DESC

  s.homepage     = "https://github.com/l900416/LTChat"
  s.license      = "MIT"
  s.author             = { "liangtong" => "l900416@163.com" }
  s.platform = :ios, '9.0'
  #  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/l900416/LTChat.git", :tag => "#{s.version}" }
  s.source_files  = "LTChat", "LTChat/**/*.{h,m}"
  s.exclude_files = "LTChat/Exclude"

  s.public_header_files = "LTChat/**/*.h"
  s.resources = "LTChat/LTChat.bundle","LTChat/**/*.{xib}"
  #  s.frameworks = "UIKit", "Foundation", "AVFoundation", "CoreTelephony", "SystemConfiguration", "MobileCoreServices"

  s.requires_arc = true
  s.dependency  'XMPPFramework'
  s.dependency  'GoogleWebRTC'

  s.subspec "XMPPFramework" do |ss|
    ss.dependency "XMPPFramework"
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/XMPPFramework"}
  end

  s.subspec "GoogleWebRTC" do |ss|
    ss.dependency "GoogleWebRTC"
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/GoogleWebRTC"}
  end


  s.subspec "KissXML" do |ss|
    ss.xcconfig = { "SWIFT_VERSION" => "3.0"}
  end

  s.xcconfig = { "SWIFT_VERSION" => "3.0"}

end
