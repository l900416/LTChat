//
//  LTChatKeyboardView.m
//  LTChatUI
//
//  Created by 梁通 on 2017/10/20.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardView.h"

@interface LTChatKeyboardView()<LTChatKeyboardMoreViewDelegate>

@property (nonatomic, strong) NSLayoutConstraint* toolbarBottomConstraint;

@property (nonatomic, strong) NSArray* moreItemArray;

@end

@implementation LTChatKeyboardView

#pragma mark - initialization
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupInitialization];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitialization];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupInitialization];
    }
    return self;
}

-(void)setupInitialization{
    
    //工具栏
    self.toolbar = [[LTChatKeyboardViewToolbar alloc] init];//Toobar
    [self addSubview:self.toolbar];
    //约束
    [self pinSubview:self.toolbar toEdge:NSLayoutAttributeTop];//Top
    [self pinSubview:self.toolbar toEdge:NSLayoutAttributeLeading];//Leading
    [self pinSubview:self.toolbar toEdge:NSLayoutAttributeTrailing];//Trailing
    _toolbarBottomConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.toolbar
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0f
                                                             constant:0];
    [self addConstraint:_toolbarBottomConstraint];
    
    
    //表情键盘 - 在工具栏下方
    self.faceKeyboard = [[LTChatKeyboardFaceView alloc] init];
    [self addSubview:self.faceKeyboard];
    [self pinSubview:self.toolbar attribute:NSLayoutAttributeLeading subView:self.faceKeyboard attribute:NSLayoutAttributeLeading constant:0];//Leading
    [self pinSubview:self.toolbar attribute:NSLayoutAttributeTrailing subView:self.faceKeyboard attribute:NSLayoutAttributeTrailing constant:0];//Trailing
    [self pinSubview:self.faceKeyboard attribute:NSLayoutAttributeTop subView:self.toolbar attribute:NSLayoutAttributeBottom constant:0];//Top
    [self pinSubview:self.faceKeyboard withAttribute:NSLayoutAttributeHeight constant:LTChatKeyboardFaceViewHeight];//Height
    
    //更多功能 - 在工具栏下方
    _moreItemArray = @[
                       @{@"name":@"照片",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_photo",@"id":@"keyboard_photo"},
                       @{@"name":@"拍摄",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_take_photo",@"id":@"keyboard_take_photo"},
                       @{@"name":@"视频聊天",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_real_time",@"id":@"keyboard_real_time"},
                       @{@"name":@"位置",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_location",@"id":@"keyboard_location"},
                       @{@"name":@"收藏",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_favorite",@"id":@"keyboard_favorite"},
                       @{@"name":@"卡券",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_ticket",@"id":@"keyboard_tickets"},
                       @{@"name":@"红包",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_lucky_mokey",@"id":@"keyboard_tickets"},
                       @{@"name":@"明信片",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_postcard",@"id":@"keyboard_tickets"},
                       @{@"name":@"应用",@"image":@"LTChatUI.bundle/Images/ic_keyboard_more_postcard",@"id":@"keyboard_tickets"},
                       
                       ];
    self.moreKeyboard = [[LTChatKeyboardMoreView alloc] init];
    self.moreKeyboard.delegate = self;
    [self addSubview:self.moreKeyboard];
    
    [self pinSubview:self.toolbar attribute:NSLayoutAttributeLeading subView:self.moreKeyboard attribute:NSLayoutAttributeLeading constant:0];//Leading
    [self pinSubview:self.toolbar attribute:NSLayoutAttributeTrailing subView:self.moreKeyboard attribute:NSLayoutAttributeTrailing constant:0];//Trailing
    [self pinSubview:self.moreKeyboard attribute:NSLayoutAttributeTop subView:self.toolbar attribute:NSLayoutAttributeBottom constant:0];//Top
    [self pinSubview:self.moreKeyboard withAttribute:NSLayoutAttributeHeight constant:LTChatKeyboardMoreViewHeight];//Height
    
    //监听事件
    [self ltRegisterForNotifications:YES];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


//监听事件
-(void)ltRegisterForNotifications:(BOOL)registerForNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if(registerForNotifications){//注册监听
        [center addObserver:self selector:@selector(didReceiveKeyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [center addObserver:self selector:@selector(didReceiveKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(didReceiveFaceKeyboardShowNotification:) name:kLTChatUIKeyboardEmojiKeyboardShowKey object:nil];
        [center addObserver:self selector:@selector(didReceiveFaceKeyboardHideNotification:) name:kLTChatUIKeyboardEmojiKeyboardHideKey object:nil];
        [center addObserver:self selector:@selector(didReceiveMoreKeyboardShowNotification:) name:kLTChatUIKeyboardMoreKeyboardShowKey object:nil];
        [center addObserver:self selector:@selector(didReceiveMoreKeyboardHideNotification:) name:kLTChatUIKeyboardMoreKeyboardHideKey object:nil];
    }else{//取消注册监听
        [center removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    
}
//键盘变更
- (void)didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         _toolbarBottomConstraint.constant = CGRectGetHeight(keyboardEndFrame);
                         [self layoutIfNeeded];
                     }
                     completion:nil];
}
//键盘隐藏
-(void)didReceiveKeyboardWillHideNotification:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         _toolbarBottomConstraint.constant = 0;
                         [self layoutIfNeeded];
                     }completion:nil];
}

//表情键盘
-(void)didReceiveFaceKeyboardShowNotification:(NSNotification *)notification{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _toolbarBottomConstraint.constant = LTChatKeyboardFaceViewHeight;
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self bringSubviewToFront:self.faceKeyboard];
                     }];
}
-(void)didReceiveFaceKeyboardHideNotification:(NSNotification *)notification{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _toolbarBottomConstraint.constant = 0;
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self sendSubviewToBack:self.faceKeyboard];
                     }];
}

//更多功能键盘
-(void)didReceiveMoreKeyboardShowNotification:(NSNotification *)notification{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _toolbarBottomConstraint.constant = LTChatKeyboardMoreViewHeight;
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self bringSubviewToFront:self.moreKeyboard];
                     }];
}
-(void)didReceiveMoreKeyboardHideNotification:(NSNotification *)notification{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _toolbarBottomConstraint.constant = 0;
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self sendSubviewToBack:self.moreKeyboard];
                     }];
}


#pragma mark - LTChatKeyboardMoreViewDelegate

-(NSInteger)numberOfItems{
    NSInteger countPerPage = kLTKeyboardMoreItem_COL * kLTKeyboardMoreItem_ROW;
    NSInteger number = (_moreItemArray.count / countPerPage + 1) * countPerPage;
    return number;
    
}
-(NSDictionary*)itemAtIndex:(NSInteger)index{
    NSInteger countPerPage = kLTKeyboardMoreItem_COL * kLTKeyboardMoreItem_ROW;
    NSInteger page = index / countPerPage;
    
    NSInteger row = index % countPerPage % kLTKeyboardMoreItem_ROW;
    NSInteger col = index % countPerPage / kLTKeyboardMoreItem_ROW;
    
    NSInteger dIndex = page * countPerPage + (row * kLTKeyboardMoreItem_COL + col);
    if (dIndex >= _moreItemArray.count) {
        return nil;
    }else{
        return [_moreItemArray objectAtIndex:dIndex];
    }
}

-(void)didSelectedAtIndex:(NSInteger)index{
    
    
}

#pragma mark - 3v to 1v

@end
