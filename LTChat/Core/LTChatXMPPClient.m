//
//  LTChatXMPPClient.m
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatXMPPClient.h"
#import "LTChatWebRTCClient.h"

@interface LTChatXMPPClient()

@property (nonatomic, strong) XMPPStream *xmppStream;

@property (nonatomic, strong) XMPPAutoPing *xmppAutoPing;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;

@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;

@property (nonatomic, strong) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;

//因为服务连接和授权／注册分离，所以密码需要单独存储起来
@property (nonatomic, copy)   NSString *password;
//XMPP注册和登录在服务连接成功后调用的方法不同，所以此处需要一个标记位
@property (nonatomic, assign) BOOL  xmppNeedRegister;

@property (nonatomic, copy) void (^loginCallback)(BOOL success);
@property (nonatomic, copy) void (^registerCallback)(BOOL success);
@end

@implementation LTChatXMPPClient

static LTChatXMPPClient *_instance;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LTChatXMPPClient alloc] init];
    });
    [_instance setupXMPPStream];
    return _instance;
}

/*初始化XMPPStream信息*/
-(void)setupXMPPStream{
    if (!_xmppStream) {
        _xmppStream = [[XMPPStream alloc] init];
        //可以参照我的博客：https://l900416.github.io/2017/09/22/ios_instance_message_xmpp/
        //socket 连接的时候 要知道host port 然后connect
        [_xmppStream setHostName:[LTChatConfig sharedInstance].xmppHost];
        [_xmppStream setHostPort:[LTChatConfig sharedInstance].xmppPort];
        
        //添加Delegate
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //添加功能模块
        //1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
        _xmppAutoPing = [[XMPPAutoPing alloc] init];
        //所有的Module模块，都要激活active
        [_xmppAutoPing activate:self.xmppStream];
        
        //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
        [_xmppAutoPing setPingInterval:1000];
        //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
        [_xmppAutoPing setRespondsToQueries:YES];
        //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
        
        //2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
        _xmppReconnect = [[XMPPReconnect alloc] init];
        [_xmppReconnect activate:self.xmppStream];
        [_xmppReconnect setAutoReconnect:YES];
        
        // 3.好友模块 支持我们管理、同步、申请、删除好友
        _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage];
        [_xmppRoster activate:self.xmppStream];
        
        //同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
        [_xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
        //关掉自动接收好友请求，默认开启自动同意
        [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
        
        //4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
        [_xmppMessageArchiving activate:self.xmppStream];
        
        //5、文件接收
        _xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        [_xmppIncomingFileTransfer activate:self.xmppStream];
        [_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppIncomingFileTransfer setAutoAcceptFileTransfers:YES];
    }
    
}

/**
 *  登录接口
 *
 *  @param username      账号
 *  @param password 密码
 */
- (void)loginWithName:(NSString *)username
             password:(NSString *)password
             complete:(void (^)(BOOL success))complete{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppStream setMyJID:JID];
    self.password = password;
    self.xmppNeedRegister = NO;
    self.loginCallback = complete;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
}

/**
 *  注册接口
 *
 *  @param username      账号
 *  @param password 密码
 */
- (void)registerWithName:(NSString *)username
                password:(NSString *)password
                complete:(void (^)(BOOL success))complete{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppStream setMyJID:JID];
    self.password = password;
    self.xmppNeedRegister = YES;
    self.registerCallback = complete;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    
}

/**
 *  退出登录
 */
- (void)logout{
    [self.xmppStream disconnect];
    [self.xmppStream removeDelegate:self];
    self.xmppStream = nil;
    self.loginCallback = nil;
    self.registerCallback = nil;
}

#pragma mark - XMPPStreamDelegate
/*证书相关*/
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings{
}
/*连接服务器之后，回调的方法*/
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"%s - %s",__FILE__,__FUNCTION__);
    //服务器连接成功之后，需要进行登录／注册操作
    if (self.xmppNeedRegister) {
        NSError *error;
        [self.xmppStream registerWithPassword:self.password error:&error];
    }else{
        [self.xmppStream authenticateWithPassword:self.password error:nil];
    }
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"%s - %s\n error:%@",__FILE__,__FUNCTION__,error);
    if (self.xmppNeedRegister && self.registerCallback) {
        self.registerCallback(NO);
    }
    if (self.loginCallback) {
        self.loginCallback(NO);
    }
}

/*新用户注册，回调的方法*/
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"%s - %s",__FILE__,__FUNCTION__);
    if (self.registerCallback) {
        self.registerCallback(YES);
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"%s - %s\n error:%@",__FILE__,__FUNCTION__,error);
    if (self.registerCallback) {
        self.registerCallback(NO);
    }
}
/*用户登陆，回调的方法*/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"%s - %s",__FILE__,__FUNCTION__);
    if (self.loginCallback) {
        self.loginCallback(YES);
    }
    
    //登录成功，发送Presence用户状态数据
    [self goOnline];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    NSLog(@"%s - %s",__FILE__,__FUNCTION__);
    if (self.loginCallback) {
        self.loginCallback(NO);
    }
}

#pragma mark - 花名册模块
/*收到添加好友请求*/
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"%s - %s",__FILE__,__FUNCTION__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_ROSTER_ADD_NOTIFICATION object:presence];
//    NSString *message = [NSString stringWithFormat:@"【%@】想加你为好友",presence.from.bare];
//    [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
//    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
}
/*删除好友*/
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    //收到对方取消定阅我得消息
    if ([presence.type isEqualToString:@"unsubscribed"]) {
        //从我的本地通讯录中将他移除
        [self.xmppRoster removeUser:presence.from];
    }
}
/*开始同步服务器发送过来的自己的好友列表*/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{

}
/*同步结束*/
//收到好友列表IQ会进入的方法，并且已经存入我的存储器
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_ROSTER_CHANGE object:nil];
}
//收到每一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item{
    //此处如果不使用coredata数据库，则可以通过这个回调进行好友花名册维护
}
// 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_ROSTER_CHANGE object:nil];
}


