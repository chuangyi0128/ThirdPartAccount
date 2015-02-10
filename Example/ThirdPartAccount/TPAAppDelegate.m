//
//  TPAAppDelegate.m
//  ThirdPartAccount
//
//  Created by CocoaPods on 01/30/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import "TPAAppDelegate.h"
#import "TPAQQAccountService.h"
#import "TPAWeChatAccountService.h"
#import "TPASinaWeiboAccountService.h"

@implementation TPAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TPAQQAccountService setAppId:@"222222"];
    
    [TPAWeChatAccountService setAppId:@"wxd930ea5d5a258f4f"];
    [TPAWeChatAccountService setSecret:@"0c806938e2413ce73eef92cc3"];
    
    [TPASinaWeiboAccountService setAppKey:@"2045436852"];
    [TPASinaWeiboAccountService setWeiboRedirectUrl:@"http://www.sina.com"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([TPAQQAccountService handleOpenURL:url]) {
        return YES;
    } else if ([TPAWeChatAccountService handleOpenURL:url delegate:[TPAWeChatAccountService sharedService]]) {
        return YES;
    } else if ([TPASinaWeiboAccountService handleOpenURL:url delegate:[TPASinaWeiboAccountService sharedService]]) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([TPAQQAccountService handleOpenURL:url]) {
        return YES;
    } else if ([TPAWeChatAccountService handleOpenURL:url delegate:[TPAWeChatAccountService sharedService]]) {
        return YES;
    } else if ([TPASinaWeiboAccountService handleOpenURL:url delegate:[TPASinaWeiboAccountService sharedService]]) {
        return YES;
    }
    return NO;
}

@end
