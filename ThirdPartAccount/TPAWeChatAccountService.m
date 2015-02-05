//
//  TPAWeChatAccountService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAWeChatAccountService.h"
#import "UIViewController+TopmostViewController.h"


// NotificationKeys
NSString * const TPANotificationWeChatAccountDidLogin = @"TPANotificationWeChatAccountDidLogin";
NSString * const TPANotificationWeChatAccountDidLogout = @"TPANotificationWeChatAccountDidLogout";
NSString * const TPANotificationWeChatAccountDidGetUserInfo = @"TPANotificationWeChatAccountDidGetUserInfo";
NSString * const TPANotificationShareToWeChatFinished = @"TPANotificationShareToWeChatFinished";

// PropertyKeys
NSString * const TPAWeChatAccountAccessTokenKey = @"accessToken";
NSString * const TPAWeChatAccountTokeExpirationDateKey = @"tokeExpirationDate";
NSString * const TPAWeChatAccountOpenIdKey = @"openId";
NSString * const TPAWeChatAccountUserUnionIdKey = @"unionId";
NSString * const TPAWeChatAccountUserNickNameKey = @"nickName";
NSString * const TPAWeChatAccountUserSexKey = @"sex";
NSString * const TPAWeChatAccountUserProvinceKey = @"province";
NSString * const TPAWeChatAccountUserCityKey = @"city";
NSString * const TPAWeChatAccountUserAvatarLinkKey = @"avatarLink";

// Private Strings
static NSString *TPAWeChatGetAccessTokenUrl = @"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code";
static NSString *TPAWeChatRefreshAccessTokenUrl = @"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@";
static NSString *TPAWeChatGetUserInfoUrl = @"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@";

// Static Variable
static NSString *appId;
static NSString *secret;


@interface TPAWeChatAccountService ()
@property (nonatomic, assign) dispatch_queue_t taskQueue;
@property (nonatomic, copy) NSString *authCode; // Auth后返回的code
@end


@implementation TPAWeChatAccountService


#pragma mark - Public Methods

+ (void)setAppId:(NSString *)theAppId
{
    appId = theAppId;
    [WXApi registerApp:theAppId];
}

+ (void)setSecret:(NSString *)theSecret
{
    secret = theSecret;
}

+ (instancetype)service
{
    return [TPAWeChatAccountService new];
}

- (instancetype)init
{
    NSAssert(appId.length > 0, @"%s 'appId' must be not nil", __func__);
    NSAssert(secret.length > 0, @"%s 'secret' must be not nil", __func__);
    
    if (appId && secret) {
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

+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id <WXApiDelegate>)delegate
{
    return [WXApi handleOpenURL:url delegate:delegate];
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

- (void)weChatLogin
{
    if (![self isAuthorized]) {
        if (self.refreshToken.length > 0) {
            [self doRefreshToken];
        } else {
            [self doAuth];
        }
    }
}

- (void)weChatLogout
{
    [self clear];
    
    NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES)};
    [self notify:TPANotificationWeChatAccountDidLogout withUserInfo:userInfo];
}

- (void)getWeChatUserInfo
{
    if ([self isAuthorized]) {
        NSString *urlStr = [NSString stringWithFormat:TPAWeChatGetUserInfoUrl, self.accessToken, self.openId];
        dispatch_async(self.taskQueue, ^{
            NSError *error;
            NSDictionary *responseDict = [self parseJsonFromUrl:urlStr error:&error];
            if (error) {
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                           TPAErrorKey : error};
                [self notify:TPANotificationWeChatAccountDidGetUserInfo withUserInfo:userInfo];
            } else if (responseDict[@"unionid"] == nil) {
                error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"请求失败"}];
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                           TPAErrorKey : error};
                [self notify:TPANotificationWeChatAccountDidGetUserInfo withUserInfo:userInfo];
            } else {
                _unionId = [responseDict[@"unionid"] description];
                _nickName = [responseDict[@"nickname"] description];
                _sex = [responseDict[@"sex"] description];
                _province = [responseDict[@"province"] description];
                _city = [responseDict[@"city"] description];
                _avatarLink = [responseDict[@"headimgurl"] description];
                
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES),
                                           TPAWeChatAccountUserUnionIdKey : self.unionId,
                                           TPAWeChatAccountUserNickNameKey : self.nickName,
                                           TPAWeChatAccountUserSexKey : self.sex,
                                           TPAWeChatAccountUserProvinceKey : self.province,
                                           TPAWeChatAccountUserCityKey : self.city,
                                           TPAWeChatAccountUserAvatarLinkKey : self.avatarLink};
                [self notify:TPANotificationWeChatAccountDidGetUserInfo withUserInfo:userInfo];
            }
        });
    } else {
        [self weChatLogin];
    }
}


