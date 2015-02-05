//
//  TPASingletonManager.h
//  ThirdPartAccount
//
//  Created by SongLi on 2/5/15.
//  Copyright (c) 2015 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPAQQAccountService.h"
#import "TPAWeChatAccountService.h"
#import "TPAShareService.h"

@interface TPASingletonManager : NSObject

+ (TPAQQAccountService *)sharedQQService;

+ (TPAWeChatAccountService *)sharedWeChatService;

@end
