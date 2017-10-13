//
//  LTIMRosterTableViewController.m
//  LTIM
//
//  Created by 梁通 on 2017/9/21.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "LTIMRosterTableViewController.h"
#import "LTIMRosterTableViewCell.h"

#import "LTIMChatViewController.h"
#import "LTChatXMPPClient.h"
@interface LTIMRosterTableViewController ()

@property (nonatomic, retain) NSMutableArray    *contacts;

@end

#define LTIMRosterTableViewCellIdentifier  @"LTIMRosterTableViewCell"

@implementation LTIMRosterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"花名册";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LTIMRosterTableViewCell" bundle:nil] forCellReuseIdentifier:LTIMRosterTableViewCellIdentifier];
    self.tableView.estimatedRowHeight = 60.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self performSegueWithIdentifier:@"presentLoginVC" sender:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:kLTCHAT_XMPP_ROSTER_CHANGE object:nil];
}

- (void)rosterChange
{
    //    CFTimeInterval startTime = CACurrentMediaTime();
    //从存储器中取出我得好友数组，更新数据源
    self.contacts = [NSMutableArray arrayWithArray:[[LTChatXMPPClient sharedInstance] getUsers]];
    //    CFTimeInterval endTime = CACurrentMediaTime();
    //    NSLog(@"Total Runtime: %g s", endTime - startTime);
    [self.tableView reloadData];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LTIMRosterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LTIMRosterTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[LTIMRosterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LTIMRosterTableViewCellIdentifier];
    }
    cell.user = self.contacts[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    XMPPUserMemoryStorageObject *user = self.contacts[indexPath.row];
    
    LTIMChatViewController* chatVC = [[LTIMChatViewController alloc] init];
    chatVC.chatJID = user.jid;
    chatVC.title = user.jid.user;
    [self.navigationController pushViewController:chatVC animated:true];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;//手势滑动删除
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    XMPPUserMemoryStorageObject *user = self.contacts[indexPath.row];
    NSLog(@"user:%@",user);
    [[LTChatXMPPClient sharedInstance] removeUser:user.jid.user];
    
    [self performSelector:@selector(rosterChange) withObject:nil afterDelay:1];
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"删除";
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
