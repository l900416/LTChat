//
//  LTChatWebRTCClient.h
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebRTC/WebRTC.h>
#import "LTVideoChatView.h"

@interface LTChatWebRTCClient : NSObject

//聊天界面
@property (nonatomic, strong) LTVideoChatView* rtcView;
//自己的JID
@property (copy, nonatomic) NSString* myJID;
//对方JID
@property (copy, nonatomic) NSString* remoteJID;


/**
 * 单例模式
 **/
+ (instancetype)sharedInstance;


- (void)startEngine;

- (void)stopEngine;

- (void)showRTCViewByRemoteName:(NSString *)remoteName isVideo:(BOOL)isVideo isCaller:(BOOL)isCaller;

- (void)resizeViews;

@end
