//
//  LTChatKeyboardView.h
//  LTChatUI
//
//  Created by 梁通 on 2017/10/20.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTChatKeyboardViewToolbar.h"//工具键盘
#import "LTChatKeyboardMoreView.h"//更多键盘


@protocol LTChatKeyboardDelegate <NSObject>

@end

/**
 * 聊天键盘
 **/
@interface LTChatKeyboardView : UIView

//Delegate
@property (nonatomic, strong) id<LTChatKeyboardDelegate> delegate;

//键盘工具区，包含声音、文本框、表情、更多功能键
@property (nonatomic, strong) LTChatKeyboardViewToolbar* toolbar;



//更多功能键盘
@property (nonatomic, strong) LTChatKeyboardMoreView* moreKeyboard;

@end
