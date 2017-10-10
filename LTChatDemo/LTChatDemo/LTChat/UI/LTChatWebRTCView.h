//
//  LTChatWebRTCView.h
//  LTChatDemo
//
//  Created by 梁通 on 2017/10/10.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 音／视频聊天画面
 **/
@interface LTChatWebRTCView : UIView

#pragma mark - properties
/** 对方的昵称 */
@property (copy, nonatomic) NSString            *nickName;
/** 连接信息，如等待对方接听...、对方已拒绝、语音通话、视频通话 */
@property (copy, nonatomic) NSString            *connectText;
/** 网络提示信息，如网络状态良好、 */
@property (copy, nonatomic) NSString            *netTipText;
/** 是否是被挂断 */
@property (assign, nonatomic)   BOOL            isHanged;
/** 是否已接听 */
@property (assign, nonatomic)   BOOL            answered;
/** 对方是否开启了摄像头 */
@property (assign, nonatomic)   BOOL            oppositeCamera;

/** 头像 */
@property (strong, nonatomic, readonly)   UIImageView             *portraitImageView;
/** 自己的视频画面 */
@property (strong, nonatomic, readonly)   UIImageView             *ownImageView;
/** 对方的视频画面 */
@property (strong, nonatomic, readonly)   UIImageView             *adverseImageView;




#pragma mark - method
- (instancetype)initWithIsVideo:(BOOL)isVideo isCallee:(BOOL)isCallee;

- (void)show;

- (void)dismiss;

@end
