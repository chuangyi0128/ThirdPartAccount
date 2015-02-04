//
//  TPAShareService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/31/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAShareService.h"
#import <MessageUI/MessageUI.h>
#import "TPAQQAccountService.h"
#import "ERActionSheet.h"
#import "UIViewController+TopmostViewController.h"

#define TPABundleImage(imageName) [UIImage imageNamed:[NSString stringWithFormat:@"TPAAcoutSerivece.bundle/%@", imageName]]

#pragma mark - TPAShareContentItem

@implementation TPAShareContentItem

@end



/*********************************************************/
#pragma mark - TPAShareService

@interface TPAShareService () <ERActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) TPAQQAccountService *qqService;
@property (nonatomic, strong) TPAShareContentBlock contentBlock;
@end

@implementation TPAShareService


#pragma mark Public Methods

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.qqService = [TPAQQAccountService service];
    }
    return self;
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

- (TPAShareTo)enabledPaths
{
    TPAShareTo enabledSharePaths = 0;
    if ([self.qqService isShareEnable]) {
        enabledSharePaths |= TPAShareToQQFriend;
        enabledSharePaths |= TPAShareToQZone;
    }
    if ([MFMessageComposeViewController canSendText]) {
        enabledSharePaths |= TPAShareToSMS;
    }
    if ([NSClassFromString(@"MFMailComposeViewController") canSendMail]) {
        enabledSharePaths |= TPAShareToEmail;
    }
    return enabledSharePaths;
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
        
        return;
    }
    if (shareTo & TPAShareToWeChatMoment) {
        
        return;
    }
    if (shareTo & TPAShareToYiXinFriend) {
        
        return;
    }
    if (shareTo & TPAShareToYiXinTimeLine) {
        
        return;
    }
    if (shareTo & TPAShareToSinaWeibo) {
        
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

@end
