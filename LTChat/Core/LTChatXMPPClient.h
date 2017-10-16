//
//  LTChatXMPPClient.h
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTChatConfig.h"

/**
 * XMPP聊天客户段
 * 注意：XMPP服务器等配置信息LTChatConfig需要在此类使用之前进行初始化
 **/
@interface LTChatXMPPClient : NSObject

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;

@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (nonatomic, strong, readonly) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

/**
 * 单例模式
 **/
+ (instancetype)sharedInstance;

/**
 *  登录接口
 *
 *  @param username      账号
 *  @param password 密码
 */
- (void)loginWithName:(NSString *)username
             password:(NSString *)password
             complete:(void (^)(BOOL success))complete;

/**
 *  注册接口
 *
 *  @param username      账号
 *  @param password 密码
 */
- (void)registerWithName:(NSString *)username
                password:(NSString *)password
                complete:(void (^)(BOOL success))complete;

/**
 *  退出登录
 */
- (void)logout;

#pragma mark - Roster
/**
 *  发送好友申请
 *
 *  @param username    对方的username
 *  @param reason 附带内容
 */
- (void)addUser:(NSString *)username reason:(NSString *)reason;
/**
 *  获取好友列表
 *
 *  @return 好友数组
 */
- (NSArray *)getUsers;

/**
 *  接受对方的好友请求
 *
 *  @param username  对方的username
 *  @param flag 是否同时请求加对方为好友，YES:请求加对方，NO:不请求加对方
 */
- (void)acceptAddRequestFrom:(NSString *)username andAddRoster:(BOOL)flag;

/**
 *  拒绝对方的好友请求
 *
 *  @param username 对方的username
 */
- (void)rejectAddRequestFrom:(NSString*)username;

/**
 *  删除某个好友
 *
 *  @param username 要删除好友的username
 */
- (void)removeUser:(NSString*)username;

/**
 *  为好友设置备注
 *
 *  @param nickname 备注
 *  @param username      好友的username
 */
- (void)setNickname:(NSString *)nickname forUser:(NSString *)username;
#pragma mark - 单聊
/**
 *  发送文字消息
 *
 *  @param message  文本
 *  @param username 对方的username
 */
- (void)sendMessage:(NSString *)message toUser:(NSString *)username;

/**
 *  发送信令消息
 *
 *  @param message 信令消息内容
 *  @param jidStr  对方jidStr
 */
- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)jidStr;
@end
