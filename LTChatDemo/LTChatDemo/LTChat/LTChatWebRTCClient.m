//
//  LTChatWebRTCClient.m
//  LTChatDemo
//
//  Created by liangtong on 2017/10/9.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatWebRTCClient.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "LTChatXMPPClient.h"

@interface LTChatWebRTCClient()<RTCPeerConnectionDelegate,RTCEAGLVideoViewDelegate>
@property (strong, nonatomic)   RTCPeerConnectionFactory            *peerConnectionFactory;
@property (nonatomic, strong)   RTCMediaConstraints                 *pcConstraints;
@property (nonatomic, strong)   RTCMediaConstraints                 *sdpConstraints;
@property (nonatomic, strong)   RTCMediaConstraints                 *videoConstraints;
@property (nonatomic, strong)   RTCPeerConnection                   *peerConnection;

@property (nonatomic, strong)   RTCEAGLVideoView                    *localVideoView;
@property (nonatomic, strong)   RTCEAGLVideoView                    *remoteVideoView;
@property (nonatomic, strong)   RTCVideoTrack                       *localVideoTrack;
@property (nonatomic, strong)   RTCVideoTrack                       *remoteVideoTrack;

@property (strong, nonatomic)   AVAudioPlayer               *audioPlayer;  /**< 音频播放器 */
@property (nonatomic, strong)   CTCallCenter                *callCenter;

@property (strong, nonatomic)   NSMutableArray              *ICEServers;

@property (strong, nonatomic)   NSMutableArray              *messages;  /**< 信令消息队列 */

@property (assign, nonatomic)   BOOL                        HaveSentCandidate;  /**< 已发送候选 */

@end
@implementation LTChatWebRTCClient

static LTChatWebRTCClient *_instance;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LTChatWebRTCClient alloc] init];
        _instance.ICEServers = [NSMutableArray array];
        _instance.messages = [NSMutableArray array];
        // 添加STUN 服务器
        //        [_instance.ICEServers addObject:[instance defaultSTUNServer]];
        [_instance addNotifications];
        [_instance startEngine];
        
    });
    return _instance;
}
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hangupEvent:) name:kLTCHAT_WEBRTC_HANGUP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSignalingMessage:) name:kLTCHAT_XMPP_WEBRTC_MESSAGE_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptAction) name:kLTCHAT_WEBRTC_ACCEPT_NOTIFICATION object:nil];
}

- (void)startEngine{
    //set RTCPeerConnection's constraints
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
    
    //注意mandatoryConstraints和optionalConstraints，其中optionalConstraints必须设置，否则在设置remoteSDP的时候会发生错误
    self.pcConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{
                                                                                     kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,
                                                                                     kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue}
                                                               optionalConstraints:@{@"DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueFalse}];
    
    //set SDP's Constraints in order to (offer/answer)
    self.sdpConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{
                                                                                      kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue}
                                                                optionalConstraints:nil];
    
    //set RTCVideoSource's(localVideoSource) constraints
    self.videoConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:nil];
}

- (void)stopEngine{
    [_peerConnectionFactory stopAecDump];
    _peerConnectionFactory = nil;
}

- (void)showRTCViewByRemoteName:(NSString *)remoteName isVideo:(BOOL)isVideo isCaller:(BOOL)isCaller{
    // 1.显示视图
    self.rtcView = [[LTChatWebRTCView alloc] initWithIsCallee:!isCaller];
    self.rtcView.nickName = remoteName;
    self.rtcView.connectText = @"等待对方接听";
    self.rtcView.netTipText = @"网络状况良好";
    [self.rtcView show];
    
    // 2.播放声音
    NSURL *audioURL;
    if (isCaller) {
        audioURL = [[NSBundle mainBundle] URLForResource:@"AVChat_waitingForAnswer.mp3" withExtension:nil];
    }else{
        audioURL = [[NSBundle mainBundle] URLForResource:@"AVChat_incoming.mp3" withExtension:nil];
    }
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    _audioPlayer.numberOfLoops = -1;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    // 3.拨打时，禁止黑屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // 4.监听系统电话
    [self listenSystemCall];
    
    // 5.做RTC必要设置
    if (isCaller) {
        //在开启webRTC通话前，发送消息
        [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcCall}];
    } else {
        // 如果是接收者，就要处理信令信息，创建一个answer
        NSLog(@"如果是接收者，就要处理信令信息");
        self.rtcView.connectText = isVideo ? @"视频通话":@"语音通话";
    }
}

