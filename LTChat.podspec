
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
  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/l900416/LTChat.git", :tag => s.version }
  s.source_files  = "LTChat", "LTChat/**/*.{h,m}", "LTChat/*.{h,m}"
  # s.exclude_files = "LTChat/Exclude"

  s.public_header_files = "LTChat/**/*.h"
  s.resources = "LTChat/LTChat.bundle","LTChat/**/*.{xib}"

  s.frameworks = "Foundation", "UIKit", "CFNetwork", "CoreData", "CoreLocation", "Security", "SystemConfiguration"

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
    ss.dependency "KissXML"
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/KissXML"}
  end

  s.subspec "CocoaAsyncSocket" do |ss|
    ss.dependency "CocoaAsyncSocket"
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/CocoaAsyncSocket"}
  end

  s.subspec "CocoaLumberjack" do |ss|
    ss.dependency "CocoaLumberjack"
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/CocoaLumberjack"}
  end
end
