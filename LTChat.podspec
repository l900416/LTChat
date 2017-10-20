
Pod::Spec.new do |s|
  s.name         = "LTChat"
  s.version      = "0.0.2"
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
  s.source_files  = "LTChat", "LTChat/**/*.{h,m}"
  # s.exclude_files = "LTChat/Exclude"

  s.public_header_files = "LTChat/**/*.h"
  s.resources = "LTChat/LTChat.bundle","LTChat/**/*.{xib}"

  s.frameworks = "Foundation", "UIKit", "CFNetwork", "CoreData", "CoreLocation", "Security", "SystemConfiguration"

  s.requires_arc = true
  s.dependency  'XMPPFramework', '~> 3.7.0'
  s.dependency  'WebRTC', '~> 61.5.19063'
# s.dependency  'GoogleWebRTC' #ERROR :Architectures in the fat file: WebRTC are: x86_64 armv7 arm64


end
