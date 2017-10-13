//
//  LTChatWebRTCView.m
//  LTChatDemo
//
//  Created by 梁通 on 2017/10/10.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatWebRTCView.h"
#import <AVFoundation/AVFoundation.h>
#import "LTChatWebRTCButton.h"
#import "LTChatConfig.h"
#import "LTChatWebRTCClient.h"

#define kRTCWidth       [UIScreen mainScreen].bounds.size.width
#define kRTCHeight      [UIScreen mainScreen].bounds.size.height

#define kRTCRate        ([UIScreen mainScreen].bounds.size.width / 320.0)
// 底部按钮容器的高度
#define kContainerH     (102 * kRTCRate)
// 每个按钮的宽度
#define kBtnW           (60 * kRTCRate)
// 视频聊天时，小窗口的宽
#define kMicVideoW      (80 * kRTCRate)
// 视频聊天时，小窗口的高
#define kMicVideoH      (120 * kRTCRate)

@interface LTChatWebRTCView()<CAAnimationDelegate>
/** 是否是被呼叫方 */
@property (assign, nonatomic)   BOOL                    callee;
/** 是否是外放模式 */
@property (assign, nonatomic)   BOOL                    loudSpeaker;

/** 语音聊天背景视图 */
@property (strong, nonatomic)   UIImageView             *bgImageView;
/** 自己的视频画面 */
@property (strong, nonatomic)   UIImageView             *ownImageView;
/** 对方的视频画面 */
@property (strong, nonatomic)   UIImageView             *adverseImageView;
/** 头像 */
@property (strong, nonatomic)   UIImageView             *portraitImageView;
/** 昵称 */
@property (strong, nonatomic)   UILabel                 *nickNameLabel;
/** 连接状态，如等待对方接听...、对方已拒绝、语音电话、视频电话 */
@property (strong, nonatomic)   UILabel                 *connectLabel;
/** 网络状态提示，如对方网络良好、网络不稳定等 */
@property (strong, nonatomic)   UILabel                 *netTipLabel;
/** 前置、后置摄像头切换按钮 */
@property (strong, nonatomic)   LTChatWebRTCButton               *swichBtn;
/** 底部按钮容器视图 */
@property (strong, nonatomic)   UIView                  *btnContainerView;
/** 静音按钮 */
@property (strong, nonatomic)   LTChatWebRTCButton               *muteBtn;
/** 扬声器按钮 */
@property (strong, nonatomic)   LTChatWebRTCButton               *loudspeakerBtn;

/** 挂断按钮 */
@property (strong, nonatomic)   LTChatWebRTCButton               *hangupBtn;
/** 接听按钮 */
@property (strong, nonatomic)   LTChatWebRTCButton               *answerBtn;

/** 遮罩视图 */
@property (strong, nonatomic)   UIView                  *coverView;
/** 动画用的layer */
@property (strong, nonatomic)   CAShapeLayer            *shapeLayer;

@end

@implementation LTChatWebRTCView

- (instancetype)initWithIsCallee:(BOOL)isCallee{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
        self.callee = isCallee;
        self.isHanged = YES;
        self.clipsToBounds = YES;
        [self setupUI];
    }
    return self;
}

/**
 *  初始化UI
 */
- (void)setupUI{
    self.adverseImageView.backgroundColor = [UIColor lightGrayColor];
    self.ownImageView.backgroundColor = [UIColor grayColor];
    self.portraitImageView.backgroundColor = [UIColor clearColor];
    
    if (self.callee) {// 视频通话时，被呼叫方UI初始化
        [self initUIForVideoCallee];
    } else {// 视频通话时，呼叫方的UI初始化
        [self initUIForVideoCaller];
    }
}

/**
 *  视频通话时，呼叫方的UI设置
 */