/*开启WebRTC交互*/
-(void)startWebRTCCaller{
    [self initRTCSetting];
    // 如果是发起者，创建一个offer信令
    [self.peerConnection offerForConstraints:self.sdpConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            NSLog(@"创建SessionDescription 失败");
        } else {
            NSLog(@"创建SessionDescription 成功");
            [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                
            }];
            NSString* type = [RTCSessionDescription stringForType:sdp.type];
            NSDictionary *jsonDict = @{ @"type" : type, @"sdp" : sdp.sdp };
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[LTChatXMPPClient sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJID];
        }
    }];
    
}

/**
 *  关于RTC 的设置
 */
- (void)initRTCSetting{
    RTCConfiguration* config = [[RTCConfiguration alloc] init];
    if (_ICEServers) {
        config.iceServers = _ICEServers;
    }
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:config constraints:self.pcConstraints delegate:self];
    NSLog(@"Peer connection created");
    //设置 local media stream
    RTCMediaStream *mediaStream = [self.peerConnectionFactory mediaStreamWithStreamId:@"ARDAMS"];
    // 添加 local video track
    RTCAVFoundationVideoSource *source = [self.peerConnectionFactory avFoundationVideoSourceWithConstraints:self.videoConstraints];
    RTCVideoTrack *localVideoTrack = [self.peerConnectionFactory videoTrackWithSource:source trackId:@"AVAMSv0"];
    [mediaStream addVideoTrack:localVideoTrack];
    self.localVideoTrack = localVideoTrack;
    
    // 添加 local audio track
    RTCAudioTrack *localAudioTrack = [self.peerConnectionFactory audioTrackWithTrackId:@"ARDAMSa0"];
    [mediaStream addAudioTrack:localAudioTrack];
    // 添加 mediaStream
    [self.peerConnection addStream:mediaStream];
    
    NSLog(@"Create Local Media Stream");
    
    RTCEAGLVideoView *localVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.rtcView.ownImageView.bounds];
    localVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    localVideoView.delegate = self;
    [self.rtcView.ownImageView addSubview:localVideoView];
    self.localVideoView = localVideoView;
    
    [self.localVideoTrack addRenderer:self.localVideoView];
    
    RTCEAGLVideoView *remoteVideoView = [[RTCEAGLVideoView alloc] initWithFrame:self.rtcView.adverseImageView.bounds];
    remoteVideoView.transform = CGAffineTransformMakeScale(-1, 1);
    remoteVideoView.delegate = self;
    [self.rtcView.adverseImageView addSubview:remoteVideoView];
    self.remoteVideoView = remoteVideoView;
}

- (void)cleanCache{
    // 1.将试图置为nil
    self.rtcView = nil;
    
    // 2.将音乐停止
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
    _audioPlayer = nil;
    
    // 3.取消手机常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // 4.取消系统电话监听
    self.callCenter = nil;
    
    _peerConnection = nil;
    _localVideoTrack = nil;
    _remoteVideoTrack = nil;
    _localVideoView = nil;
    _remoteVideoView = nil;
    _HaveSentCandidate = NO;
}

