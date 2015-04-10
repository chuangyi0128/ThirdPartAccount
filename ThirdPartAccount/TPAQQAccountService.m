//
//  TPAQQAccountService.m
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAQQAccountService.h"
#import "TencentOAuth.h"
#import "QQApiInterface.h"
#import "UIImage+Resize.h"
#import "UIImage+Crop.h"

// NotificationKeys
NSString * const TPANotificationQQAccountDidLogin = @"TPANotificationQQAccountDidLogin";
NSString * const TPANotificationQQAccountDidLogout = @"TPANotificationQQAccountDidLogut";
NSString * const TPANotificationQQAccountDidGetUserInfo = @"TPANotificationQQAccountDidGetUserInfo";
NSString * const TPANotificationShareToQQFinished = @"TPANotificationShareToQQFinished";

// PropertyKeys
NSString * const TPAQQAccountAccessTokenKey = @"accessToken";
NSString * const TPAQQAccountTokeExpirationDateKey = @"tokeExpirationDate";
NSString * const TPAQQAccountOpenIdKey = @"openId";
NSString * const TPAQQAccountUserNickNameKey = @"nickName";
NSString * const TPAQQAccountUserAvatarLinkKey = @"avatarLink";


// Static Variable
static NSString *appId;


@interface TPAQQAccountService () <TencentSessionDelegate>
@property (nonatomic, assign) dispatch_queue_t taskQueue;
@property (nonatomic, strong) TencentOAuth *oauth;
@property (nonatomic, strong) NSArray *permissionsArray;
@end


@implementation TPAQQAccountService


#pragma mark - Public Methods

+ (void)setAppId:(NSString *)theAppId
{
    appId = theAppId;
}

+ (instancetype)sharedService
{
    static TPAQQAccountService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [TPAQQAccountService new];
    });
    return instance;
}

- (instancetype)init
{
    if (appId) {
        self = [super init];
        if (self) {
            self.taskQueue = dispatch_queue_create(NSStringFromClass(self.class).UTF8String, DISPATCH_QUEUE_CONCURRENT);
            self.oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
            self.permissionsArray = @[kOPEN_PERMISSION_GET_INFO,
                                      kOPEN_PERMISSION_ADD_TOPIC,
                                      kOPEN_PERMISSION_ADD_PIC_T];
        }
        return self;
    } else {
        return nil;
    }
}

- (void)dealloc
{
    if (self.taskQueue) {
        dispatch_release(self.taskQueue);
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


#pragma mark 登录

- (BOOL)isAuthEnable
{
    return YES;
}

- (BOOL)isAuthorized
{
    return self.oauth.isSessionValid;
}

- (void)qqLogin
{
    if (!self.oauth.isSessionValid) {
        [self.oauth authorize:self.permissionsArray];
    }
}

- (void)qqLogout
{
    if (self.oauth.isSessionValid) {
        [self.oauth logout:self];
        // QQSDK的Bug吗：logout之后oauth无法重新authorize
        self.oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    }
}

- (void)getQQUserInfo
{
    if (![self.oauth getUserInfo]) {
        [self qqLogin];
    }
}


#pragma mark 分享

- (BOOL)isShareEnable
{
    return YES;
}

- (void)shareToFriendsWithURL:(NSString *)urlStr title:(NSString *)title description:(NSString *)desc previewImage:(UIImage *)prevImage
{
    dispatch_async(self.taskQueue, ^{
        SendMessageToQQReq *reqest = [self requestWithURL:urlStr title:title description:desc previewImage:prevImage];
        if (reqest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QQApiSendResultCode code = [QQApiInterface sendReq:reqest];
                [self proceedShareResult:code];
            });
        }
    });
}

- (void)shareToFriendsWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)desc
{
    dispatch_async(self.taskQueue, ^{
        SendMessageToQQReq *reqest = [self requestWithImage:image title:title description:desc];
        if (reqest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QQApiSendResultCode code = [QQApiInterface sendReq:reqest];
                [self proceedShareResult:code];
            });
        }
    });
}

- (void)shareToQZoneWithURL:(NSString *)urlStr title:(NSString *)title description:(NSString *)desc previewImage:(UIImage *)prevImage
{
    dispatch_async(self.taskQueue, ^{
        SendMessageToQQReq *reqest = [self requestWithURL:urlStr title:title description:desc previewImage:prevImage];
        if (reqest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QQApiSendResultCode code = [QQApiInterface sendReq:reqest];
                [self proceedShareResult:code];
            });
        }
    });
}

- (void)shareToQZoneWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)desc
{
    dispatch_async(self.taskQueue, ^{
        SendMessageToQQReq *reqest = [self requestWithImage:image title:title description:desc];
        if (reqest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                QQApiSendResultCode code = [QQApiInterface sendReq:reqest];
                [self proceedShareResult:code];
            });
        }
    });
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
    _nickName = nil;
    _avatarLink = nil;
}

- (SendMessageToQQReq *)requestWithURL:(NSString *)urlStr title:(NSString *)title description:(NSString *)desc previewImage:(UIImage *)prevImage
{
    if (urlStr.length == 0) {
        return nil;
    }
    if (title.length == 0) {
        title = @"快来看看我的分享";
    }
    
    NSData *prevImageData = nil;
    if (prevImage) {
        prevImage = [prevImage cropToSquareInCenter];
        prevImage = [prevImage resizedImageToSize:CGSizeMake(300, 300)];
        prevImageData = UIImageJPEGRepresentation(prevImage, 1.0f);
        
        for (int i = 1; prevImageData.length > 1024 * 1024 * 0.9f; i++) {
            prevImageData = UIImageJPEGRepresentation(prevImage, 1.0f - 0.2f * i);
        }
    }
    
    QQApiNewsObject *msgObject = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlStr]
                                                        title:title
                                                  description:desc
                                             previewImageData:prevImageData];
    
    return [SendMessageToQQReq reqWithContent:msgObject];
}

