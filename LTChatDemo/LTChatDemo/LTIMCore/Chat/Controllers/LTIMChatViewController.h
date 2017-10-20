//
//  LTIMChatViewController.h
//  LTIM
//
//  Created by 梁通 on 2017/9/22.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "LTIMChatViewModel.h"

@interface LTIMChatViewController : JSQMessagesViewController

@property (nonatomic, strong) XMPPJID *chatJID;
/** 聊天记录*/
@property (nonatomic, strong) NSMutableArray *chatHistory;

@end
