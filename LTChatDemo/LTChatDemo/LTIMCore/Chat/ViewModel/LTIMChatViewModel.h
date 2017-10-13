//
//  LTIMChatViewModel.h
//  LTIM
//
//  Created by 梁通 on 2017/9/22.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTChatConfig.h"
#import "JSQMessages.h"
#import <UIKit/UIKit.h>

@interface LTIMChatViewModel : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) XMPPJID* chatJid;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;


-(instancetype)initWithChatJid:(XMPPJID*)chatJid;

-(void)refreshChatHistory;

-(void)sendMessage:(NSString*)message;

@end
