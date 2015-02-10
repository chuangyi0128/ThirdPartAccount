//
//  TPASinaWeiboAccountService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPASinaWeiboAccountService.h"
#import "UIViewController+TopmostViewController.h"
#import "UIImage+Crop.h"
#import "UIImage+Resize.h"


// NotificationKeys
NSString * const TPANotificationSinaWeiboAccountDidLogin = @"TPANotificationSinaWeiboAccountDidLogin";
NSString * const TPANotificationSinaWeiboAccountDidLogout = @"TPANotificationSinaWeiboAccountDidLogout";
NSString * const TPANotificationSinaWeiboAccountDidGetUserInfo = @"TPANotificationSinaWeiboAccountDidGetUserInfo";
NSString * const TPANotificationShareToSinaWeiboFinished = @"TPANotificationShareToSinaWeiboFinished";

// PropertyKeys
NSString * const TPASinaWeiboAccountAccessTokenKey = @"accessToken";
NSString * const TPASinaWeiboAccountTokeExpirationDateKey = @"tokeExpirationDate";
NSString * const TPASinaWeiboAccountUserIdKey = @"userId";
NSString * const TPASinaWeiboAccountUserNickNameKey = @"nickName";
NSString * const TPASinaWeiboAccountUserAvatarLinkKey = @"avatarLink";

// Static Variable
static NSString *appKey;
static NSString *redirectUrl = @"http://";


@interface TPASinaWeiboAccountService () <WBHttpRequestDelegate>
@property (nonatomic, assign) dispatch_queue_t taskQueue;
@end


@implementation TPASinaWeiboAccountService


#pragma mark - Public Methods

+ (void)setAppKey:(NSString *)theAppKey
{
    appKey = theAppKey;
    [WeiboSDK registerApp:theAppKey];
}

+ (void)setWeiboRedirectUrl:(NSString *)url
{
    redirectUrl = url;
}

+ (instancetype)sharedService
{
    static TPASinaWeiboAccountService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TPASinaWeiboAccountService new];
    });
    return instance;
}

- (instancetype)init
{
    if (appKey) {
        self = [super init];
        if (self) {
            self.taskQueue = dispatch_queue_create(NSStringFromClass(self.class).UTF8String, DISPATCH_QUEUE_CONCURRENT);
        }
        return self;
    } else {
        return nil;
    }
}

- (void)dealloc
{
    dispatch_release(self.taskQueue);
}

+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id <WeiboSDKDelegate>)delegate
{
    return [WeiboSDK handleOpenURL:url delegate:delegate];
}


#pragma mark 登录

- (BOOL)isAuthEnable
{
    return YES;
}

- (BOOL)isAuthorized
{
    return (self.tokeExpirationDate && [[NSDate date] compare:self.tokeExpirationDate] == NSOrderedDescending);
}

- (void)weiboLogin
{
    if (![self isAuthorized]) {
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = redirectUrl;
        request.scope = @"";
        request.userInfo = @{};
        [WeiboSDK sendRequest:request];
    }
}

- (void)weiboLogout
{
    if ([self isAuthorized]) {
        [WeiboSDK logOutWithToken:self.accessToken delegate:self withTag:@"weibo_logout"];
    }
}

- (void)getWeiboUserInfo
{
    [WBHttpRequest requestForUserProfile:self.userId
                         withAccessToken:self.accessToken
                      andOtherProperties:nil
                                   queue:nil
                   withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                       NSDictionary *responseDict;
                       if (error == nil) {
                           responseDict = [self parseJsonWithResponse:result error:&error];
                       }
                       if (error || responseDict == nil) {
                           NSError *theError = [NSError errorWithDomain:@"TPASinaWeiboAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"获取用户信息失败"}];
                           NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                                      TPAErrorKey : theError};
                           [self notify:TPANotificationSinaWeiboAccountDidGetUserInfo withUserInfo:userInfo];
                       } else {
                           _nickName = [responseDict[@"name"] description];
                           _avatarLink = [responseDict[@"profile_image_url"] description];
                           
                           NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                                      TPASinaWeiboAccountUserNickNameKey : self.nickName,
                                                      TPASinaWeiboAccountUserAvatarLinkKey : self.avatarLink};
                           [self notify:TPANotificationSinaWeiboAccountDidGetUserInfo withUserInfo:userInfo];
                       }
                   }
     ];
}


#pragma mark 分享

- (BOOL)isShareEnable
{
    return YES;
}

