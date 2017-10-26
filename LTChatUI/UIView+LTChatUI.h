//
//  UIView+LTChatUI.h
//  LTChatUI
//
//  Created by 梁通 on 2017/10/23.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LTChatUI)
- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute;
- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant;
- (void)squareSubview:(UIView*)subview;
-(void)pinSubview:(UIView*)subview withAttribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant;
-(void)pinSubview:(UIView*)subview1 attribute:(NSLayoutAttribute)attribute1
          subView:(UIView*)subview2 attribute:(NSLayoutAttribute)attribute2
         constant:(CGFloat)constant;
-(void)addLayerOnSubView:(UIView*)subview;
@end
