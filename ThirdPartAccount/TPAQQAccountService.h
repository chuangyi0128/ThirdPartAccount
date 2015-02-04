//
//  TPAQQAccountService.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPADefines.h"

// NotificationKeys
extern NSString * const TPANotificationQQAccountDidLogin;
extern NSString * const TPANotificationQQAccountDidLogout;
extern NSString * const TPANotificationQQAccountDidGetUserInfo;
extern NSString * const TPANotificationShareToQQFinished;

// PropertyKeys
extern NSString * const TPAQQAccountAccessTokenKey;
extern NSString * const TPAQQAccountTokeExpirationDateKey;
extern NSString * const TPAQQAccountOpenIdKey;
extern NSString * const TPAQQAccountUserNickNameKey;
extern NSString * const TPAQQAccountUserAvatarLinkKey;


@interface TPAQQAccountService : NSObject <TPAOAuthProtocal, TPAShareProtocal>

/** QQ已经授权登录 */
@property (nonatomic, assign, readonly) BOOL isAuthorized;

/** Access Token凭证，用于后续访问各开放接口 */
@property (nonatomic, copy, readonly) NSString *accessToken;

/** Access Token的失效期 */
@property (nonatomic, copy, readonly) NSDate *tokeExpirationDate;

/** 用户授权登录后对该用户的唯一标识 */
@property(nonatomic, copy, readonly) NSString *openId;

/** 登录用户的昵称 */
@property(nonatomic, copy, readonly) NSString *nickName;

/** 登录用户的头像链接 */
@property(nonatomic, copy, readonly) NSString *avatarLink;


/**
 *  @param  appId   第三方应用在互联开放平台申请的唯一标识
 */
+ (void)setAppId:(NSString *)theAppId;

/**
 *  获得service新实例。
 *  调用之前先设置appid，否则返回nil
 */
+ (instancetype)service;

/**
 * sdk是否可以处理应用拉起协议
 * @param   url     处理被其他应用呼起时的逻辑
 * @return  处理结果，YES表示可以 NO表示不行
 */
+ (BOOL)canHandleOpenURL:(NSURL *)url;

/**
 * 处理应用拉起协议
 * @param   url     处理被其他应用呼起时的逻辑
 * @return  处理结果，YES表示成功，NO表示失败
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 *  QQ登录，登录成功后自动获取用户帐号信息
 */
- (void)qqLogin;

/**
 *  QQ登出
 */
- (void)qqLogout;

/**
 *  获取登录用户的帐号信息。
 *  若登录失效则重新登录后自动获取用户帐号信息
 *  若重新登录失败则放弃获取用户信息
 */
- (void)getQQUserInfo;

/**
 *  QQ好友链接类型分享，可以附带一张预览图和多张大图
 *  @param  urlStr      分享的url链接
 *  @param  title       标题
 *  @param  desc        描述
 *  @param  prevImage   预览图，最大1MB
 */
- (void)shareToFriendsWithURL:(NSString *)urlStr
                        title:(NSString *)title
                  description:(NSString *)desc
                 previewImage:(UIImage *)prevImage;

/**
 *  QQ好友图片类型分享，可以附带一张预览图和多张大图
 *  @param  image       分享的大图
 *  @param  title       标题
 *  @param  desc        描述
 */
- (void)shareToFriendsWithImage:(UIImage *)image
                          title:(NSString *)title
                    description:(NSString *)desc;

/**
 *  QQ空间链接类型分享，可以附带一张预览图和多张大图
 *  @param  urlStr      分享的url链接
 *  @param  title       标题
 *  @param  desc        描述
 *  @param  prevImage   预览图，最大1MB
 */
- (void)shareToQZoneWithURL:(NSString *)urlStr
                      title:(NSString *)title
                description:(NSString *)desc
               previewImage:(UIImage *)prevImage;

/**
 *  QQ空间图片类型分享，可以附带一张预览图和多张大图
 *  @param  image       分享的大图
 *  @param  title       标题
 *  @param  desc        描述
 */
- (void)shareToQZoneWithImage:(UIImage *)image
                        title:(NSString *)title
                  description:(NSString *)desc;

@end