- (void)shareToWeiboWithImage:(UIImage *)image url:(NSString *)urlStr content:(NSString *)content
{
    dispatch_async(self.taskQueue, ^{
        WBImageObject *imageObject = [WBImageObject object];
        if (image) {
            UIImage *attachImage = image;
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            
            for (int i = 1; imageData.length > 1024 * 1024 * 9.9f; i++) { // max:10MB
                attachImage = [attachImage resizedImageToFitInSize:CGSizeMake(attachImage.size.width * 0.8f, attachImage.size.height * 0.8f) scaleIfSmaller:NO];
                imageData = UIImageJPEGRepresentation(attachImage, MAX(1.0f - 0.2f * i, 0.5f));
            }
            imageObject.imageData = imageData;
        }
        
        WBMessageObject *message = [WBMessageObject message];
        message.imageObject = imageObject;
        message.text = [content stringByAppendingString:urlStr];
        
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = redirectUrl;
        authRequest.scope = @"statuses_to_me_read";
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:self.accessToken];
        [WeiboSDK sendRequest:request];
    });
}


#pragma mark - Private Methods

- (void)notify:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[userInfo copy]];
    });
}

- (void)clear
{
    _accessToken = nil;
    _tokeExpirationDate = nil;
    _refreshToken = nil;
    _userId = nil;
    _nickName = nil;
    _avatarLink = nil;
}

- (NSDictionary *)parseJsonWithResponse:(NSString *)responseStr error:(NSError **)error
{
    NSError *theError;
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&theError];
    if (theError || responseDict == nil) {
        *error = [NSError errorWithDomain:@"TPASinaWeiboAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据解析失败"}];
        return nil;
    }
    return responseDict;
}


#pragma mark - WeiboSDKDelegate

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *authResponse = (WBAuthorizeResponse *)response;
        
        switch (authResponse.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
            {
                _userId = authResponse.userID;
                _accessToken = authResponse.accessToken;
                _tokeExpirationDate = authResponse.expirationDate;
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
                if (self.accessToken.length > 0) {
                    userInfo[TPASinaWeiboAccountAccessTokenKey] = self.accessToken;
                }
                if (self.tokeExpirationDate) {
                    userInfo[TPASinaWeiboAccountTokeExpirationDateKey] = self.tokeExpirationDate;
                }
                if (self.userId.length > 0) {
                    userInfo[TPASinaWeiboAccountUserIdKey] = self.userId;
                }
                [self notify:TPANotificationSinaWeiboAccountDidLogin withUserInfo:userInfo];
            }
                break;
            case WeiboSDKResponseStatusCodeUserCancel:
                // Do nothing
                break;
            case WeiboSDKResponseStatusCodeAuthDeny:
            default:
            {
                NSError *error = [NSError errorWithDomain:@"TPASinaWeiboAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"微博授权失败"}];
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                           TPAErrorKey : error};
                [self notify:TPANotificationSinaWeiboAccountDidLogin withUserInfo:userInfo];
            }
                break;
        }
    }
    else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        WBSendMessageToWeiboResponse *sendWeiboResponse = (WBSendMessageToWeiboResponse *)response;
        
        switch (sendWeiboResponse.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:
            {
                if (sendWeiboResponse.authResponse) {
                    [self didReceiveWeiboResponse:sendWeiboResponse.authResponse];
                }
                
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES)};
                [self notify:TPANotificationShareToSinaWeiboFinished withUserInfo:userInfo];
            }
                break;
            case WeiboSDKResponseStatusCodeUserCancel:
                // Do nothing
                break;
            case WeiboSDKResponseStatusCodeAuthDeny:
            default:
            {
                NSError *error = [NSError errorWithDomain:@"TPASinaWeiboAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"分享失败"}];
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                           TPAErrorKey : error};
                [self notify:TPANotificationShareToSinaWeiboFinished withUserInfo:userInfo];
            }
                break;
        }
    }
}


#pragma mark - WBHttpRequestDelegate

/**
 收到一个来自微博Http请求的响应
 
 @param response 具体的响应对象
 */
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    if ([request.tag isEqualToString:@"weibo_logout"]) {
        [self clear];
        
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES)};
        [self notify:TPANotificationSinaWeiboAccountDidLogout withUserInfo:userInfo];
    }
}

/**
 收到一个来自微博Http请求失败的响应
 
 @param error 错误信息
 */
- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error
{
    if ([request.tag isEqualToString:@"weibo_logout"]) {
        NSError *error = [NSError errorWithDomain:@"TPASinaWeiboAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"微博登出失败"}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : error};
        [self notify:TPANotificationSinaWeiboAccountDidLogout withUserInfo:userInfo];
    }
}

@end
