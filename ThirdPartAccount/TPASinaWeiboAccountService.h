//
//  TPASinaWeiboAccountService.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPADefines.h"
#import "WeiboSDK.h"

// NotificationKeys
extern NSString * const TPANotificationSinaWeiboAccountDidLogin;
extern NSString * const TPANotificationSinaWeiboAccountDidLogout;
extern NSString * const TPANotificationSinaWeiboAccountDidGetUserInfo;
extern NSString * const TPANotificationShareToSinaWeiboFinished;

// PropertyKeys
extern NSString * const TPASinaWeiboAccountAccessTokenKey;
extern NSString * const TPASinaWeiboAccountTokeExpirationDateKey;
extern NSString * const TPASinaWeiboAccountUserIdKey;
extern NSString * const TPASinaWeiboAccountUserNickNameKey;
extern NSString * const TPASinaWeiboAccountUserAvatarLinkKey;


@interface TPASinaWeiboAccountService : NSObject <TPAOAuthProtocal, TPAShareProtocal, WeiboSDKDelegate>

/** SinaWeibo已经授权登录 */
@property (nonatomic, assign, readonly) BOOL isAuthorized;

/** Access Token凭证，用于后续访问各开放接口 */
@property (nonatomic, copy, readonly) NSString *accessToken;

/** Access Token的失效期 */
@property (nonatomic, copy, readonly) NSDate *tokeExpirationDate;

/** Refresh Token 用户刷新access_token */
@property (nonatomic, copy, readonly) NSString *refreshToken;

/** 登录用户的ID */
@property (nonatomic, copy, readonly) NSString *userId;

/** 登录用户的昵称 */
@property (nonatomic, copy, readonly) NSString *nickName;

/** 登录用户的头像链接 */
@property (nonatomic, copy, readonly) NSString *avatarLink;


/**
 *  @param  theAppKey   第三方应用在互联开放平台申请的唯一标识
 */
+ (void)setAppKey:(NSString *)theAppKey;

/**
 *  @param  url   微博开放平台第三方应用授权回调页地址，默认为`http://`
 *  @warning 必须保证和在微博开放平台应用管理界面配置的“授权回调页”地址一
 *              致，如未进行配置则默认为`http://`
 *  @warning 不能为空，长度小于1K
 */
+ (void)setWeiboRedirectUrl:(NSString *)url;

/**
 *  获得service新实例。
 *  调用之前先设置appid和secret，否则返回nil
 */
+ (instancetype)service;

/*! @brief 处理Weibo通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。此处
 *                  传入TPASinaWeiboAccountService对象即可
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url delegate:(id <WeiboSDKDelegate>)delegate;

/**
 *  Sina Weibo登录，登录成功后自动获取用户帐号信息
 */
- (void)weiboLogin;

/**
 *  Sina Weibo登出
 */
- (void)weiboLogout;

/**
 *  获取登录用户的帐号信息。
 *  若登录失效则重新登录后自动获取用户帐号信息
 *  若重新登录失败则放弃获取用户信息
 */
- (void)getWeiboUserInfo;

/**
 *  Weibo链接类型分享，可以附带一张预览图和多张大图
 *  @param  urlStr      分享的url链接
 *  @param  title       标题
 *  @param  desc        描述
 *  @param  prevImage   预览图
 */
- (void)shareToWeiboWithURL:(NSString *)urlStr
                        title:(NSString *)title
                  description:(NSString *)desc
                 previewImage:(UIImage *)prevImage;

/**
 *  Weibo图片类型分享(无图片时分享文字)，可以附带一张预览图和多张大图
 *  @param  image       分享的大图
 *  @param  title       标题
 *  @param  desc        描述
 */
- (void)shareToWeiboWithImage:(UIImage *)image
                          title:(NSString *)title
                    description:(NSString *)desc;

@end
