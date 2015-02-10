//
//  TPAShareService.h
//  ThirdPartAccount
//
//  Created by SongLi on 01/31/2015.
//  Copyright (c) 2014 SongLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPADefines.h"

extern NSString * const TPANotificationShareFinished;


@class TPAShareContentItem;

/**
 *  用于配置分享内容的block
 *
 *  @return 返回nil则不分享
 */
typedef TPAShareContentItem * (^TPAShareContentBlock)(TPAShareTo shareTo);



/*********************************************************/
#pragma mark - TPAShareContentItem

@interface TPAShareContentItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *linkUrlStr;

@end



/*********************************************************/
#pragma mark - TPAShareService

@interface TPAShareService : NSObject

/**
 *  向用户展示指定的若干个分享路径，当用户选择后调用contentBlock指定
 *  分享的内容
 *
 *  @param  shareTo         提供给用户可选的分享途径，多个用"|"并列
 *  @param  view            分享选择列表显示在view中
 *  @param  contentBlock    返回一个TPAShareContentItem指定用户
 *                          选择的分享路径的分享内容，返回nil则忽略
 */
- (void)showShareList:(TPAShareTo)shareTo inView:(UIView *)view usingBlock:(TPAShareContentBlock)contentBlock;

@end