#pragma mark 分享

- (BOOL)isShareEnable
{
    return [WXApi isWXAppSupportApi] && [WXApi isWXAppInstalled];
}

- (void)shareToWeChatFriendsWithURL:(NSString *)urlStr title:(NSString *)title description:(NSString *)desc previewImage:(UIImage *)prevImage
{
    
}

- (void)shareToWeChatFriendsWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)desc
{
    
}

- (void)shareToWeChatMomentWithURL:(NSString *)urlStr title:(NSString *)title description:(NSString *)desc previewImage:(UIImage *)prevImage
{
    
}

- (void)shareToWeChatMomentWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)desc
{
    
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
    _openId = nil;
    _unionId = nil;
    _nickName = nil;
    _sex = nil;
    _province = nil;
    _city = nil;
    _avatarLink = nil;
}

- (NSDictionary *)parseJsonFromUrl:(NSString *)urlStr error:(NSError **)error
{
    if (urlStr.length == 0) {
        *error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Url为空"}];
        return nil;
    }
    NSError *theError;
    NSData *responseData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr] options:NSDataReadingUncached error:&theError];
    if (theError || responseData.length == 0) {
        *error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"请求失败"}];
        return nil;
    }
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&theError];
    if (theError || responseDict == nil) {
        *error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据解析失败"}];
        return nil;
    }
    return responseDict;
}

// 续AccessToken
- (void)doRefreshToken
{
    NSString *urlStr = [NSString stringWithFormat:TPAWeChatRefreshAccessTokenUrl, appId, self.refreshToken];
    dispatch_async(self.taskQueue, ^{
        NSError *error;
        NSDictionary *responseDict = [self parseJsonFromUrl:urlStr error:&error];
        if (error) {
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                       TPAErrorKey : error};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        } else if (responseDict[@"access_token"] == nil) {
            error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"请求失败"}];
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                       TPAErrorKey : error};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        } else {
            _accessToken = [responseDict[@"access_token"] description];
            NSTimeInterval expiresTime = [responseDict[@"expires_in"] doubleValue];
            _tokeExpirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresTime - 60];
            _refreshToken = [responseDict[@"refresh_token"] description];
            _openId = [responseDict[@"openid"] description];
            
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES),
                                       TPAWeChatAccountAccessTokenKey : self.accessToken,
                                       TPAWeChatAccountTokeExpirationDateKey : self.tokeExpirationDate,
                                       TPAWeChatAccountOpenIdKey : self.openId};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        }
    });
}

// 新Auth（授权第一步）
- (void)doAuth
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,post_timeline,snsapi_userinfo";
    req.state = nil;
    
    [WXApi sendAuthReq:req viewController:[UIViewController topmostViewController] delegate:self];
}

// 获取AccessToken（授权第二步）
- (void)requestNewAccessToken
{
    NSString *urlStr = [NSString stringWithFormat:TPAWeChatGetAccessTokenUrl, appId, secret, self.authCode];
    
    dispatch_async(self.taskQueue, ^{
        NSError *error;
        NSDictionary *responseDict = [self parseJsonFromUrl:urlStr error:&error];
        if (error) {
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                       TPAErrorKey : error};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        } else if (responseDict[@"access_token"] == nil) {
            error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"请求失败"}];
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                       TPAErrorKey : error};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        } else {
            _accessToken = [responseDict[@"access_token"] description];
            NSTimeInterval expiresTime = [responseDict[@"expires_in"] doubleValue];
            _tokeExpirationDate = [NSDate dateWithTimeIntervalSinceNow:expiresTime - 60];
            _refreshToken = [responseDict[@"refresh_token"] description];
            _openId = [responseDict[@"openid"] description];
            
            NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES),
                                       TPAWeChatAccountAccessTokenKey : self.accessToken,
                                       TPAWeChatAccountTokeExpirationDateKey : self.tokeExpirationDate,
                                       TPAWeChatAccountOpenIdKey : self.openId};
            [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
        }
    });
}


#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp*)resp;
        switch (authResp.errCode) {
            case 0: // 成功
            {
                self.authCode = authResp.code;
                [self requestNewAccessToken];
            }
                break;
            case -4: // 用户拒绝授权
            {
                NSError *error = [NSError errorWithDomain:@"TPAWeChatAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"微信授权失败"}];
                NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                           TPAErrorKey : error};
                [self notify:TPANotificationWeChatAccountDidLogin withUserInfo:userInfo];
            }
                break;
            case -2: // 用户取消授权
            default:
                break;
        }
    }
}

@end
