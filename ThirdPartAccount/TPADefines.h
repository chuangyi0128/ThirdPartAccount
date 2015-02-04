//
//  TPADefines.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString * const TPANotificationNetworkError = @"TPANotificationNetworkError";

static NSString * const TPASucceedFlagKey = @"TPASucceedFlagKey";
static NSString * const TPAErrorKey = @"TPAErrorKey";

static NSString * const TPANetworkErrorDesc = @"网络不给力";


/** TPAOAuthProtocal */
@protocol TPAOAuthProtocal <NSObject>
@required
- (BOOL)isAuthEnable;
@end



/** 提供给用户的可选分享途径，多个可用"|"并列 */
typedef NS_OPTIONS(NSUInteger, TPAShareTo)
{
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToQQFriend      = 1 << 0,
    
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToQZone         = 1 << 1,
    
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToWeChatFriend  = 1 << 2,
    
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToWeChatMoment  = 1 << 3,
    
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToYiXinFriend   = 1 << 4,
    
    /** 可选参数: title, image, content, linkUrlStr */
    TPAShareToYiXinTimeLine   = 1 << 5,
    
    /** 可选参数: title, image, content */
    TPAShareToSinaWeibo     = 1 << 6,
    
    /** 可选参数: content */
    TPAShareToSMS           = 1 << 7,
    
    /** 可选参数: title, content */
    TPAShareToEmail         = 1 << 8,
    
    /** 可选参数: All */
    TPAShareToAll           = NSUIntegerMax,
};


/** TPAShareProtocal */
@protocol TPAShareProtocal <NSObject>
@required
- (BOOL)isShareEnable;

@end
