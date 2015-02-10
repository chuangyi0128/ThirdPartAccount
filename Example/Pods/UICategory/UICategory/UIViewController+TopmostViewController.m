//
//  UIViewController+TopmostViewController.m
//  NeteaseLottery
//
//  Created by SongLi on 02/04/2015.
//  Copyright (c) 2014年 netease. All rights reserved.
//

#import "UIViewController+TopmostViewController.h"

@implementation UIViewController (TopmostViewController)

+ (UIViewController *)topmostViewController
{
    UIViewController *rootViewContoller = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (!rootViewContoller) {
        return nil;
    }
    
    if ([rootViewContoller isKindOfClass:[UITabBarController class]]) {
        //当前显示哪个tab页
        UINavigationController *rootNavController = (UINavigationController *) [(UITabBarController*)rootViewContoller selectedViewController];
        if (!rootNavController) {
            return nil;
        }
        
        UINavigationController *navController = rootNavController;
        while ([navController isKindOfClass:[UINavigationController class]]) {
            UIViewController *topViewController = [navController topViewController];
            if ([topViewController isKindOfClass:[UINavigationController class]]) { //顶层是个导航控制器，继续循环
                navController = (UINavigationController *) topViewController;
            } else {
                //是否有弹出presentViewControllr;
                UIViewController *presentedViewController = topViewController.presentedViewController;
                while (presentedViewController) {
                    topViewController = presentedViewController;
                    if ([topViewController isKindOfClass:[UINavigationController class]]) {
                        break;
                    } else {
                        presentedViewController = topViewController.presentedViewController;
                    }
                }
                navController = (UINavigationController *) topViewController;
            }
        }
        return navController;
    }
    else if ([rootViewContoller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)rootViewContoller;
        while ([navController isKindOfClass:[UINavigationController class]]) {
            UIViewController *topViewController = [navController topViewController];
            if ([topViewController isKindOfClass:[UINavigationController class]]) { //顶层是个导航控制器，继续循环
                navController = (UINavigationController *) topViewController;
            } else {
                //是否有弹出presentViewControllr;
                UIViewController *presentedViewController = topViewController.presentedViewController;
                while (presentedViewController) {
                    topViewController = presentedViewController;
                    if ([topViewController isKindOfClass:[UINavigationController class]]) {
                        break;
                    } else {
                        presentedViewController = topViewController.presentedViewController;
                    }
                }
                navController = (UINavigationController *) topViewController;
            }
        }
        return navController;
    }
    else {
        //是否有弹出presentViewControllr;
        UIViewController *presentedViewController = rootViewContoller.presentedViewController;
        while (presentedViewController) {
            rootViewContoller = presentedViewController;
            if ([rootViewContoller isKindOfClass:[UINavigationController class]]) {
                break;
            } else {
                presentedViewController = rootViewContoller.presentedViewController;
            }
        }
        return rootViewContoller;
    }
}

@end
