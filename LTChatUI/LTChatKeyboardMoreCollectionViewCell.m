//
//  LTChatKeyboardMoreCollectionViewCell.m
//  LTChatUI
//
//  Created by 梁通 on 2017/10/23.
//  Copyright © 2017年 梁通. All rights reserved.
//

#import "LTChatKeyboardMoreCollectionViewCell.h"

@interface LTChatKeyboardMoreCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *im;
@property (weak, nonatomic) IBOutlet UILabel *nameL;

@end

@implementation LTChatKeyboardMoreCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setItem:(NSDictionary *)item{
    _item = item;
    
    NSString* name = [item objectForKey:@"name"];
    NSString* image = [item objectForKey:@"image"];
    
    self.nameL.text = name;
    self.im.image = [UIImage imageNamed:image];
}
@end
