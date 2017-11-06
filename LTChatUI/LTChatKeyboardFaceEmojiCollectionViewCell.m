//
//  LTChatKeyboardFaceEmojiCollectionViewCell.m
//  LTChatUI
//
//  Created by 梁通 on 2017/11/6.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardFaceEmojiCollectionViewCell.h"

@interface LTChatKeyboardFaceEmojiCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *emojiL;
@end
@implementation LTChatKeyboardFaceEmojiCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setEmojiStr:(NSString *)emojiStr{
    _emojiStr = emojiStr;
    _emojiL.text = emojiStr;
}

@end
