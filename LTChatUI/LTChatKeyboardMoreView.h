//
//  LTChatKeyboardMoreView.h
//  LTChatUI
//
//  Created by 梁通 on 2017/10/23.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTChatUIConfig.h"

#define kLTKeyboardMoreItem_COL 4
#define kLTKeyboardMoreItem_ROW 2

/**
 * 更多功能协议，包括数据源和操作
 **/
@protocol LTChatKeyboardMoreViewDelegate<NSObject>

-(NSInteger)numberOfItems;
-(NSDictionary*)itemAtIndex:(NSInteger)index;
-(void)didSelectedAtIndex:(NSInteger)index;

@end

/**
 * 更多功能键盘，包括照片、拍摄、视频聊天、位置等
 **/
@interface LTChatKeyboardMoreView : UIView

@property (nonatomic, strong) id <LTChatKeyboardMoreViewDelegate> delegate;


@end
