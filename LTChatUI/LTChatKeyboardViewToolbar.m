//
//  LTChatKeyboardViewToolbar.m
//  LTChatUI
//
//  Created by 梁通 on 2017/10/20.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardViewToolbar.h"


@interface LTChatKeyboardViewToolbar()<UITextViewDelegate>

//文本框高度
@property (nonatomic, strong) NSLayoutConstraint* textHeightConstraint;

@end

@implementation LTChatKeyboardViewToolbar

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
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.7f;
    self.clipsToBounds = YES;
    
    
    // Add Constant - 添加约束
    //Voice Button Constant - 在工具栏左下位置
    [self pinSubview:self.voiceBtn toEdge:NSLayoutAttributeLeading withConstant:-LTChatKeyboardPadding];//Leading
    [self pinSubview:self.voiceBtn toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.voiceBtn withAttribute:NSLayoutAttributeWidth constant:LTChatKeyboardToolbarBtnHeight];//With
    [self squareSubview:self.voiceBtn];//Square
    
    //TextView Constant - 声音按钮右侧，表情按钮左侧，工具栏上下对齐
    [self pinSubview:self.textView toEdge:NSLayoutAttributeTop withConstant:-LTChatKeyboardPadding];//Top
    [self pinSubview:self.textView attribute:NSLayoutAttributeLeading subView:self.voiceBtn attribute:NSLayoutAttributeTrailing constant:LTChatKeyboardPadding];//Leading
    [self pinSubview:self.textView toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.textView attribute:NSLayoutAttributeTrailing subView:self.emojiBtn attribute:NSLayoutAttributeLeading constant:-LTChatKeyboardPadding];//Trailing
    self.textView.delegate = self;
    
    //Voice Input Button - 与文本框相同
    [self pinSubview:self.voiceInputBtn attribute:NSLayoutAttributeLeading subView:self.textView attribute:NSLayoutAttributeLeading constant:0];//Leading
    [self pinSubview:self.voiceInputBtn attribute:NSLayoutAttributeTrailing subView:self.textView attribute:NSLayoutAttributeTrailing constant:0];//Trailing
    [self pinSubview:self.voiceInputBtn attribute:NSLayoutAttributeTop subView:self.textView attribute:NSLayoutAttributeTop constant:0];//Top
    [self pinSubview:self.voiceInputBtn attribute:NSLayoutAttributeBottom subView:self.textView attribute:NSLayoutAttributeBottom constant:0];//Bottom
    
    //Emijo Button Constant - 文本框右侧，更多按钮左侧
    //Leading has been setup
    [self pinSubview:self.emojiBtn toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.emojiBtn withAttribute:NSLayoutAttributeWidth constant:LTChatKeyboardToolbarBtnHeight];//With
    [self squareSubview:self.emojiBtn];//Square
    
    //More Button Constant - 表情按钮右侧，工具栏左侧
    [self pinSubview:self.moreBtn attribute:NSLayoutAttributeLeading subView:self.emojiBtn attribute:NSLayoutAttributeTrailing constant:LTChatKeyboardPadding];//Leading
    [self pinSubview:self.moreBtn toEdge:NSLayoutAttributeBottom withConstant:LTChatKeyboardPadding];//Bottom
    [self pinSubview:self.moreBtn withAttribute:NSLayoutAttributeWidth constant:LTChatKeyboardToolbarBtnHeight];//With
    [self squareSubview:self.moreBtn];//Square
    [self pinSubview:self.moreBtn toEdge:NSLayoutAttributeTrailing withConstant:LTChatKeyboardPadding];//Trailing
    
    
    NSArray* layerArray = @[_textView,_voiceInputBtn];
    for (UIView* subview in layerArray) {
        [self addLayerOnSubView:subview];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Action
//CASE 1: Vt=0,Et=0,Mt=0 普通模式，下方键盘显示
//CASE 2: Vt=1,Et=0,Mt=0 录音时，下方键盘隐藏
//CASE 3: Vt=0,Et=1,Mt=0 输入表情符号，下方表情符号键盘
//CASE 4: Vt=0,Et=0,Mt=1 更多功能键盘
-(void)toolbarButtonPressed:(UIButton*)btn{
    if ([btn isEqual:_voiceBtn]) {
        _voiceBtn.tag = 1 - _voiceBtn.tag;
        _emojiBtn.tag = 0;
        _moreBtn.tag = 0;
    }else if ([btn isEqual:_emojiBtn]){
        _emojiBtn.tag = 1 - _emojiBtn.tag;
        _voiceBtn.tag = 0;
        _moreBtn.tag = 0;
    }else if([btn isEqual:_moreBtn]){
        _moreBtn.tag = 1 - _moreBtn.tag;
        _voiceBtn.tag = 0;
        _emojiBtn.tag = 0;
    }
    
    if (_voiceBtn.tag == 0 && _emojiBtn.tag == 0 && _moreBtn.tag == 0) {//CASE 1 : 普通模式
        _textView.hidden = NO;
        _voiceInputBtn.hidden = YES;
        [_textView becomeFirstResponder];
    }else if (_voiceBtn.tag == 1 && _emojiBtn.tag == 0 && _moreBtn.tag == 0) {//CASE 2 : 录音模式
        _textView.hidden = YES;
        _voiceInputBtn.hidden = NO;
        [_textView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTChatUIKeyboardMoreKeyboardHideKey object:nil];
    }else if (_voiceBtn.tag == 0 && _emojiBtn.tag == 1 && _moreBtn.tag == 0) {//CASE 3 : 表情符号模式
        _textView.hidden = NO;
        _voiceInputBtn.hidden = YES;
        [_textView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTChatUIKeyboardEmojiKeyboardShowKey object:nil];
    }else if (_voiceBtn.tag == 0 && _emojiBtn.tag == 0 && _moreBtn.tag == 1) {//CASE 3 : 更多模式
        _textView.hidden = NO;
        _voiceInputBtn.hidden = YES;
        [_textView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLTChatUIKeyboardMoreKeyboardShowKey object:nil];
    }
    
    NSLog(@"======= Button TAG =======");
    NSLog(@"\nVoice:%td\nEmoji:%td\nMore:%td",_voiceBtn.tag,_emojiBtn.tag,_moreBtn.tag);
    NSLog(@"======= Button TAG =======");
    [self updateVoiceAndEmojiBtn];
}

//更新图标
-(void)updateVoiceAndEmojiBtn{
    if (_voiceBtn.tag == 0) {
        [_voiceBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_record"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_record_selected"] forState:UIControlStateNormal];
    }else{
        [_voiceBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_keyboard"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_keyboard_selected"] forState:UIControlStateNormal];
    }
    if (_emojiBtn.tag == 0) {
        [_emojiBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_emoji"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_emoji_selected"] forState:UIControlStateNormal];
    }else{
        [_emojiBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_keyboard"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_keyboard_selected"] forState:UIControlStateNormal];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    //输入框成为焦点的时候，设置为模式一
    _voiceBtn.tag = 0;
    _emojiBtn.tag = 0;
    _moreBtn.tag = 0;
    [self updateVoiceAndEmojiBtn];
    return YES;
}

