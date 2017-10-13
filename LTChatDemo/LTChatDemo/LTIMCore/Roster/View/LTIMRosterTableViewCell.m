//
//  LTIMRosterTableViewCell.m
//  LTIM
//
//  Created by 梁通 on 2017/9/21.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "LTIMRosterTableViewCell.h"

@interface LTIMRosterTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;
@property (weak, nonatomic) IBOutlet UILabel *nickNameL;
@property (weak, nonatomic) IBOutlet UILabel *descL;
@property (weak, nonatomic) IBOutlet UILabel *countL;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@property (weak, nonatomic) IBOutlet UILabel *showL;
@end

@implementation LTIMRosterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setup];
}

-(void)setup{
    self.bgView.layer.cornerRadius = 2.f;
    //    self.bgView.clipsToBounds = YES;
    
    self.bgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.bgView.layer.shadowOpacity = 0.6;
    self.bgView.layer.shadowOffset = CGSizeMake(4, 4);
    self.bgView.layer.shadowRadius = 4.0;
    
    
    self.countL.layer.cornerRadius = 10.f;
    self.countL.clipsToBounds = YES;
    self.countL.backgroundColor = [UIColor redColor];
    self.countL.textColor = [UIColor whiteColor];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setUser:(XMPPUserMemoryStorageObject *)user{
    _user = user;
    NSString* name = user.jid.user;
    self.nickNameL.text = name;
    
    if (user.isOnline) {
        self.statusL.text = @"[在线]";
        self.nickNameL.textColor = [UIColor blackColor];
        self.statusL.textColor = [UIColor blackColor];
    }else{
        self.statusL.text = @"[离线]";
        self.nickNameL.textColor = [UIColor grayColor];
        self.statusL.textColor = [UIColor grayColor];
    }
}
@end