- (void)initUIForVideoCaller{
    self.adverseImageView.frame = self.frame;
    [self addSubview:_adverseImageView];
    
    //    self.ownImageView.frame = self.frame;
    self.ownImageView.frame = CGRectMake(kRTCWidth - kMicVideoW - 5 , kRTCHeight - kContainerH - kMicVideoH - 5, kMicVideoW, kMicVideoH);
    [self addSubview:_ownImageView];
    
    CGFloat switchBtnW = 45 * kRTCRate;
    CGFloat topOffset = 30 * kRTCRate;
    self.swichBtn.frame = CGRectMake(kRTCWidth - switchBtnW - 10, topOffset, switchBtnW, switchBtnW);
    [self addSubview:_swichBtn];
    
    self.nickNameLabel.frame = CGRectMake(20, topOffset, kRTCWidth - 20 * 3 - switchBtnW, 30);
    self.nickNameLabel.textColor = [UIColor whiteColor];
    self.nickNameLabel.textAlignment = NSTextAlignmentLeft;
    self.nickNameLabel.text = self.nickName ? :@"昵称";
    [self addSubview:_nickNameLabel];
    
    self.connectLabel.frame = CGRectMake(20, CGRectGetMaxY(self.nickNameLabel.frame), CGRectGetWidth(self.nickNameLabel.frame), 20);
    self.connectLabel.textColor = [UIColor whiteColor];
    self.connectLabel.textAlignment = NSTextAlignmentLeft;
    self.connectLabel.text = self.connectText;
    [self addSubview:_connectLabel];
    
    self.netTipLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.netTipLabel.textColor = [UIColor whiteColor];
    self.netTipLabel.center = self.center;
    [self addSubview:_netTipLabel];
    
    self.btnContainerView.frame = CGRectMake(0, kRTCHeight - kContainerH, kRTCWidth, kContainerH);
    self.btnContainerView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:_btnContainerView];
    
    
    // 下面底部 6按钮视图
    [self initUIForBottomBtns];
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
    
    //    [self loudspeakerClick];
}

/**
 *  视频通话，被呼叫方UI初始化
 */
- (void)initUIForVideoCallee{
    // 上面 通用部分
    [self initUIForTopCommonViews];
    
    CGFloat btnW = kBtnW;
    CGFloat btnH = kBtnW + 20;
    CGFloat paddingX = (kRTCWidth - btnW * 2) / 3;
    CGFloat paddingY = (kContainerH - kBtnW ) / 2;
    self.hangupBtn.frame = CGRectMake(paddingX, paddingY, btnW, btnH);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.answerBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY, btnW, btnH);
    [self.btnContainerView addSubview:_answerBtn];
    
    
    self.coverView.frame = self.frame;
    self.coverView.hidden = YES;
    [self addSubview:_coverView];
}

/**
 *  上半部分通用视图
 *  语音通话呼叫方、语音通话接收方、视频通话接收方上半部分视图布局都一样
 */
- (void)initUIForTopCommonViews{
    CGFloat centerX = self.center.x;
    
    self.bgImageView.frame = self.frame;
    [self addSubview:_bgImageView];
    
    CGFloat portraitW = 130 * kRTCRate;
    self.portraitImageView.frame = CGRectMake(0, 0, portraitW, portraitW);
    self.portraitImageView.center = CGPointMake(centerX, portraitW);
    self.portraitImageView.layer.cornerRadius = portraitW * 0.5;
    self.portraitImageView.layer.masksToBounds = YES;
    [self addSubview:_portraitImageView];
    
    self.nickNameLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.nickNameLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.portraitImageView.frame) + 40);
    self.nickNameLabel.text = self.nickName ? :@"昵称";
    [self addSubview:_nickNameLabel];
    
    self.connectLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.connectLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.nickNameLabel.frame) + 10);
    self.connectLabel.text = self.connectText;
    [self addSubview:_connectLabel];
    
    self.netTipLabel.frame = CGRectMake(0, 0, kRTCWidth, 30);
    self.netTipLabel.center = CGPointMake(centerX, CGRectGetMaxY(self.connectLabel.frame) + 40);
    [self addSubview:_netTipLabel];
    
    self.btnContainerView.frame = CGRectMake(0, kRTCHeight - kContainerH, kRTCWidth, kContainerH);
    [self addSubview:_btnContainerView];
    
}

/**
 *  添加底部6个按钮
 */
- (void)initUIForBottomBtns{
    CGFloat btnW = kBtnW;
    CGFloat paddingX = (self.frame.size.width - btnW * 3) / 4;
    CGFloat paddingY = (kContainerH - kBtnW ) / 2;
    self.muteBtn.frame = CGRectMake(paddingX, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_muteBtn];
    
    self.hangupBtn.frame = CGRectMake(paddingX * 2 + btnW, paddingY, btnW, btnW);
    [self.btnContainerView addSubview:_hangupBtn];
    
    self.loudspeakerBtn.frame = CGRectMake(paddingX * 3 + btnW * 2, paddingY, btnW, btnW);
    self.loudspeakerBtn.selected = self.loudSpeaker;
    [self.btnContainerView addSubview:_loudspeakerBtn];
    
}

