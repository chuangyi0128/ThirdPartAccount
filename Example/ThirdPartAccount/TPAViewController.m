//
//  TPAViewController.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAViewController.h"
#import "TPAQQAccountService.h"
#import "TPAShareService.h"

@interface TPAViewController ()
@property (nonatomic, strong) TPAQQAccountService *qqAccountService;
@property (nonatomic, strong) TPAShareService *shareService;
@property (nonatomic, strong) UIImage *testImage;
@end

@implementation TPAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNotifications];
    
    [TPAQQAccountService setAppId:@"222222"];
    self.qqAccountService = [TPAQQAccountService service];
    self.shareService = [[TPAShareService alloc] init];
    
    self.testImage = [UIImage imageNamed:@"image02"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQShare:) name:TPANotificationShareToQQFinished object:self.qqAccountService];
}

- (IBAction)handleQQLogInOut:(UIButton *)sender
{
    if ([self.qqAccountService isAuthorized]) {
        [self.qqAccountService qqLogout];
    } else {
        [self.qqAccountService qqLogin];
    }
}

- (IBAction)handleShare:(UIButton *)sender
{
    [self.shareService showShareList:TPAShareToAll inView:self.view usingBlock:^TPAShareContentItem *(TPAShareTo shareTo) {
        if (shareTo & TPAShareToQQFriend || shareTo & TPAShareToQZone) {
            
        }
        TPAShareContentItem *contentItem = [TPAShareContentItem new];
        contentItem.title = @"ThirdPartAccount";
        contentItem.content = @"Test content 这是测试内容\n是测试内容～";
        contentItem.linkUrlStr = @"http://cp.163.com";
        contentItem.image = [UIImage imageNamed:@"image02"];
        return contentItem;
    }];
}

- (IBAction)handleQQFriendsShare:(UIButton *)sender
{
    [self.qqAccountService shareToFriendsWithImage:self.testImage title:@"test" description:@"description"];
}

- (IBAction)handleQZoneShare:(UIButton *)sender
{
    [self.qqAccountService shareToQZoneWithURL:@"http://www.qq.com" title:@"title" description:@"description" previewImage:self.testImage];
}

#pragma mark - Notifications

- (void)handleNetworkError:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
}

- (void)handleQQLogin:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSString *token = noti.userInfo[TPAQQAccountAccessTokenKey];
        NSDate *expirationDate = noti.userInfo[TPAQQAccountTokeExpirationDateKey];
        NSString *openId = noti.userInfo[TPAQQAccountOpenIdKey];
        NSLog(@"succeed:%@ / %@ / %@", token, expirationDate, openId);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
    self.qqLogInOutButton.selected = succeed;
}

- (void)handleQQLogout:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    self.qqLogInOutButton.selected = NO;
}

- (void)handleQQUserInfo:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSString *nickName = noti.userInfo[TPAQQAccountUserNickNameKey];
        NSString *avatarLink = noti.userInfo[TPAQQAccountUserAvatarLinkKey];
        NSLog(@"succeed:%@ / %@", nickName, avatarLink);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

- (void)handleQQShare:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"分享成功");
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

@end
