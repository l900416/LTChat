//
//  LTVideoChatView.h
//  LTChatDemo
//
//  Created by 梁通 on 2017/10/13.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTVideoChatView : UIView

@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *localView;

/** 是否是被挂断 */
@property (assign, nonatomic)   BOOL            isHanged;
/** 是否已接听 */
@property (assign, nonatomic)   BOOL            answered;
/** 网络提示信息，如网络状态良好、 */
@property (copy, nonatomic) NSString            *tipText;


- (void)setupWithIsCallee:(BOOL)isCallee;

- (void)show;

- (void)dismiss;

@end
