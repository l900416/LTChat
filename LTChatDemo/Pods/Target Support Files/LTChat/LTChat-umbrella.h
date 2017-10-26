#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LTChatConfig.h"
#import "LTChatWebRTCClient.h"
#import "LTChatXMPPClient.h"
#import "LTVideoChatView.h"

FOUNDATION_EXPORT double LTChatVersionNumber;
FOUNDATION_EXPORT const unsigned char LTChatVersionString[];