- (void)listenSystemCall{
    self.callCenter = [[CTCallCenter alloc] init];
    self.callCenter.callEventHandler = ^(CTCall* call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected]){
            NSLog(@"Call has been disconnected");
        }else if ([call.callState isEqualToString:CTCallStateConnected]){
            NSLog(@"Call has just been connected");
        }else if([call.callState isEqualToString:CTCallStateIncoming]){
            NSLog(@"Call is incoming");
        }else if ([call.callState isEqualToString:CTCallStateDialing]){
            NSLog(@"call is dialing");
        }else{
            NSLog(@"Nothing is done");
        }
    };
}

- (void)resizeViews{
    [self videoView:self.localVideoView didChangeVideoSize:self.rtcView.ownImageView.bounds.size];
    [self videoView:self.remoteVideoView didChangeVideoSize:self.rtcView.adverseImageView.bounds.size];
}

#pragma mark - notification events
- (void)hangupEvent:(NSNotification *)notification{
    
    NSDictionary* dict = [notification object];
    BOOL isCaller = [[dict objectForKey:@"isCaller"] boolValue];
    BOOL answered = [[dict objectForKey:@"answered"] boolValue];
    if (isCaller) {//呼叫者
        if (answered) {//已经接通，则发送停止
            [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcStop}];
        }else{//未接通，应该发送取消
            [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcCancel}];
        }
    }else{
        if (answered) {//已经接通，则发送停止
            [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcStop}];
        }else{//未接通，应该发送拒绝
            [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcReject}];
        }
    }
}

- (void)receiveSignalingMessage:(NSNotification *)notification{
    NSDictionary *dict = [notification object];
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"offer"]) {
        [self showRTCViewByRemoteName:self.remoteJID isVideo:YES isCaller:NO];
        
        [self.messages insertObject:dict atIndex:0];
    } else if ([type isEqualToString:@"answer"]) {
        RTCSessionDescription *sdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:dict[@"sdp"]];
        //        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
        [self.peerConnection setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
            
        }];
    } else if ([type isEqualToString:@"candidate"]) {
        
        [self.messages addObject:dict];
    } else if ([type isEqualToString:[LTChatConfig sharedInstance].webrtcStop] || [type isEqualToString:[LTChatConfig sharedInstance].webrtcReject] || [type isEqualToString:[LTChatConfig sharedInstance].webrtcCancel]) {
        NSLog(@"接收到了挂断／拒绝的消息，则直接发送停止的消息给对方");
        //        [self processMessageDict:dict];
        [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcStop}];
    }else if ([type isEqualToString:[LTChatConfig sharedInstance].webrtcCall]){
        [self processMessageDict:@{@"type":[LTChatConfig sharedInstance].webrtcAccept}];
    }else if ([type isEqualToString:[LTChatConfig sharedInstance].webrtcAccept]){
        [self startWebRTCCaller];
    }
}

- (void)acceptAction{
    [self.audioPlayer stop];
    
    [self initRTCSetting];
    
    NSLog(@"%@",self.remoteVideoView);
    
    
    
    for (NSDictionary *dict in self.messages) {
        [self processMessageDict:dict];
    }
    
    [self.messages removeAllObjects];
    
}

