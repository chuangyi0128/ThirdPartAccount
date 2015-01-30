//
//  TPAQQAccountService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAQQAccountService.h"
#import "TencentOAuth.h"

// NotificationKeys
NSString * const TPANotificationQQAccountDidLogin = @"TPANotificationQQAccountDidLogin";
NSString * const TPANotificationQQAccountDidLogout = @"TPANotificationQQAccountDidLogut";
NSString * const TPANotificationQQAccountDidGetUserInfo = @"TPANotificationQQAccountDidGetUserInfo";

// PropertyKeys
NSString * const TPAQQAccountAccessTokenKey = @"accessToken";
NSString * const TPAQQAccountTokeExpirationDateKey = @"tokeExpirationDate";
NSString * const TPAQQAccountOpenIdKey = @"openId";
NSString * const TPAQQAccountUserNickNameKey = @"nickName";
NSString * const TPAQQAccountUserAvatarLinkKey = @"avatarLink";


// Static Variable
static NSString *appId;


@interface TPAQQAccountService () <TencentSessionDelegate>
@property (nonatomic, strong) TencentOAuth *oauth;
@property (nonatomic, strong) NSArray *permissionsArray;
@end


@implementation TPAQQAccountService


#pragma mark - Public Methods

+ (void)setAppId:(NSString *)theAppId
{
    appId = theAppId;
}

+ (instancetype)service
{
    return [TPAQQAccountService new];
}

- (instancetype)init
{
    NSAssert(appId.length > 0, @"%s 'appId' must be not nil", __func__);
    
    if (appId) {
        self = [super init];
        if (self) {
            self.oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
            self.permissionsArray = @[kOPEN_PERMISSION_GET_INFO,
                                      kOPEN_PERMISSION_GET_USER_INFO,
                                      kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                      kOPEN_PERMISSION_ADD_TOPIC,
                                      kOPEN_PERMISSION_ADD_PIC_T];
        }
        return self;
    } else {
        return nil;
    }
}

+ (BOOL)canHandleOpenURL:(NSURL *)url
{
    return [TencentOAuth CanHandleOpenURL:url];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    return [TencentOAuth HandleOpenURL:url];
}

- (void)qqLogin
{
    if (self.oauth.isSessionValid) {
        return;
    }
    
    [self.oauth authorize:self.permissionsArray];
}

- (void)qqLogout
{
    if (self.oauth.isSessionValid) {
        [self.oauth logout:self];
    }
}

- (void)getQQUserInfo
{
    if (![self.oauth getUserInfo]) {
        [self qqLogin];
    }
}


#pragma mark - Private Methods

- (void)notify:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[userInfo copy]];
}

- (void)clear
{
    _accessToken = nil;
    _tokeExpirationDate = nil;
    _openId = nil;
}


#pragma mark - TencentSessionDelegate

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    [self clear];
    
    if (self.oauth.accessToken.length > 0) {
        _accessToken = self.oauth.accessToken;
        _tokeExpirationDate = self.oauth.expirationDate;
        _openId = self.oauth.openId;
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
        if (self.accessToken.length > 0) {
            userInfo[TPAQQAccountAccessTokenKey] = self.accessToken;
        }
        if (self.tokeExpirationDate) {
            userInfo[TPAQQAccountTokeExpirationDateKey] = self.tokeExpirationDate;
        }
        if (self.openId.length > 0) {
            userInfo[TPAQQAccountOpenIdKey] = self.openId;
        }
        [self notify:TPANotificationQQAccountDidLogin withUserInfo:userInfo];
        
        [self getQQUserInfo];
    } else {
        NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"QQ登陆失败"}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : error};
        [self notify:TPANotificationQQAccountDidLogin withUserInfo:userInfo];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (!cancelled) {
        NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"QQ登陆失败"}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : error};
        [self notify:TPANotificationQQAccountDidLogin withUserInfo:userInfo];
    }
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:TPANetworkErrorDesc}];
    [self notify:TPANotificationNetworkError withUserInfo:@{TPAErrorKey:error}];
}

/**
 * 退出登录的回调
 */
- (void)tencentDidLogout
{
    [self clear];
    
    NSDictionary *userInfo = @{TPASucceedFlagKey : @(YES)};
    [self notify:TPANotificationQQAccountDidLogout withUserInfo:userInfo];
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*)response
{
    if (response.retCode == URLREQUEST_SUCCEED && response.detailRetCode == kOpenSDKErrorSuccess) { // 获取成功
        _accessToken = self.oauth.accessToken;
        _tokeExpirationDate = self.oauth.expirationDate;
        _openId = self.oauth.openId;
        _nickName = [response.jsonResponse[@"nickname"] description];
        _avatarLink = [response.jsonResponse[@"figureurl_qq_2"] description];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
        if (self.nickName.length > 0) {
            userInfo[TPAQQAccountUserNickNameKey] = self.nickName;
        }
        if (self.avatarLink.length > 0) {
            userInfo[TPAQQAccountUserAvatarLinkKey] = self.avatarLink;
        }
        [self notify:TPANotificationQQAccountDidGetUserInfo withUserInfo:userInfo];
    } else { // 获取失败
        NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"QQ获取用户信息失败"}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : error};
        [self notify:TPANotificationQQAccountDidGetUserInfo withUserInfo:userInfo];
    }
}

@end
