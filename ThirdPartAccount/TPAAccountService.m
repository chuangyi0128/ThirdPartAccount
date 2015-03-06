//
//  TPAAccountService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/31/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAAccountService.h"
#import "TPAQQAccountService.h"
#import "TPAWeChatAccountService.h"
#import "TPASinaWeiboAccountService.h"

// NotificationKeys
NSString * const TPANotificationDidLogin = @"TPANotificationDidLogin";
NSString * const TPANotificationDidGetUserInfo = @"TPANotificationDidGetUserInfo";

// PropertyKeys
NSString * const TPAAccountAuthType = @"authType";
NSString * const TPAAccountAccessTokenKey = @"accessToken";
NSString * const TPAAccountTokeExpirationDateKey = @"tokeExpirationDate";
NSString * const TPAAccountOpenIdKey = @"openId";
NSString * const TPAAccountUserIdKey = @"userId";
NSString * const TPAAccountUserNickNameKey = @"nickName";
NSString * const TPAAccountUserAvatarLinkKey = @"avatarLink";
NSString * const TPAAccountUserSexKey = @"sex";
NSString * const TPAAccountUserProvinceKey = @"province";
NSString * const TPAAccountUserCityKey = @"city";


@interface TPAAccountService ()

@end


@implementation TPAAccountService

#pragma mark Public Methods

- (BOOL)auth:(TPAAuthType)authType
{
    switch (authType) {
        case TPAAuthTypeQQ:
            if ([self.qqService isAuthEnable]) {
                [self clearCurrentAuth];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQLogin:) name:TPANotificationQQAccountDidLogin object:self.qqService];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQQUserInfo:) name:TPANotificationQQAccountDidGetUserInfo object:self.qqService];
                
                [self.qqService qqLogin];
                return YES;
            }
            break;
        case TPAAuthTypeWeChat:
            if ([self.weChatService isAuthEnable]) {
                [self clearCurrentAuth];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatLogin:) name:TPANotificationWeChatAccountDidLogin object:self.weChatService];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeChatUserInfo:) name:TPANotificationWeChatAccountDidGetUserInfo object:self.weChatService];
                
                [self.weChatService weChatLogin];
                return YES;
            }
            break;
        case TPAAuthTypeYiXin:
            return NO;
            break;
        case TPAAuthTypeSinaWeibo:
            if ([self.sinaWeiboSerivce isAuthEnable]) {
                [self clearCurrentAuth];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboLogin:) name:TPANotificationSinaWeiboAccountDidLogin object:self.sinaWeiboSerivce];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSinaWeiboUserInfo:) name:TPANotificationSinaWeiboAccountDidGetUserInfo object:self.sinaWeiboSerivce];
                
                [self.sinaWeiboSerivce weiboLogin];
                return YES;
            }
            break;
            
        default:
            break;
    }
    return NO;
}

- (void)logout
{
    [self clearCurrentAuth];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods

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

- (void)clearCurrentAuth
{
    switch (self.authType) {
        case TPAAuthTypeQQ:
            [[TPAQQAccountService sharedService] qqLogout];
            break;
        case TPAAuthTypeWeChat:
            [[TPAWeChatAccountService sharedService] weChatLogout];
            break;
        case TPAAuthTypeYiXin:
            break;
        case TPAAuthTypeSinaWeibo:
            [[TPASinaWeiboAccountService sharedService] weiboLogout];
            break;
            
        default:
            break;
    }
    _authType = TPANotAuthorize;
    
    _accessToken = nil;
    _tokeExpirationDate = nil;
    _openId = nil;
    
    _userId = nil;
    _nickName = nil;
    _avatarLink = nil;
    _sex = nil;
    _province = nil;
    _city = nil;
}

- (void)notify:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[userInfo copy]];
}

- (void)notifyLoginSucceed
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
    if (self.accessToken.length > 0) {
        userInfo[TPAAccountAccessTokenKey] = self.accessToken;
    }
    if (self.tokeExpirationDate) {
        userInfo[TPAAccountTokeExpirationDateKey] = self.tokeExpirationDate;
    }
    if (self.openId.length > 0) {
        userInfo[TPAAccountOpenIdKey] = self.openId;
    }
    if (self.authType > TPANotAuthorize && self.authType < TPAAuthTypeMax) {
        userInfo[TPAAccountAuthType] = @(self.authType);
    }
    [self notify:TPANotificationDidLogin withUserInfo:userInfo];
}