#pragma mark - 发送消息
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"消息发送成功");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_MESSAGE_CHANGE object:nil];
    });
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"消息发送失败");
}

#pragma mark - 文件接收
/** 是否同意对方发文件给我 */
- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didReceiveSIOffer:(XMPPIQ *)offer
{
    NSLog(@"%s",__FUNCTION__);
    //弹出一个是否接收的询问框
    //    [self.xmppIncomingFileTransfer acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender didSucceedWithData:(NSData *)data named:(NSString *)name
{
    //    XMPPJID *jid = [sender.senderJID copy];
    NSLog(@"%s",__FUNCTION__);
    //在这个方法里面，我们通过带外来传输的文件
    //因此我们的消息同步器，不会帮我们自动生成Message,因此我们需要手动存储message
    //根据文件后缀名，判断文件我们是否能够处理，如果不能处理则直接显示。
    //图片 音频 （.wav,.mp3,.mp4)
    //    NSString *extension = [name pathExtension];
    //    if (![@"wav" isEqualToString:extension]) {
    //        return;
    //    }
    //    //创建一个XMPPMessage对象,message必须要有from
    //    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:jid];
    //    //将这个文件的发送者添加到Message的from
    //    [message addAttributeWithName:@"from" stringValue:sender.senderJID.bare];
    //    [message addSubject:@"audio"];
    //
    //    //保存data
    //    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    //    path = [path stringByAppendingPathExtension:@"wav"];
    //    [data writeToFile:path atomically:YES];
    //
    //    [message addBody:path.lastPathComponent];
    //
    //    [self.xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:self.xmppStream];
}

#pragma mark - 消息聊天模块
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"%s--%@",__FUNCTION__, message);
    //XEP--0136 已经用coreData实现了数据的接收和保存
    
    NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    //根据主题判断是否为webRTC聊天信息
    NSString* subject = [message subject];
    if ([subject isEqualToString:[LTChatConfig sharedInstance].xmppWebrtcSubject]) {//webRTC主题
        [LTChatWebRTCClient sharedInstance].myJID = self.xmppStream.myJID.full;
        [LTChatWebRTCClient sharedInstance].remoteJID = message.from.full;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_WEBRTC_MESSAGE_CHANGE object:jsonDic];
    }else{
        if ([jsonDic objectForKey:@"roomId"]) {
            //        NSLog(@"roomId:%@",[dict objectForKey:@"roomId"]);
            //        [[LTWebRTCClient sharedInstance] showRTCViewByRemoteName:message.from.full isVideo:YES isCaller:NO];
        }
    }
    
    // 当消息已经保存好，通知控制器来取。因为消息保存需要一定的时间，此处没有重写coredata方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_XMPP_MESSAGE_CHANGE object:nil];
    });
    
}

- (void)goOnline{
    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    XMPPPresence *presence = [XMPPPresence presence];
    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:[LTChatConfig sharedInstance].xmppPresenceStatus]];
    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:[LTChatConfig sharedInstance].xmppPresenceShow]];
    
    [self.xmppStream sendElement:presence];
}

#pragma mark - Roster
/**
 *  发送加好友申请
 *
 *  @param username    对方的username
 *  @param reason 发送
 */
- (void)addUser:(NSString *)username reason:(NSString *)reason{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppRoster addUser:JID withNickname:nil];
}

/**
 *  获取好友列表
 *
 *  @return 好友数组
 */
- (NSArray *)getUsers{
    return self.xmppRosterMemoryStorage.sortedUsersByAvailabilityName;
}

/**
 *  接受对方的好友请求
 *
 *  @param username  对方的username
 *  @param flag 是否同时请求加对方为好友，YES:请求加对方，NO:不请求加对方
 */
- (void)acceptAddRequestFrom:(NSString *)username andAddRoster:(BOOL)flag{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:JID andAddToRoster:flag];
}

/**
 *  拒绝对方的好友请求
 *
 *  @param username 对方的username
 */
- (void)rejectAddRequestFrom:(NSString*)username{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppRoster rejectPresenceSubscriptionRequestFrom:JID];
}

/**
 *  删除某个好友
 *
 *  @param username 要删除好友的username
 */
- (void)removeUser:(NSString*)username{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppRoster removeUser:JID];
}

/**
 *  为好友设置备注
 *
 *  @param nickname 备注
 *  @param username      好友的username
 */
- (void)setNickname:(NSString *)nickname forUser:(NSString *)username{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    [self.xmppRoster setNickname:nickname forUser:JID];
}

#pragma mark - 单聊
/**
 *  发送文字消息
 *
 *  @param text  文本
 *  @param username 对方的username
 */
- (void)sendMessage:(NSString *)text toUser:(NSString *)username{
    XMPPJID *JID = [XMPPJID jidWithUser:username domain:[LTChatConfig sharedInstance].xmppDomain resource:[LTChatConfig sharedInstance].xmppResource];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:JID];
    [message addBody:text];
    [message addSubject:[LTChatConfig sharedInstance].xmppChatSubject];
    [self.xmppStream sendElement:message];
    
}

- (void)sendSignalingMessage:(NSString *)message toUser:(NSString *)jidStr{
    XMPPJID *JID = [XMPPJID jidWithString:jidStr];
    
    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:JID];
    [xmppMessage addBody:message];
    [xmppMessage addSubject:[LTChatConfig sharedInstance].xmppWebrtcSubject];
    
    [self.xmppStream sendElement:xmppMessage];
}

@end
