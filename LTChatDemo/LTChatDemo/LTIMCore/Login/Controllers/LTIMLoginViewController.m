//
//  LTIMLoginViewController.m
//  LTIM
//
//  Created by 梁通 on 2017/9/22.
//  Copyright © 2017年 Personal. All rights reserved.
//

#import "LTIMLoginViewController.h"
#import "LTChatXMPPClient.h"
@interface LTIMLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameF;
@property (weak, nonatomic) IBOutlet UITextField *jidF;
@property (weak, nonatomic) IBOutlet UITextField *pwdF;
@property (weak, nonatomic) IBOutlet UITextField *ipF;
@property (weak, nonatomic) IBOutlet UITextField *portF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LTIMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(UIButton *)sender {
    
    [[LTChatXMPPClient sharedInstance] loginWithName:self.nameF.text password:self.pwdF.text complete:^(BOOL success) {
        if (success) {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
    
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