- (void)show{
    self.connectLabel.text = @"视频通话";
    
    _portraitImageView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_portraitImageView.frame));
    _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
    _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
    _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
    _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
    
    self.alpha = 0;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _portraitImageView.transform = CGAffineTransformIdentity;
            _nickNameLabel.transform = CGAffineTransformIdentity;
            _connectLabel.transform = CGAffineTransformIdentity;
            _swichBtn.transform = CGAffineTransformIdentity;
            _btnContainerView.transform = CGAffineTransformIdentity;
            
        }];
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:1.0 animations:^{
        _portraitImageView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_portraitImageView.frame));
        _nickNameLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_nickNameLabel.frame));
        _connectLabel.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_connectLabel.frame));
        _swichBtn.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(_swichBtn.frame));
        _btnContainerView.transform = CGAffineTransformMakeTranslation(0, kContainerH);
        
    } completion:^(BOOL finished) {
        [self clearAllSubViews];
        [self removeFromSuperview];
    }];
}

- (void)connected{
    // 视频通话，对方接听以后
    self.loudspeakerBtn.selected = YES;
    [UIView animateWithDuration:0.5 animations:^{
        [self updateFrameOfLocalView:CGRectMake(kRTCWidth - kMicVideoW - 5 , kRTCHeight - kContainerH - kMicVideoH - 5, kMicVideoW, kMicVideoH)];
    } completion:^(BOOL finished) {
        [[LTChatWebRTCClient sharedInstance] resizeViews];
    }];
}

- (void)updateFrameOfLocalView:(CGRect)newFrame{
    self.ownImageView.frame = newFrame;
    for (UIView *subView in self.ownImageView.subviews) {
        Class class = NSClassFromString(@"RTCEAGLVideoView");
        if ([subView isKindOfClass:class]) {
            subView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
            for (UIView *sView in subView.subviews) {
                class = NSClassFromString(@"GLKView");
                if ([sView isKindOfClass:class]) {
                    sView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
                }
            }
        }
    }
}

- (void)updateFrameOfRemoteView:(CGRect)newFrame{
    self.adverseImageView.frame = newFrame;
    for (UIView *subView in self.adverseImageView.subviews) {
        Class class = NSClassFromString(@"RTCEAGLVideoView");
        if ([subView isKindOfClass:class]) {
            subView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
            for (UIView *sView in subView.subviews) {
                class = NSClassFromString(@"GLKView");
                if ([sView isKindOfClass:class]) {
                    sView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
                }
            }
        }
    }
}

- (void)clearAllSubViews{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _bgImageView = nil;
    //    _ownImageView = nil;
    //    _adverseImageView = nil;
    //    _portraitImageView = nil;
    _nickNameLabel = nil;
    _connectLabel = nil;
    _netTipLabel = nil;
    _swichBtn = nil;
    
    [self clearBottomViews];
    
    _coverView = nil;
}

- (void)clearBottomViews{
    _btnContainerView = nil;
    _muteBtn = nil;
    _loudspeakerBtn = nil;
    _hangupBtn = nil;
    _answerBtn = nil;
}


#pragma mark - 按钮点击事件

- (void)switchClick{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_WEBRTC_SWITCH_CAMERA_NOTIFICATION object:nil];
}

- (void)muteClick{
    NSLog(@"静音%s",__func__);
    if (!self.muteBtn.selected) {
        self.muteBtn.selected = YES;
    } else {
        self.muteBtn.selected = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_WEBRTC_MUTE_NOTIFICATION object:@{@"isMute":@(self.muteBtn.selected)}];
}


- (void)loudspeakerClick{
    NSLog(@"外放声音%s",__func__);
    if (!self.loudspeakerBtn.selected) {
        self.loudspeakerBtn.selected = YES;
        self.loudSpeaker = YES;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    } else {
        self.loudspeakerBtn.selected = NO;
        self.loudSpeaker = NO;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }
}


- (void)hangupClick{
    if (self.isHanged) {
        self.coverView.hidden = NO;
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0];
    } else {
        [self dismiss];
    }
    
    NSDictionary *dict = @{@"isVideo":@YES,@"isCaller":@(!self.callee),@"answered":@(self.answered)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_WEBRTC_HANGUP_NOTIFICATION object:dict];
}


/**
 *  接听按钮操作
 */
