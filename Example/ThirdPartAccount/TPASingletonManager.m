//
//  TPASingletonManager.m
//  ThirdPartAccount
//
//  Created by SongLi on 2/5/15.
//  Copyright (c) 2015 SongLi. All rights reserved.
//

#import "TPASingletonManager.h"

@implementation TPASingletonManager

+ (TPAQQAccountService *)sharedQQService
{
    [TPAQQAccountService setAppId:@"222222"];
    return [TPAQQAccountService sharedService];
}

+ (TPAWeChatAccountService *)sharedWeChatService
{
    [TPAWeChatAccountService setAppId:@"wxd930ea5d5a258f4f"];
    [TPAWeChatAccountService setSecret:@"0c806938e2413ce73eef92cc3"];
    return [TPAWeChatAccountService sharedService];
}

+ (TPASinaWeiboAccountService *)sharedSinaWeiboService
{
    [TPASinaWeiboAccountService setAppKey:@"2045436852"];
    [TPASinaWeiboAccountService setWeiboRedirectUrl:@"http://www.sina.com"];
    return [TPASinaWeiboAccountService sharedService];
}

@end
