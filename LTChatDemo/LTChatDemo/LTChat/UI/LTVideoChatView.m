//
//  LTVideoChatView.m
//  LTChatDemo
//
//  Created by 梁通 on 2017/10/13.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTVideoChatView.h"
#import "LTChatConfig.h"
#import <AVFoundation/AVFoundation.h>
#import "LTChatWebRTCClient.h"

@interface LTVideoChatView()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;


//Caller的操作页面，只有一个取消按钮
@property (weak, nonatomic) IBOutlet UIView *callerActionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;//取消

//Callee的操作页面，有接收和拒绝两个按钮
@property (weak, nonatomic) IBOutlet UIView *calleeActionView;

@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;//接听
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;//拒绝

//通话画面，有静音、挂断、摄像头切换三个按钮
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;//静音
@property (weak, nonatomic) IBOutlet UIButton *hangupBtn;//挂断
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;//切换摄像头


//标记位，用于区分是否是被呼叫方
@property (assign, nonatomic)   BOOL                    callee;

@end

@implementation LTVideoChatView

- (void)setupWithIsCallee:(BOOL)isCallee{
    [self setFrame:[UIScreen mainScreen].bounds];
    self.callee = isCallee;
    self.isHanged = YES;
    self.clipsToBounds = YES;
    [self setupUI];
}

/**
 *  初始化UI
 */
- (void)setupUI{
    //初始化本地、远程窗口颜色／或者所在层级
    
    self.remoteView.hidden = YES;
    
    //操作相关的View进行操作
    self.actionView.hidden = YES;
    
    if (self.callee) {// 视频通话时，被呼叫方UI初始化
        self.calleeActionView.hidden = NO;
        self.callerActionView.hidden = YES;
    } else {// 视频通话时，呼叫方的UI初始化
        self.calleeActionView.hidden = YES;
        self.callerActionView.hidden = NO;
    }
    
    //给Button绑定事件
    [self.cancelBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.acceptBtn addTarget:self action:@selector(answerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.rejectBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.muteBtn addTarget:self action:@selector(muteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.hangupBtn addTarget:self action:@selector(hangupClick) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn addTarget:self action:@selector(switchClick) forControlEvents:UIControlEventTouchUpInside];
}


- (void)show{
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:1.0 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)connected{
    self.remoteView.hidden = NO;
    // 视频通话，对方接听以后
    [[LTChatWebRTCClient sharedInstance] resizeViews];
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


- (void)hangupClick{
    if (self.isHanged) {
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
    
    
    self.actionView.hidden = NO;
    self.callerActionView.hidden = YES;
    self.calleeActionView.hidden = YES;
    
    // 执行一个小动画
    [self connected];
    dict = @{@"isVideo":@(YES),@"audioAccept":@(NO)};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTCHAT_WEBRTC_ACCEPT_NOTIFICATION object:dict];
}


#pragma mark - property setter

- (void)setTipText:(NSString *)tipText{
    _tipText = tipText;
}

- (void)setAnswered:(BOOL)answered{
    _answered = answered;
    if (!self.callee) {
        [self connected];
    }
}

@end
