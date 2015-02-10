//
//  TPAAccountService.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/31/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPADefines.h"


// NotificationKeys
extern NSString * const TPANotificationDidLogin;
extern NSString * const TPANotificationDidGetUserInfo;

// PropertyKeys
extern NSString * const TPAAccountAccessTokenKey;
extern NSString * const TPAAccountTokeExpirationDateKey;
extern NSString * const TPAAccountOpenIdKey;
extern NSString * const TPAAccountUserIdKey;
extern NSString * const TPAAccountUserNickNameKey;
extern NSString * const TPAAccountUserAvatarLinkKey;
extern NSString * const TPAAccountUserSexKey;
extern NSString * const TPAAccountUserProvinceKey;
extern NSString * const TPAAccountUserCityKey;


#pragma mark - TPAAccountService

@interface TPAAccountService : NSObject

#pragma mark 授权信息

/** 第三方平台的授权登录状态 */
@property (nonatomic, assign, readonly) TPAAuthType authType;

/** Access Token凭证，用于后续访问各开放接口 */
@property (nonatomic, copy, readonly) NSString *accessToken;

/** Access Token的失效期 */
@property (nonatomic, copy, readonly) NSDate *tokeExpirationDate;

/** 用户授权登录后对该用户的唯一标识 */
@property (nonatomic, copy, readonly) NSString *openId;


#pragma mark 用户信息

/** 第三方平台的用户id */
@property (nonatomic, copy, readonly) NSString *userId;

/** 第三方平台的用户昵称 */
@property (nonatomic, copy, readonly) NSString *nickName;

/** 第三方平台的用户头像链接 */
@property (nonatomic, copy, readonly) NSString *avatarLink;

/** 第三方平台的用户性别：1为男性，2为女性 */
@property (nonatomic, copy, readonly) NSString *sex;

/** 第三方平台的用户省份 */
@property (nonatomic, copy, readonly) NSString *province;

/** 第三方平台的用户城市 */
@property (nonatomic, copy, readonly) NSString *city;


#pragma mark Public Methods

/**
 *  统一的登录接口
 *  @return 若当前authType登录可用，返回YES，否则返回NO
 */
- (BOOL)auth:(TPAAuthType)authType;

/** 取消当前登录 */
- (void)logout;

@end
