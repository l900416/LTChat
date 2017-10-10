//
//  LTChatWebRTCButton.h
//  LTChatDemo
//
//  Created by 梁通 on 2017/10/10.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTChatWebRTCButton : UIButton

- (instancetype)initWithTitle:(NSString *)title
                    imageName:(NSString *)imageName
                      isVideo:(BOOL)isVideo;

+ (instancetype)rtcButtonWithTitle:(NSString *)title
                         imageName:(NSString *)imageName
                           isVideo:(BOOL)isVideo;

- (instancetype)initWithTitle:(NSString *)title
            noHandleImageName:(NSString *)noHandleImageName;

+ (instancetype)rtcButtonWithTitle:(NSString *)title
                 noHandleImageName:(NSString *)noHandleImageName;

@end