//声音按钮。
-(UIButton*)voiceBtn{
    if (!_voiceBtn) {
        _voiceBtn = [[UIButton alloc] init];
        _voiceBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_voiceBtn];
        //UI-样式
        _voiceBtn.tag = 0;
        [self updateVoiceAndEmojiBtn];
        [_voiceBtn addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

//文本输入框。
-(UITextView*)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_textView];
        //UI-样式
        [_textView addConstraint:self.textHeightConstraint];
        _textView.font = [UIFont systemFontOfSize:17];
    }
    
    return _textView;
}

-(UIButton*)voiceInputBtn{
    if (!_voiceInputBtn) {
        _voiceInputBtn = [[UIButton alloc] init];
        _voiceInputBtn.translatesAutoresizingMaskIntoConstraints = NO;
        _voiceInputBtn.hidden = YES;
        [self addSubview:_voiceInputBtn];
        [_voiceInputBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_voiceInputBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_voiceInputBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_voiceInputBtn setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    }
    return _voiceInputBtn;
    
}

-(UIButton*)emojiBtn{
    if (!_emojiBtn) {
        _emojiBtn = [[UIButton alloc] init];
        _emojiBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_emojiBtn];
        //UI-样式
        _emojiBtn.tag = 0;
        [self updateVoiceAndEmojiBtn];
        
        [_emojiBtn addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
    
}

-(UIButton*)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        _moreBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_moreBtn];
        _moreBtn.tag = 0;
        //UI-样式
        [_moreBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_more"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage imageNamed:@"LTChatUI.bundle/Images/ic_chatBar_more_selected"] forState:UIControlStateNormal];
        
        [_moreBtn addTarget:self action:@selector(toolbarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
    
}

-(NSLayoutConstraint*)textHeightConstraint{
    if (!_textHeightConstraint) {
        _textHeightConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0f
                                                              constant:LTChatKeyboardToolbarDefaultTextViewHeight];
    }
    return _textHeightConstraint;
    
}

@end
