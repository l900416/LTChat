//
//  LTChatConfig.h
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <Foundation/Foundation.h>



#ifndef LTCHATXMPPFramework_h
#define LTCHATXMPPFramework_h

#import <XMPPFramework/XMPP.h>

//连接
#import <XMPPFramework/XMPPReconnect.h>
#import <XMPPFramework/XMPPAutoPing.h>

//花名册
#import <XMPPFramework/XMPPRoster.h>
#import <XMPPFramework/XMPPRosterMemoryStorage.h>  //遵循 XMPPRosterStorage接口
#import <XMPPFramework/XMPPUserMemoryStorageObject.h> //遵循 XMPPUser接口

//聊天记录模块的导入
#import <XMPPFramework/XMPPMessageArchiving.h>
#import <XMPPFramework/XMPPMessageArchivingCoreDataStorage.h>
#import <XMPPFramework/XMPPMessageArchiving_Contact_CoreDataObject.h> //最近联系人
#import <XMPPFramework/XMPPMessageArchiving_Message_CoreDataObject.h>

//文件传输
//接收文件
#import <XMPPFramework/XMPPIncomingFileTransfer.h>
//发送文件
#import <XMPPFramework/XMPPOutgoingFileTransfer.h>


#endif /* LTCHATXMPPFramework_h */

/**
 * 通知 Notification
 **/

//登陆成功通知
#define kLTCHAT_XMPP_LOGIN_SUCCESS  @"kLTCHAT_XMPP_LOGIN_SUCCESS"
//注册结果通知
#define kLTCHAT_XMPP_REGISTER_RESULT  @"kLTCHAT_XMPP_REGISTER_RESULT"
//花名册变更通知
#define kLTCHAT_XMPP_ROSTER_CHANGE  @"kLTCHAT_XMPP_ROSTER_CHANGE"
//添加好友通知
#define kLTCHAT_XMPP_ROSTER_ADD_NOTIFICATION  @"kLTCHAT_XMPP_ROSTER_ADD_NOTIFICATION"
//消息变更通知
#define kLTCHAT_XMPP_MESSAGE_CHANGE  @"kLTCHAT_XMPP_MESSAGE_CHANGE"
//WEBRTC消息变更通知
#define kLTCHAT_XMPP_WEBRTC_MESSAGE_CHANGE  @"kLTCHAT_XMPP_WEBRTC_MESSAGE_CHANGE"

/**WebRTC挂断通知,Object中附带参数
 @{
 @"isVideo":@(self.isVideo),     // 是否是视频通话
 @"isCaller":@(!self.callee),    // 是否是发起方挂断
 @"answered":@(self.answered)    // 通话是否已经接通
 }
 */
#define kLTCHAT_WEBRTC_HANGUP_NOTIFICATION  @"kLTCHAT_WEBRTC_HANGUP_NOTIFICATION"

/**WebRTC接听通知,Object中附带参数
 @{
 @"isVideo":@(YES),      // 是否为视频通话
 @"audioAccept":@(YES)   // 是否为语音接听，音频通话和视频通话里的语音接听都是YES
 }
 */
#define kLTCHAT_WEBRTC_ACCEPT_NOTIFICATION  @"kLTCHAT_WEBRTC_ACCEPT_NOTIFICATION"

// 摄像头切换的通知，接收到该通知时，需要切换摄像头,默认应该是开启前置摄像头
#define kLTCHAT_WEBRTC_SWITCH_CAMERA_NOTIFICATION  @"kLTCHAT_WEBRTC_SWITCH_CAMERA_NOTIFICATION"

/**静音按钮事件通知, 静音之后，对方听不到自己这边的任何声音,Object中附带参数
 @{
 @"isMute":@(self.muteBtn.selected)
 }
 */
#define kLTCHAT_WEBRTC_MUTE_NOTIFICATION  @"kLTCHAT_WEBRTC_MUTE_NOTIFICATION"

/**开启和关闭本地摄像头的事件，需要在收到通知后，开启或者关闭视频采集功能,Object中附带参数
 @{
 @"videoCapture":@(YES)
 }
 */
#define kLTCHAT_WEBRTC_CAPTURE_NOTIFICATION  @"kLTCHAT_WEBRTC_CAPTURE_NOTIFICATION"

/**
 * Chat Config
 **/
@interface LTChatConfig : NSObject

/** 
 * 单例模式
 **/
+ (instancetype)sharedInstance;

#pragma mark - XMPP

/*XMPP 服务器配置相关*/
//xmpp host
@property (nonatomic, strong) NSString* xmppHost;
//xmpp port
@property (nonatomic, assign) UInt16 xmppPort;
//xmpp resource
@property (nonatomic, strong) NSString* xmppResource;
//xmpp domain
@property (nonatomic, strong) NSString* xmppDomain;

/**
 * 主题配置，对应XMPPMessage中的subject字段
 * 当XMPP收到消息后，首先会解析消息的subject字段
 **/
//普通聊天主题，默认为chat
@property (nonatomic, strong) NSString* xmppChatSubject;
//WebRTC聊天主题，默认为webrtc
@property (nonatomic, strong) NSString* xmppWebrtcSubject;


/**
 * 登录之后默认的状态配置
 **/
@property (nonatomic, strong) NSString* xmppPresenceStatus;//我在线上
@property (nonatomic, strong) NSString* xmppPresenceShow;//online

#pragma mark - webRTC
/**
 * WebRTC通信用
 **/
// Call
//@property (nonatomic, strong) NSString* webrtcCall;
// Cancel
@property (nonatomic, strong) NSString* webrtcCancel;
// Accept
//@property (nonatomic, strong) NSString* webrtcAccept;
// Reject
@property (nonatomic, strong) NSString* webrtcReject;
// Stop
@property (nonatomic, strong) NSString* webrtcStop;

@end