- (void)notifyGetUserInfoSucceed
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
    if (self.userId.length > 0) {
        userInfo[TPAAccountUserIdKey] = self.userId;
    }
    if (self.nickName.length > 0) {
        userInfo[TPAAccountUserNickNameKey] = self.nickName;
    }
    if (self.avatarLink.length > 0) {
        userInfo[TPAAccountUserAvatarLinkKey] = self.avatarLink;
    }
    if (self.sex.length > 0) {
        userInfo[TPAAccountUserSexKey] = self.sex;
    }
    if (self.province.length > 0) {
        userInfo[TPAAccountUserProvinceKey] = self.province;
    }
    if (self.city.length > 0) {
        userInfo[TPAAccountUserCityKey] = self.city;
    }
    [self notify:TPANotificationDidGetUserInfo withUserInfo:userInfo];
}


#pragma mark - Notifications

- (void)handleQQLogin:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _authType = TPAAuthTypeQQ;
        _accessToken = noti.userInfo[TPAQQAccountAccessTokenKey];
        _tokeExpirationDate = noti.userInfo[TPAQQAccountTokeExpirationDateKey];
        _openId = noti.userInfo[TPAQQAccountOpenIdKey];
        
        [self notifyLoginSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError,
                                   TPAAccountAuthType : @(TPAAuthTypeQQ)};
        [self notify:TPANotificationDidLogin withUserInfo:userInfo];
    }
}

- (void)handleWeChatLogin:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _authType = TPAAuthTypeWeChat;
        _accessToken = noti.userInfo[TPAWeChatAccountAccessTokenKey];
        _tokeExpirationDate = noti.userInfo[TPAWeChatAccountTokeExpirationDateKey];
        _openId = noti.userInfo[TPAWeChatAccountOpenIdKey];
        
        [self notifyLoginSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError,
                                   TPAAccountAuthType : @(TPAAuthTypeQQ)};
        [self notify:TPANotificationDidLogin withUserInfo:userInfo];
    }
}

- (void)handleSinaWeiboLogin:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _authType = TPAAuthTypeWeChat;
        _accessToken = noti.userInfo[TPASinaWeiboAccountAccessTokenKey];
        _tokeExpirationDate = noti.userInfo[TPASinaWeiboAccountTokeExpirationDateKey];
        _openId = noti.userInfo[TPASinaWeiboAccountUserIdKey];
        
        [self notifyLoginSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError,
                                   TPAAccountAuthType : @(TPAAuthTypeQQ)};
        [self notify:TPANotificationDidLogin withUserInfo:userInfo];
    }
}

- (void)handleQQUserInfo:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _nickName = noti.userInfo[TPAQQAccountUserNickNameKey];
        _avatarLink = noti.userInfo[TPAQQAccountUserAvatarLinkKey];
        
        [self notifyGetUserInfoSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError};
        [self notify:TPANotificationDidGetUserInfo withUserInfo:userInfo];
    }
}

- (void)handleWeChatUserInfo:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _userId = noti.userInfo[TPAWeChatAccountUserUnionIdKey];
        _nickName = noti.userInfo[TPAWeChatAccountUserNickNameKey];
        _avatarLink = noti.userInfo[TPAWeChatAccountUserAvatarLinkKey];
        _sex = noti.userInfo[TPAWeChatAccountUserSexKey];
        _province = noti.userInfo[TPAWeChatAccountUserProvinceKey];
        _city = noti.userInfo[TPAWeChatAccountUserCityKey];
        
        [self notifyGetUserInfoSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError};
        [self notify:TPANotificationDidGetUserInfo withUserInfo:userInfo];
    }
}

- (void)handleSinaWeiboUserInfo:(NSNotification *)noti
{
    BOOL succeed = [noti.userInfo[TPASucceedFlagKey] boolValue];
    if (succeed) {
        _userId = noti.userInfo[TPASinaWeiboAccountUserIdKey];
        _nickName = noti.userInfo[TPASinaWeiboAccountUserNickNameKey];
        _avatarLink = noti.userInfo[TPASinaWeiboAccountUserAvatarLinkKey];
        
        [self notifyGetUserInfoSucceed];
    } else {
        NSError *error = noti.userInfo[TPAErrorKey];
        NSError *newError = [NSError errorWithDomain:@"TPAAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                                   TPAErrorKey : newError};
        [self notify:TPANotificationDidGetUserInfo withUserInfo:userInfo];
    }
}

@end