- (SendMessageToQQReq *)requestWithImage:(UIImage *)image title:(NSString *)title description:(NSString *)desc
{
    if (image == nil && title.length == 0 && desc.length == 0) {
        return nil;
    }
    
    QQApiObject *msgObject = nil;
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
        UIImage *prevImage = [image resizedImageToFitInSize:CGSizeMake(500, 500) scaleIfSmaller:NO];
        NSData *prevImageData = UIImageJPEGRepresentation(prevImage, 1.0f);
        
        for (int i = 1; imageData.length > 1024 * 1024 * 4.9f; i++) {
            image = [image resizedImageToFitInSize:CGSizeMake(image.size.width * 0.8f, image.size.height * 0.8f) scaleIfSmaller:NO];
            imageData = UIImageJPEGRepresentation(image, MAX(1.0f - 0.2f * i, 0.5f));
        }
        for (int i = 1; prevImageData.length > 1024 * 1024 * 0.9f; i++) {
            prevImage = [prevImage resizedImageToFitInSize:CGSizeMake(prevImage.size.width * 0.8f, prevImage.size.height * 0.8f) scaleIfSmaller:NO];
            prevImageData = UIImageJPEGRepresentation(image, 1.0f - 0.2f * i);
        }
        
        if (title.length == 0) {
            title = @"快来看看我的分享";
        }
        msgObject = [QQApiImageObject objectWithData:imageData
                                    previewImageData:prevImageData
                                               title:title
                                         description:desc];
    } else {
        if (desc.length > 0) {
            msgObject = [QQApiTextObject objectWithText:desc];
        } else {
            msgObject = [QQApiTextObject objectWithText:title];
        }
    }
    
    return [SendMessageToQQReq reqWithContent:msgObject];
}

- (void)proceedShareResult:(QQApiSendResultCode)code
{
    NSString *resultDesc = nil;
    switch (code) {
        case EQQAPISENDSUCESS:
        {
            NSLog(@"成功跳转到QQ");
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(YES) forKey:TPASucceedFlagKey];
            [self notify:TPANotificationShareToQQFinished withUserInfo:userInfo];
            return;
        }
            break;
        case EQQAPIQQNOTINSTALLED:
            resultDesc = @"请先安装QQ客户端";
            break;
        case EQQAPIQQNOTSUPPORTAPI:
            resultDesc = @"QQ API不被支持";
            break;
        case EQQAPIMESSAGETYPEINVALID:
            resultDesc = @"暂不支持此类型分享";
            break;
        case EQQAPIMESSAGECONTENTNULL:
            resultDesc = @"分享内容为空";
            break;
        case EQQAPIMESSAGECONTENTINVALID:
            resultDesc = @"分享内容不合法";
            break;
        case EQQAPIAPPNOTREGISTED:
            resultDesc = @"App未注册到QQ平台";
            break;
        case EQQAPIAPPSHAREASYNC:
            resultDesc = @"异步分享中";
            break;
        case EQQAPIQZONENOTSUPPORTTEXT:
            resultDesc = @"QQ空间不支持文本分享";
            break;
        case EQQAPIQZONENOTSUPPORTIMAGE:
            resultDesc = @"QQ空间不支持图片分享";
            break;
            
        case EQQAPISENDFAILD:
        default:
            resultDesc = @"网络不给力，分享发送失败";
            break;
    }
    NSLog(@"%@", resultDesc);
    
    NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:resultDesc}];
    NSDictionary *userInfo = @{TPASucceedFlagKey : @(NO),
                               TPAErrorKey : error};
    [self notify:TPANotificationShareToQQFinished withUserInfo:userInfo];
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
        NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败"}];
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
        NSError *error = [NSError errorWithDomain:@"TPAQQAccountService" code:0 userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败"}];
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

/**
 * 因用户未授予相应权限而需要执行增量授权。在用户调用某个api接口时，如果服务器返回操作未被授权，则触发该回调协议接口，由第三方决定是否跳转到增量授权页面，让用户重新授权。
 * \param tencentOAuth 登录授权对象。
 * \param permissions 需增量授权的权限列表。
 * \return 是否仍然回调返回原始的api请求结果。
 * \note 不实现该协议接口则默认为不开启增量授权流程。若需要增量授权请调用\ref TencentOAuth#incrAuthWithPermissions: \n注意：增量授权时用户可能会修改登录的帐号
 */
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions
{
    return YES;
}

/**
 * 用户通过增量授权流程重新授权登录，token及有效期限等信息已被更新。
 * \param tencentOAuth token及有效期限等信息更新后的授权实例对象
 * \note 第三方应用需更新已保存的token及有效期限等信息。
 */
- (void)tencentDidUpdate:(TencentOAuth *)tencentOAuth
{
    
}

/**
 * 用户增量授权过程中因取消或网络问题导致授权失败
 * \param reason 授权失败原因，具体失败原因参见sdkdef.h文件中\ref UpdateFailType
 */
- (void)tencentFailedUpdate:(UpdateFailType)reason
{
    
}

/**
 * 通知第三方界面需要被关闭
 * \param tencentOAuth 返回回调的tencentOAuth对象
 * \param viewController 需要关闭的viewController
 */
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    
}

/**
 * 分享到QZone回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/addShareResponse.exp success
 *          错误返回示例: \snippet example/addShareResponse.exp fail
 */
- (void)addShareResponse:(APIResponse*)response
{
    
}

@end
