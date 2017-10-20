//
//  LTIMChatViewModel.m
//  LTIM
//
//  Created by 梁通 on 2017/9/22.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "LTIMChatViewModel.h"
#import "LTChatXMPPClient.h"
@interface LTIMChatViewModel()


@end

@implementation LTIMChatViewModel

-(instancetype)initWithChatJid:(XMPPJID*)chatJid{
    self = [super init];
    if (self) {
        self.chatJid = chatJid;
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    return self;
}

-(void)refreshChatHistory{
    XMPPMessageArchivingCoreDataStorage *storage = [LTChatXMPPClient sharedInstance].xmppMessageArchivingCoreDataStorage;
    //查询的时候要给上下文
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:storage.messageEntityName inManagedObjectContext:storage.mainThreadManagedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJid.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [storage.mainThreadManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    [self.messages removeAllObjects];
    for (XMPPMessageArchiving_Message_CoreDataObject* msg in fetchedObjects) {
//        NSString* subject = msg.message.subject;
//        NSString* body = msg.body;
        if (msg.isOutgoing) {
            JSQMessage* messageItem = [[JSQMessage alloc] initWithSenderId:self.userId  senderDisplayName:self.userName date:msg.timestamp text:msg.body];
            [self.messages addObject:messageItem];
        }else{
            JSQMessage* messageItem = [[JSQMessage alloc] initWithSenderId:msg.bareJid.bareJID.user  senderDisplayName:msg.bareJid.bareJID.user date:msg.timestamp text:msg.body];
            [self.messages addObject:messageItem];
        }
    }

}
-(void)sendMessage:(NSString*)msg{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJid];
    [message addBody:msg];
    [[LTChatXMPPClient sharedInstance].xmppStream sendElement:message];
}
//
//
//
//-(void)refreshMessages{
//    NSArray* msgList = [self.msgManager talksWithJid:_toJid];
//    [_messages removeAllObjects];
//    for (LTXMPPMessage* msg in msgList) {
//        JSQMessage* messageItem = [[JSQMessage alloc] initWithSenderId:msg.fromJid  senderDisplayName:msg.fromName date:msg.showTime text:msg.body];
//        [_messages addObject:messageItem];
//    }
//}

-(NSMutableArray*)messages{
    if(!_messages){
        _messages = [[NSMutableArray alloc] init];
//        [self refreshMessages];
    }
    return _messages;
}

-(NSString*)userId{
    NSString* userId = [[LTChatXMPPClient sharedInstance].xmppStream.myJID user];
    return userId;
}

-(NSString*)userName{
    NSString* userName = [LTChatXMPPClient sharedInstance].xmppStream.myJID.user;
    return userName;
}
@end