- (void)answerClick{
    self.answered = YES;
    NSDictionary *dict = nil;
    
    [self clearAllSubViews];
    // 视频通话接听之后，UI布局与呼叫方一样
    [self initUIForVideoCaller];
    // 执行一个小动画
    [self connected];
    dict = @{@"isVideo":@(YES),@"audioAccept":@(NO)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_WEBRTC_ACCEPT_NOTIFICATION object:dict];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.frame;
        rect.origin = self.portraitImageView.frame.origin;
        self.bounds = rect;
        rect.size = self.portraitImageView.frame.size;
        self.frame = rect;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.center = CGPointMake(kRTCWidth - 60, kRTCHeight - 80);
            self.transform = CGAffineTransformMakeScale(0.5, 0.5);
            
        } completion:^(BOOL finished) {
            
        }];
    } else if ([anim isEqual:[self.shapeLayer animationForKey:@"showAnimation"]]) {
        self.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - 懒加载
- (UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"im_skin_icon_audiocall_bg.jpg"]];
    }
    
    return _bgImageView;
}

- (UIImageView *)adverseImageView{
    if (!_adverseImageView) {
        _adverseImageView = [[UIImageView alloc] init];
    }
    
    return _adverseImageView;
}

- (UIImageView *)ownImageView{
    if (!_ownImageView) {
        _ownImageView = [[UIImageView alloc] init];
    }
    
    return _ownImageView;
}

- (UIImageView *)portraitImageView{
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
    }
    
    return _portraitImageView;
}

- (UILabel*)nickNameLabel{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = @"昵称";
        _nickNameLabel.font = [UIFont systemFontOfSize:17.0f];
        _nickNameLabel.textColor = [UIColor darkGrayColor];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _nickNameLabel;
}

- (UILabel*)connectLabel{
    if (!_connectLabel) {
        _connectLabel = [[UILabel alloc] init];
        _connectLabel.text = @"等待对方接听...";
        _connectLabel.font = [UIFont systemFontOfSize:15.0f];
        _connectLabel.textColor = [UIColor grayColor];
        _connectLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _connectLabel;
}

- (LTChatWebRTCButton *)swichBtn{
    if (!_swichBtn) {
        _swichBtn = [[LTChatWebRTCButton alloc] initWithTitle:nil noHandleImageName:@"icon_avp_camera_white"];
        [_swichBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _swichBtn;
}

- (UILabel*)netTipLabel{
    if (!_netTipLabel) {
        _netTipLabel = [[UILabel alloc] init];
        _netTipLabel.text = @"对方网络良好";
        _netTipLabel.font = [UIFont systemFontOfSize:13.0f];
        _netTipLabel.textColor = [UIColor grayColor];
        _netTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _netTipLabel;
}

- (UIView *)btnContainerView{
    if (!_btnContainerView) {
        _btnContainerView = [[UIView alloc] init];
    }
    return _btnContainerView;
}

- (LTChatWebRTCButton *)muteBtn{
    if (!_muteBtn) {
        _muteBtn = [[LTChatWebRTCButton alloc] initWithTitle:@"静音" imageName:@"icon_avp_mute" isVideo:YES];
        [_muteBtn addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _muteBtn;
}


- (LTChatWebRTCButton *)loudspeakerBtn{
    if (!_loudspeakerBtn) {
        _loudspeakerBtn = [[LTChatWebRTCButton alloc] initWithTitle:@"扬声器" imageName:@"icon_avp_loudspeaker" isVideo:YES];
        [_loudspeakerBtn addTarget:self action:@selector(loudspeakerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _loudspeakerBtn;
}


- (LTChatWebRTCButton *)hangupBtn{
    if (!_hangupBtn) {
        if (_callee && !_answered) {
            _hangupBtn = [[LTChatWebRTCButton alloc] initWithTitle:@"拒绝"  noHandleImageName:@"icon_call_reject_normal"];
        } else {
            _hangupBtn = [[LTChatWebRTCButton alloc] initWithTitle:nil noHandleImageName:@"icon_call_reject_normal"];
        }
        
        [_hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupBtn;
}


- (LTChatWebRTCButton *)answerBtn{
    if (!_answerBtn) {
        _answerBtn = [[LTChatWebRTCButton alloc] initWithTitle:@"接听" noHandleImageName:@"icon_audio_receive_normal"];
        [_answerBtn addTarget:self action:@selector(answerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerBtn;
}



- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    
    return _coverView;
}

#pragma mark - property setter
- (void)setNickName:(NSString *)nickName{
    _nickName = nickName;
    self.nickNameLabel.text = _nickName;
}

- (void)setConnectText:(NSString *)connectText{
    _connectText = connectText;
    self.connectLabel.text = connectText;
}

- (void)setNetTipText:(NSString *)netTipText{
    _netTipText = netTipText;
    self.netTipLabel.text = _netTipText;
}

- (void)setAnswered:(BOOL)answered{
    _answered = answered;
    if (!self.callee) {
        [self connected];
    }
}
@end
