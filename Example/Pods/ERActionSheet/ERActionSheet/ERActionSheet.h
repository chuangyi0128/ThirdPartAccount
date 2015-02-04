//
//  ERActionSheet.h
//  ERActionSheet
//
//  Created by Mac on 12-11-30.
//  Copyright (c) 2012年 SongLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ERActionSheet;
@protocol ERActionSheetDelegate <NSObject>

@optional
- (void)ERActionSheet:(ERActionSheet*)sheet clickedButtonAtIndex:(NSInteger)index withInfo:(NSDictionary *)info;
- (void)ERActionSheetCancel;

@end

@interface ERActionSheet : UIView
{
    
}

- (id)initWithDelegate:(id<ERActionSheetDelegate>)delegate;
- (void)addButtonWithTitle:(NSString*)title image:(UIImage*)image info:(NSDictionary *)info;
- (void)showInView:(UIView*)view;

@property (strong, nonatomic) UIPageControl *pageController;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *buttonCancel;
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (weak, nonatomic) id<ERActionSheetDelegate> delegate;

- (void)handleCancel:(id)sender;

@end
