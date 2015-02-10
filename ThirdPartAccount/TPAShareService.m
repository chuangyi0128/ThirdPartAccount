//
//  TPAShareService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/31/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAShareService.h"
#import <MessageUI/MessageUI.h>
#import "UIViewController+TopmostViewController.h"
#import "ERActionSheet.h"
#import "TPAQQAccountService.h"
#import "TPAWeChatAccountService.h"
#import "TPASinaWeiboAccountService.h"

#define TPABundleImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"TPAAcoutSerivece.bundle/%@", imageName]]

NSString * const TPANotificationShareFinished = @"TPANotificationShareFinished";


#pragma mark - TPAShareContentItem

@implementation TPAShareContentItem

@end



/*********************************************************/
#pragma mark - TPAShareService

@interface TPAShareService () <ERActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) TPAShareContentBlock contentBlock;
@end

@implementation TPAShareService

#pragma mark Public Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        // QQ
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQDidShare:) name:TPANotificationShareToQQFinished object:self.qqService];
        // WeChat
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatDidShare:) name:TPANotificationShareToWeChatFinished object:self.weChatService];
        // Weibo
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboDidShare:) name:TPANotificationShareToSinaWeiboFinished object:self.sinaWeiboSerivce];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showShareList:(TPAShareTo)shareTo inView:(UIView *)view usingBlock:(TPAShareContentBlock)contentBlock
{
    ERActionSheet *actionSheet = [[ERActionSheet alloc] initWithDelegate:self];
    
    TPAShareTo showSharePaths = [self enabledPaths] & shareTo;
    if (showSharePaths & TPAShareToQQFriend) {
        [actionSheet addButtonWithTitle:@"QQ好友" image:TPABundleImage(@"Icon-QQFriend") info:@{@"TPAShareTo":@(TPAShareToQQFriend)}];
    }
    if (showSharePaths & TPAShareToQZone) {
        [actionSheet addButtonWithTitle:@"QQ空间" image:TPABundleImage(@"Icon-QZone") info:@{@"TPAShareTo":@(TPAShareToQZone)}];
    }
    if (showSharePaths & TPAShareToWeChatFriend) {
        [actionSheet addButtonWithTitle:@"微信" image:TPABundleImage(@"Icon-Wechat") info:@{@"TPAShareTo":@(TPAShareToWeChatFriend)}];
    }
    if (showSharePaths & TPAShareToWeChatMoment) {
        [actionSheet addButtonWithTitle:@"微信朋友圈" image:TPABundleImage(@"Icon-WechatTimeline") info:@{@"TPAShareTo":@(TPAShareToWeChatMoment)}];
    }
    if (showSharePaths & TPAShareToYiXinFriend) {
        [actionSheet addButtonWithTitle:@"易信好友" image:TPABundleImage(@"Icon-Yixin") info:@{@"TPAShareTo":@(TPAShareToYiXinFriend)}];
    }
    if (showSharePaths & TPAShareToYiXinTimeLine) {
        [actionSheet addButtonWithTitle:@"易信朋友圈" image:TPABundleImage(@"Icon-YixinTimeline") info:@{@"TPAShareTo":@(TPAShareToYiXinTimeLine)}];
    }
    if (showSharePaths & TPAShareToSinaWeibo) {
        [actionSheet addButtonWithTitle:@"新浪微博" image:TPABundleImage(@"Icon-SinaWeibo") info:@{@"TPAShareTo":@(TPAShareToSinaWeibo)}];
    }
    if (showSharePaths & TPAShareToSMS) {
        [actionSheet addButtonWithTitle:@"短信" image:TPABundleImage(@"Icon-SMS") info:@{@"TPAShareTo":@(TPAShareToSMS)}];
    }
    if (showSharePaths & TPAShareToEmail) {
        [actionSheet addButtonWithTitle:@"邮件" image:TPABundleImage(@"Icon-Email") info:@{@"TPAShareTo":@(TPAShareToEmail)}];
    }
    [actionSheet showInView:view];
    self.contentBlock = [contentBlock copy];
}


#pragma mark Private Methods

- (TPAQQAccountService *)qqService
{
    return [TPAQQAccountService sharedService];
}

- (TPAWeChatAccountService *)weChatService
{
    return [TPAWeChatAccountService sharedService];
}

- (TPASinaWeiboAccountService *)sinaWeiboSerivce
{
    return [TPASinaWeiboAccountService sharedService];
}

