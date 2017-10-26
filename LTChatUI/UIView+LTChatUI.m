//
//  UIView+LTChatUI.m
//  LTChatUI
//
//  Created by 梁通 on 2017/10/23.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "UIView+LTChatUI.h"

@implementation UIView (LTChatUI)

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:0]];
}

- (void)pinSubview:(UIView *)subview toEdge:(NSLayoutAttribute)attribute withConstant:(CGFloat)constant{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:attribute
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview
                                                     attribute:attribute
                                                    multiplier:1.0f
                                                      constant:constant]];
}

-(void)squareSubview:(UIView*)subview{
    [subview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:subview
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0f
                                                         constant:0]];
}

-(void)pinSubview:(UIView*)subview withAttribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant{
    [subview addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                        attribute:attribute
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0.0f
                                                         constant:constant]];
}


-(void)pinSubview:(UIView*)subview1 attribute:(NSLayoutAttribute)attribute1
          subView:(UIView*)subview2 attribute:(NSLayoutAttribute)attribute2
         constant:(CGFloat)constant{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview1
                                                     attribute:attribute1
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:subview2
                                                     attribute:attribute2
                                                    multiplier:1.0f
                                                      constant:constant]];
}

-(void)addLayerOnSubView:(UIView*)subview{
    subview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    subview.layer.borderWidth = 0.7f;
    subview.layer.cornerRadius = 5.f;
    subview.clipsToBounds = YES;
    
}
@end
