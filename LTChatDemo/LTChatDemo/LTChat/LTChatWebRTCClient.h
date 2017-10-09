//
//  LTChatWebRTCClient.h
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

@interface LTChatWebRTCClient : NSObject

@property (copy, nonatomic)     NSString            *myJID;  /** 自己的JID */
@property (copy, nonatomic)     NSString            *remoteJID;    /** 对方JID */


/**
 * 单例模式
 **/
+ (instancetype)sharedInstance;
@end