- (void)processMessageDict:(NSDictionary *)dict{
    NSString *type = dict[@"type"];
    if ([type isEqualToString:@"offer"]) {
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:dict[@"sdp"]];
        __weak __typeof(self) weakSelf = self;
        [self.peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.peerConnection answerForConstraints:strongSelf.sdpConstraints completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"创建SessionDescription 失败");
                } else {
                    NSLog(@"创建SessionDescription 成功");
                    [strongSelf.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                        
                    }];
                    NSString* type = [RTCSessionDescription stringForType:sdp.type];
                    NSDictionary *jsonDict = @{ @"type" : type, @"sdp" : sdp.sdp };
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
                    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    
                    [[LTChatXMPPClient sharedInstance] sendSignalingMessage:jsonStr toUser:weakSelf.remoteJID];
                }
            }];
            
        }];
        
    } else if ([type isEqualToString:@"answer"]) {
        RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:dict[@"sdp"]];
        [self.peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            
        }];
        
    } else if ([type isEqualToString:@"candidate"]) {
        NSString *mid = [dict objectForKey:@"id"];
        int sdpLineIndex = [[dict objectForKey:@"label"] intValue];
        NSString *sdp = [dict objectForKey:@"sdp"];
        RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp
                                                            sdpMLineIndex:sdpLineIndex
                                                                   sdpMid:mid];
        
        [self.peerConnection addIceCandidate:candidate];
    } else if ([type isEqualToString:[LTChatConfig sharedInstance].webrtcStop] || [type isEqualToString:[LTChatConfig sharedInstance].webrtcReject] || [type isEqualToString:[LTChatConfig sharedInstance].webrtcCancel]) {
        
        if (self.rtcView) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            if (jsonStr.length > 0) {
                [[LTChatXMPPClient sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJID];
            }
            
            [self.rtcView dismiss];
            
            [self cleanCache];
        }
    }else if ([type isEqualToString:[LTChatConfig sharedInstance].webrtcCall] || [type isEqualToString:[LTChatConfig sharedInstance].webrtcAccept]){
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonStr.length > 0) {
            [[LTChatXMPPClient sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJID];
        }
    }
}

#pragma mark - RTCPeerConnectionDelegate
// Triggered when the SignalingState changed.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged{
    NSLog(@"信令状态改变 %td", stateChanged);
}

// Triggered when media is received on a new stream from remote peer.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream{
    NSLog(@"已添加多媒体流");
    NSLog(@"Received %lu video tracks and %lu audio tracks",(unsigned long)stream.videoTracks.count,(unsigned long)stream.audioTracks.count);
    if ([stream.videoTracks count]) {
        self.remoteVideoTrack = nil;
        [self.remoteVideoView renderFrame:nil];
        self.remoteVideoTrack = stream.videoTracks[0];
        [self.remoteVideoTrack addRenderer:self.remoteVideoView];
    }
    
    [self videoView:self.remoteVideoView didChangeVideoSize:self.rtcView.adverseImageView.bounds.size];
    [self videoView:self.localVideoView didChangeVideoSize:self.rtcView.ownImageView.bounds.size];
}

// Triggered when a remote peer close a stream.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream{
    NSLog(@"a remote peer close a stream");
}

// Triggered when renegotiation is needed, for example the ICE has restarted.

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection{
    NSLog(@"WARNING:Renegotiation needed but unimplemented");
}

// Called any time the ICEConnectionState changes.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState{
    NSLog(@"%s",__func__);
    NSLog(@"ICE state changed: %td", newState);
}

// Called any time the ICEGatheringState changes.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState{
    NSLog(@"ICE gathering state changed: %td", newState);
}

// New Ice candidate have been found.
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    if (self.HaveSentCandidate) {
        return;
    }
    NSLog(@"新的 Ice candidate 被发现.");
    
    NSDictionary *jsonDict = @{@"type":@"candidate",
                               @"label":[NSNumber numberWithInteger:candidate.sdpMLineIndex],
                               @"id":candidate.sdpMid,
                               @"sdp":candidate.sdp
                               };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
    if (jsonData.length > 0) {
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [[LTChatXMPPClient sharedInstance] sendSignalingMessage:jsonStr toUser:self.remoteJID];
        self.HaveSentCandidate = YES;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates{
    NSLog(@"%s",__func__);
}
// New data channel has been opened.
- (void)peerConnection:(RTCPeerConnection*)peerConnection
    didOpenDataChannel:(RTCDataChannel*)dataChannel{
    NSLog(@"New data channel has been opened.");
}


#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView*)videoView didChangeVideoSize:(CGSize)size{
    if (videoView == self.localVideoView) {
        NSLog(@"local size === %@",NSStringFromCGSize(size));
    }else if (videoView == self.remoteVideoView){
        NSLog(@"remote size === %@",NSStringFromCGSize(size));
    }
}


@end
