//
//  TestViewController.m
//  GCPrePermissions
//
//  Created by 韩俊强 on 16/6/17.
//  Copyright © 2016年 韩俊强. All rights reserved.
//

#import "TestViewController.h"
#import "GCPrePermissions.h"

@interface TestViewController ()

@property (strong, nonatomic) IBOutlet UILabel *photoPermissionResultLabel;

@property (strong, nonatomic) IBOutlet UILabel *contactsPermissionResultLabel;

@property (strong, nonatomic) IBOutlet UILabel *locationPermissionResultLabel;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

// 相机
- (IBAction)onCameraPermissionAction:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showCameraPermissionsWithTitle:@"访问相册" message:@"访问相册设置" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
        NSLog(@"相册设置过了");
    }];
}

// 相册
- (IBAction)onPhotoPermissionsButtonTapped:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showPhotoPermissionsWithTitle:@"相册设置提醒"
                                       message:@"允许访问相册"
                               denyButtonTitle:@"暂不"
                              grantButtonTitle:@"设置"
                             completionHandler:^(BOOL hasPermission,
                                                 GCDialogResult userDialogResult,
                                                 GCDialogResult systemDialogResult) {
                                 [self updateResultLabel:self.photoPermissionResultLabel
                                          withPermission:hasPermission
                                        userDialogResult:userDialogResult
                                      systemDialogResult:systemDialogResult];
                             }];
}

// 通讯录
- (IBAction)onContactsButtonPermissionTapped:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showContactsPermissionsWithTitle:@"接受通讯录设置提醒"
                                          message:@"允许同步通讯录"
                                  denyButtonTitle:@"暂不"
                                 grantButtonTitle:@"设置"
                                completionHandler:^(BOOL hasPermission,
                                                    GCDialogResult userDialogResult,
                                                    GCDialogResult systemDialogResult) {
                                    [self updateResultLabel:self.contactsPermissionResultLabel
                                             withPermission:hasPermission
                                           userDialogResult:userDialogResult
                                         systemDialogResult:systemDialogResult];
                                }];
}

// 位置
- (IBAction)onLocationButtonPermissionTapped:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showLocationPermissionsWithTitle:@"位置提醒设置"
                                          message:@"允许设置位置"
                                  denyButtonTitle:@"暂不"
                                 grantButtonTitle:@"设置"
                                completionHandler:^(BOOL hasPermission,
                                                    GCDialogResult userDialogResult,
                                                    GCDialogResult systemDialogResult) {
                                    [self updateResultLabel:self.locationPermissionResultLabel
                                             withPermission:hasPermission
                                           userDialogResult:userDialogResult
                                         systemDialogResult:systemDialogResult];
                                }];
}

// 通知
- (IBAction)onPushNotificationPermission:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showPushNotificationPermissionsWithType:GCPushNotificationTypeBadge title:@"通知提醒设置" message:@"是否接收通知" denyButtonTitle:@"暂不" grantButtonTitle:@"去设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
        NSLog(@"设置过了哈哈哈😄");
    }];
}

// 麦克风
- (IBAction)onMicrophonePermissionsAction:(id)sender
{
   GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showMicrophonePermissionsWithTitle:@"麦克风设置提醒" message:@"设置麦克风" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
        NSLog(@"设置过了");
    }];
}

// 日历     GCEventAuthorizationTypeEvent
// 提醒事项 GCEventAuthorizationTypeReminder
- (IBAction)onEventsPermissionAction:(id)sender
{
    GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
    [permissions showEventPermissionsWithType:GCEventAuthorizationTypeEvent Title:@"日历设置" message:@"允许设置日历" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
        NSLog(@"日历已设置");
    }];
    
}


- (void) updateResultLabel:(UILabel *)resultLabel
            withPermission:(BOOL)hasPermission
          userDialogResult:(GCDialogResult)userDialogResult
        systemDialogResult:(GCDialogResult)systemDialogResult
{
    resultLabel.text = @"haha";
    resultLabel.alpha = 0.0;
    
    if (hasPermission) {
        resultLabel.textColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.1 alpha:1.0];
    } else {
        resultLabel.textColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0];
    }
    NSString *text = nil;
    if (userDialogResult == GCDialogResultNoActionTaken &&
        systemDialogResult == GCDialogResultNoActionTaken) {
        NSString *prefix = nil;
        if (hasPermission) {
            prefix = @"Granted.";
        } else if (systemDialogResult == GCDialogResultParentallyRestricted) {
            prefix = @"Restricted.";
        } else {
            prefix = @"Denied.";
        }
        text = [NSString stringWithFormat:@"%@ Dialogs not shown, system choice already made.", prefix];
    } else {
        NSString *userResultString = [self stringFromDialogResult:userDialogResult];
        NSString *systemResultString = [self stringFromDialogResult:systemDialogResult];
        text = [NSString stringWithFormat:@"User Action: %@\nSystem Action: %@", userResultString, systemResultString];
    }
    resultLabel.text = text;
    
    [UIView animateWithDuration:0.35 animations:^{
        resultLabel.alpha = 1.0;
    }];
}

- (NSString *) stringFromDialogResult:(GCDialogResult)result
{
    switch (result) {
        case GCDialogResultNoActionTaken:
            return @"No Action Taken";
            break;
        case GCDialogResultGranted:
            return @"Granted";
            break;
        case GCDialogResultDenied:
            return @"Denied";
            break;
        case GCDialogResultParentallyRestricted:
            return @"Restricted";
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
