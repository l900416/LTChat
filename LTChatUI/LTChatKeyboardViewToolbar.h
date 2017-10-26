//
//  LTChatKeyboardViewToolbar.h
//  LTChatUI
//
//  Created by 梁通 on 2017/10/20.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTChatUIConfig.h"

@interface LTChatKeyboardViewToolbar : UIView

//声音
@property (nonatomic, strong) UIButton* voiceBtn;
//中间 - 文本框／声音输入框
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UIButton* voiceInputBtn;
//表情
@property (nonatomic, strong) UIButton* emojiBtn;
//更多
@property (nonatomic, strong) UIButton* moreBtn;



@end
