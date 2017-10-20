//
//  LTIMChatViewController.m
//  LTIM
//
//  Created by 梁通 on 2017/9/22.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "LTIMChatViewController.h"
#import "LTChatXMPPClient.h"
#import "LTChatWebRTCClient.h"

@interface LTIMChatViewController ()<XMPPOutgoingFileTransferDelegate>

@property (nonatomic, strong) LTIMChatViewModel* viewModel;

@end

@implementation LTIMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inputToolbar.contentView.leftBarButtonItemWidth = 60.f;
    [self.inputToolbar.contentView.leftBarButtonItem setImage:[UIImage imageNamed:@"ic_rtc_call"] forState:UIControlStateNormal];
    
    self.viewModel = [[LTIMChatViewModel alloc] initWithChatJid:self.chatJID];
    [self.viewModel refreshChatHistory];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadChatData) name:kLTCHAT_XMPP_MESSAGE_CHANGE object:nil];
}

-(void)reloadChatData{
    [self.viewModel refreshChatHistory];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self finishSendingMessageAnimated:YES];
    });
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date{
    [self.viewModel sendMessage:text];
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
    LTChatWebRTCClient *client = [LTChatWebRTCClient sharedInstance];
//    [client startEngine];
    client.myJID = [LTChatXMPPClient sharedInstance].xmppStream.myJID.full;
    client.remoteJID = self.chatJID.full;
    
    [client showRTCViewByRemoteName:self.chatJID.full isVideo:YES isCaller:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return self.viewModel.userId;
}

- (NSString *)senderDisplayName {
    return self.viewModel.userName;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.viewModel.outgoingBubbleImageData;
    }
    
    return self.viewModel.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
//    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
//    return [self.viewModel avatarImageWithUserId:message.senderId userName:message.senderDisplayName];
    return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"ic_user_gray_header"] diameter:10];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger minite = 60;
//    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
//    NSDate* msgDate = message.date;
//    if (indexPath.item > 0) {
//        JSQMessage *preMessage = [self.viewModel.messages objectAtIndex:indexPath.item - 1];
//        NSDate* preMsgDate = preMessage.date;
//        //        NSLog(@"msgDate:%@ preMsgDate:%@",msgDate,preMsgDate);
//        minite =  [msgDate timeIntervalSinceDate:preMsgDate] / 60;
//    }
//    if (minite > 1) {//相邻聊天记录时间差超过1分钟，则显示时间
//        return [[NSAttributedString alloc] initWithString:[NSDate jk_timeInfoWithDate:msgDate]];
//    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.viewModel.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.viewModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *msg = [self.viewModel.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.viewModel.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.viewModel.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath{
//    JSQMessage *msg = [self.viewModel.messages objectAtIndex:indexPath.item];
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


@end