- (TPAShareTo)enabledPaths
{
    TPAShareTo enabledSharePaths = 0;
    if ([self.qqService isShareEnable]) {
        enabledSharePaths |= TPAShareToQQFriend;
        enabledSharePaths |= TPAShareToQZone;
    }
    if ([self.weChatService isShareEnable]) {
        enabledSharePaths |= TPAShareToWeChatFriend;
        enabledSharePaths |= TPAShareToWeChatMoment;
    }
    if ([self.sinaWeiboSerivce isShareEnable]) {
        enabledSharePaths |= TPAShareToSinaWeibo;
    }
    if ([MFMessageComposeViewController canSendText]) {
        enabledSharePaths |= TPAShareToSMS;
    }
    if ([NSClassFromString(@"MFMailComposeViewController") canSendMail]) {
        enabledSharePaths |= TPAShareToEmail;
    }
    return enabledSharePaths;
}

- (void)proceedShareNotification:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
        [self notify:TPANotificationShareFinished withUserInfo:userInfo];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAShareService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError};
        [self notify:TPANotificationShareFinished withUserInfo:userInfo];
    }
}

- (void)notify:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[userInfo copy]];
}


#pragma mark ERActionSheetDelegate

- (void)ERActionSheet:(ERActionSheet*)sheet clickedButtonAtIndex:(NSInteger)index withInfo:(NSDictionary *)info
{
    if (self.contentBlock == nil) {
        return;
    }
    
    TPAShareTo shareTo = [info[@"TPAShareTo"] unsignedIntegerValue];
    if (shareTo & TPAShareToQQFriend) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToQQFriend);
        if (contentItem.linkUrlStr) {
            [self.qqService shareToFriendsWithURL:contentItem.linkUrlStr title:contentItem.title description:contentItem.content previewImage:contentItem.image];
        } else {
            [self.qqService shareToFriendsWithImage:contentItem.image title:contentItem.title description:contentItem.content];
        }
        return;
    }
    if (shareTo & TPAShareToQZone) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToQZone);
        if (contentItem.linkUrlStr) {
            [self.qqService shareToQZoneWithURL:contentItem.linkUrlStr title:contentItem.title description:contentItem.content previewImage:contentItem.image];
        } else {
            [self.qqService shareToQZoneWithImage:contentItem.image title:contentItem.title description:contentItem.content];
        }
        return;
    }
    if (shareTo & TPAShareToWeChatFriend) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToWeChatFriend);
        if (contentItem.linkUrlStr) {
            [self.weChatService shareToWeChatFriendsWithURL:contentItem.linkUrlStr title:contentItem.title description:contentItem.content previewImage:contentItem.image];
        } else {
            [self.weChatService shareToWeChatFriendsWithImage:contentItem.image title:contentItem.title description:contentItem.content];
        }
        return;
    }
    if (shareTo & TPAShareToWeChatMoment) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToWeChatMoment);
        if (contentItem.linkUrlStr) {
            [self.weChatService shareToWeChatMomentWithURL:contentItem.linkUrlStr title:contentItem.title description:contentItem.content previewImage:contentItem.image];
        } else {
            [self.weChatService shareToWeChatMomentWithImage:contentItem.image title:contentItem.title description:contentItem.content];
        }
        return;
    }
    if (shareTo & TPAShareToYiXinFriend) {
        
        return;
    }
    if (shareTo & TPAShareToYiXinTimeLine) {
        
        return;
    }
    if (shareTo & TPAShareToSinaWeibo) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToSinaWeibo);
        [self.sinaWeiboSerivce shareToWeiboWithImage:contentItem.image url:contentItem.linkUrlStr content:contentItem.content];
        return;
    }
    if (shareTo & TPAShareToSMS) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToSMS);
        
        NSString *content = contentItem.content;
        if (contentItem.linkUrlStr.length > 0) {
            content = [content stringByAppendingString:contentItem.linkUrlStr];
        }
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        controller.body = content;
        
        UIViewController *presenter = [UIViewController topmostViewController];
        [presenter presentViewController:controller animated:YES completion:^{
            
        }];
        return;
    }
    if (shareTo & TPAShareToEmail) {
        TPAShareContentItem *contentItem = self.contentBlock(TPAShareToEmail);
        
        NSString *content = contentItem.content;
        if (contentItem.linkUrlStr.length > 0) {
            content = [content stringByAppendingString:contentItem.linkUrlStr];
        }
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:contentItem.title];
        [controller setMessageBody:content isHTML:NO];
        [controller setCcRecipients:nil];
        [controller setBccRecipients:nil];
        
        UIViewController *presenter = [UIViewController topmostViewController];
        [presenter presentViewController:controller animated:YES completion:^{
            
        }];
        return;
    }
}


#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [[UIViewController topmostViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [[UIViewController topmostViewController] dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - Notifications

- (void)handleQQDidShare:(NSNotification *)noti
{
    [self proceedShareNotification:noti];
}

- (void)handleWeChatDidShare:(NSNotification *)noti
{
    [self proceedShareNotification:noti];
}

- (void)handleSinaWeiboDidShare:(NSNotification *)noti
{
    [self proceedShareNotification:noti];
}

@end
