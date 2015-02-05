//
//  TPAWeChatAccountService.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPADefines.h"
#import "WXApi.h"

// NotificationKeys
extern NSString * const TPANotificationWeChatAccountDidLogin;
extern NSString * const TPANotificationWeChatAccountDidLogout;
extern NSString * const TPANotificationWeChatAccountDidGetUserInfo;
extern NSString * const TPANotificationShareToWeChatFinished;

// PropertyKeys
extern NSString * const TPAWeChatAccountAccessTokenKey;
extern NSString * const TPAWeChatAccountTokeExpirationDateKey;
extern NSString * const TPAWeChatAccountOpenIdKey;
extern NSString * const TPAWeChatAccountUserUnionIdKey;
extern NSString * const TPAWeChatAccountUserNickNameKey;
extern NSString * const TPAWeChatAccountUserSexKey;
extern NSString * const TPAWeChatAccountUserProvinceKey;
extern NSString * const TPAWeChatAccountUserCityKey;
extern NSString * const TPAWeChatAccountUserAvatarLinkKey;


@interface TPAWeChatAccountService : NSObject <TPAOAuthProtocal, TPAShareProtocal, WXApiDelegate>

/** weChat已经授权登录 */
@property (nonatomic, assign, readonly) BOOL isAuthorized;

/** Access Token凭证，用于后续访问各开放接口 */
@property (nonatomic, copy, readonly) NSString *accessToken;

/** Access Token的失效期 */
@property (nonatomic, copy, readonly) NSDate *tokeExpirationDate;

/** Refresh Token 用户刷新access_token */
@property (nonatomic, copy, readonly) NSString *refreshToken;

/** 用户授权登录后对该用户的唯一标识 */
@property (nonatomic, copy, readonly) NSString *openId;

/** 登录用户的唯一ID */
@property (nonatomic, copy, readonly) NSString *unionId;

/** 登录用户的昵称 */
@property (nonatomic, copy, readonly) NSString *nickName;

/** 性别：1为男性，2为女性 */
@property (nonatomic, copy, readonly) NSString *sex;

/** 省份 */
@property (nonatomic, copy, readonly) NSString *province;

/** 城市 */
@property (nonatomic, copy, readonly) NSString *city;

/** 登录用户的头像链接 */
@property (nonatomic, copy, readonly) NSString *avatarLink;


/**
 *  @param  appId   第三方应用在互联开放平台申请的唯一标识
 */
+ (void)setAppId:(NSString *)theAppId;

/**
 *  @param  secret  应用密钥AppSecret，在微信开放平台提交
 *                  应用审核通过后获得
 */
+ (void)setSecret:(NSString *)theSecret;

/**
 *  获得service新实例。
 *  调用之前先设置appid和secret，否则返回nil
 */
+ (instancetype)service;

/*! @brief 处理微信通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。此处
 *                  传入TPAWeChatAccountService对象即可
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id <WXApiDelegate>)delegate;

/**
 *  WeChat登录，登录成功后自动获取用户帐号信息
 */
- (void)weChatLogin;

/**
 *  WeChat登出
 */
- (void)weChatLogout;

/**
 *  获取登录用户的帐号信息。
 *  若登录失效则重新登录后自动获取用户帐号信息
 *  若重新登录失败则放弃获取用户信息
 */
- (void)getWeChatUserInfo;

/**
 *  WeChat好友链接类型分享，可以附带一张预览图和多张大图
 *  @param  urlStr      分享的url链接
 *  @param  title       标题
 *  @param  desc        描述
 *  @param  prevImage   预览图，最大1MB
 */
- (void)shareToWeChatFriendsWithURL:(NSString *)urlStr
                        title:(NSString *)title
                  description:(NSString *)desc
                 previewImage:(UIImage *)prevImage;

/**
 *  WeChat好友图片类型分享，可以附带一张预览图和多张大图
 *  @param  image       分享的大图
 *  @param  title       标题
 *  @param  desc        描述
 */
- (void)shareToWeChatFriendsWithImage:(UIImage *)image
                          title:(NSString *)title
                    description:(NSString *)desc;

/**
 *  WeChat朋友圈链接类型分享，可以附带一张预览图和多张大图
 *  @param  urlStr      分享的url链接
 *  @param  title       标题
 *  @param  desc        描述
 *  @param  prevImage   预览图，最大1MB
 */
- (void)shareToWeChatMomentWithURL:(NSString *)urlStr
                      title:(NSString *)title
                description:(NSString *)desc
               previewImage:(UIImage *)prevImage;

/**
 *  WeChat朋友圈图片类型分享，可以附带一张预览图和多张大图
 *  @param  image       分享的大图
 *  @param  title       标题
 *  @param  desc        描述
 */
- (void)shareToWeChatMomentWithImage:(UIImage *)image
                               title:(NSString *)title
                         description:(NSString *)desc;

@end
