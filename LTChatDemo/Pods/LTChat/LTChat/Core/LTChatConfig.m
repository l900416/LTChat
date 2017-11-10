//
//  LTChatConfig.m
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatConfig.h"

@implementation LTChatConfig

static LTChatConfig *_instance;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LTChatConfig alloc] init];
        [_instance setupInitValues];
    });
    
    return _instance;
}

/*默认设置*/
-(void)setupInitValues{
    /*XMPP*/
    //_xmppHost =
    _xmppPort = 5552;
    _xmppResource = @"LTChatResource";
    _xmppDomain = @"LTChatDomain";
    
    /*Subject*/
    _xmppChatSubject = @"chat";
    _xmppWebrtcSubject = @"webrtc";
    
    /*Presence*/
    _xmppPresenceStatus = @"我在线上";
    _xmppPresenceShow = @"online";
    
    /*WebRTC*/
//    _webrtcCall = @"call_webrtc";
    _webrtcCancel = @"stop_webrtc";
//    _webrtcAccept = @"accept_webrtc";
    _webrtcReject = @"reject_webrtc";
    _webrtcStop = @"stop_webrtc";
}
@end
