# WebRTC SDK for iOS
This pod contains the WebRTC iOS SDK in binary form. It is a dynamic library
that contains the armv7, arm64 and x86_64 slices. 
Bitcode is not supported.
Our currently provided API’s are Objective C only.

## Getting started
If you are new to WebRTC valuable resources can be found at webrtc.org/start/.
More documentation can be found at https://webrtc.org/native-code/ios/.
Sample code can be found [here](https://chromium.googlesource.com/external/webrtc/+/master/webrtc/examples/objc/AppRTCMobile/).

## Installation
To integrate the WebRTC SDK into your XCode project add the following to your
Podfile:


```
source 'https://github.com/CocoaPods/Specs.git'
target 'YOUR_APPLICATION_TARGET_NAME_HERE' do
 platform :ios, '9.0'
 pod 'GoogleWebRTC'
end
```

Then, run the following command

```
$ pod install
```

## Notice
While WebRTC source code is licensed under BSD, it depends on many
other open sourced projects. The list of relevant transitive licenses are
enclosed in LICENSE.html.

## Terms of Service
WebRTC is a free, open project that provides browsers and
mobile applications with Real-Time Communications (RTC) capabilities via simple
APIs. The WebRTC components have been optimized to best serve this purpose.

Our mission: To enable rich, high-quality RTC applications to be developed for
browsers, mobile platforms, and IoT devices, and allow them all to communicate
via a common set of protocols.

The mobile libraries are part of Google’s effort to facilitate the adoption of
WebRTC on Android and iOS. They can be integrated with projects in Apple’s Xcode
and Android studio directly, giving developers the opportunity to start
experimenting with WebRTC without the need to check-out and build from
https://chromium.googlesource.com/external/webrtc.

Thank you, -The WebRTC Team


Section 1:  Intended Uses

The WebRTC Mobile and APIs and developer libraries are published to facilitate
the development of mobile applications for Android and iOS. The APIs are
published weekly as a snapshot of the WebRTC source code at
https://chromium.googlesource.com/external/webrtc. The provided libraries are
targeted for developers that want to try out WebRTC on mobile devices.

