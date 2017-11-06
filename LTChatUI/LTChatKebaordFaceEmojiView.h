//
//  LTChatKebaordFaceEmojiView.h
//  LTChatUI
//
//  Created by 梁通 on 2017/11/6.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTChatUIConfig.h"


#define kLTKeyboardFaceEmojiItem_ROW 4
#define kLTKeyboardFaceEmojiItem_COL 8

/**
 * 更多功能协议，包括数据源和操作
 **/
@protocol LTChatKeyboardFaceEmojiViewDelegate<NSObject>

-(NSInteger)numberOfEmojis;
-(NSString*)emojiAtIndex:(NSInteger)index;
-(void)didSelectedEmojiAtIndex:(NSInteger)index;

@end

/**
 * 表情键盘 - Emoji
 **/
@interface LTChatKebaordFaceEmojiView : UIView

@property (nonatomic, strong) id <LTChatKeyboardFaceEmojiViewDelegate> delegate;

-(void)reloadEmojis;

@end
