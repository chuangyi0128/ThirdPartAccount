//
//  TPAViewController.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAViewController.h"
#import "TPAQQAccountService.h"

@interface TPAViewController ()
@property (nonatomic, strong) TPAQQAccountService *qqAccountService;
@end

@implementation TPAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNotifications];
    
    self.qqAccountService = [TPAQQAccountService serviceWithAppId:@"222222"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.qqAccountService performSelector:@selector(getQQUserInfo) withObject:nil afterDelay:2.0f];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkError:) name:TPANotificationNetworkError object:self.qqAccountService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQLogin:) name:TPANotificationQQAccountDidLogin object:self.qqAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQLogout:) name:TPANotificationQQAccountDidLogout object:self.qqAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQUserInfo:) name:TPANotificationQQAccountDidGetUserInfo object:self.qqAccountService];
}


#pragma mark - Notifications

- (void)handleNetworkError:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
}

- (void)handleQQLogin:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = noti.userInfo[TPASucceedFlagKey];
    if (succeed) {
        NSString *token = noti.userInfo[TPAQQAccountAccessTokenKey];
        NSDate *expirationDate = noti.userInfo[TPAQQAccountTokeExpirationDateKey];
        NSString *openId = noti.userInfo[TPAQQAccountOpenIdKey];
        NSLog(@"succeed:%@ / %@ / %@", token, expirationDate, openId);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

- (void)handleQQLogout:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
}

- (void)handleQQUserInfo:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = noti.userInfo[TPASucceedFlagKey];
    if (succeed) {
        NSString *nickName = noti.userInfo[TPAQQAccountUserNickNameKey];
        NSString *avatarLink = noti.userInfo[TPAQQAccountUserAvatarLinkKey];
        NSLog(@"succeed:%@ / %@", nickName, avatarLink);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

@end
