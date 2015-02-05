//
//  TPAViewController.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAViewController.h"
#import "TPASingletonManager.h"

@interface TPAViewController ()
@property (nonatomic, strong) TPAQQAccountService *qqAccountService;
@property (nonatomic, strong) TPAWeChatAccountService *weChatAccountService;
@property (nonatomic, strong) TPASinaWeiboAccountService *weiboAccountService;
@property (nonatomic, strong) TPAShareService *shareService;
@property (nonatomic, strong) UIImage *testImage;
@end

@implementation TPAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNotifications];
    
    self.qqAccountService = [TPASingletonManager sharedQQService];
    
    self.weChatAccountService = [TPASingletonManager sharedWeChatService];
    
    self.weiboAccountService = [TPASingletonManager sharedSinaWeiboService];
    
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
    
    // QQ
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQLogin:) name:TPANotificationQQAccountDidLogin object:self.qqAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQLogout:) name:TPANotificationQQAccountDidLogout object:self.qqAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQUserInfo:) name:TPANotificationQQAccountDidGetUserInfo object:self.qqAccountService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQShare:) name:TPANotificationShareToQQFinished object:self.qqAccountService];
    
    // WeChat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatLogin:) name:TPANotificationWeChatAccountDidLogin object:self.weChatAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatLogout:) name:TPANotificationWeChatAccountDidLogout object:self.weChatAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatUserInfo:) name:TPANotificationWeChatAccountDidGetUserInfo object:self.weChatAccountService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatShare:) name:TPANotificationShareToWeChatFinished object:self.weChatAccountService];
    
    // Weibo
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboLogin:) name:TPANotificationSinaWeiboAccountDidLogin object:self.weChatAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboLogout:) name:TPANotificationSinaWeiboAccountDidLogout object:self.weChatAccountService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboUserInfo:) name:TPANotificationSinaWeiboAccountDidGetUserInfo object:self.weChatAccountService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboShare:) name:TPANotificationShareToSinaWeiboFinished object:self.weChatAccountService];
}

- (IBAction)handleQQLogInOut:(UIButton *)sender
{
    if ([self.qqAccountService isAuthorized]) {
        [self.qqAccountService qqLogout];
    } else {
        [self.qqAccountService qqLogin];
    }
}

- (IBAction)handleWeChatLogInOut:(UIButton *)sender
{
    if ([self.weChatAccountService isAuthorized]) {
        [self.weChatAccountService weChatLogout];
    } else {
        [self.weChatAccountService weChatLogin];
    }
}

- (IBAction)handleSinaWeiboLogInOut:(UIButton *)sender
{
    if ([self.weiboAccountService isAuthorized]) {
        [self.weiboAccountService weiboLogout];
    } else {
        [self.weiboAccountService weiboLogin];
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
        contentItem.image = self.testImage;
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
        NSLog(@"分享已发出");
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

////
- (void)handleWeChatLogin:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"succeed:%@", noti.userInfo);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
    self.weChatLogInOutButton.selected = succeed;
}

- (void)handleWeChatLogout:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    self.weChatLogInOutButton.selected = NO;
}

- (void)handleWeChatUserInfo:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"succeed:%@", noti.userInfo);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

- (void)handleWeChatShare:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"分享已发出");
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

////
- (void)handleSinaWeiboLogin:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"succeed:%@", noti.userInfo);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
    self.sinaWeiboLogInOutButton.selected = succeed;
}

- (void)handleSinaWeiboLogout:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    self.sinaWeiboLogInOutButton.selected = NO;
}

- (void)handleSinaWeiboUserInfo:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"succeed:%@", noti.userInfo);
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

- (void)handleSinaWeiboShare:(NSNotification *)noti
{
    NSLog(@"%s", __func__);
    
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSLog(@"分享已发出");
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSLog(@"error:%@", error.localizedDescription);
    }
}

@end
