//
//  ERActionSheetCell.h
//  ERActionSheet
//
//  Created by Mac on 12-11-30.
//  Copyright (c) 2012年 SongLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ERActionSheetCellDelegate <NSObject>

- (void)didClickCell:(id)sender;

@end


@interface ERActionSheetCell : UIView
{
    
}

- (id)initWithDelegate:(id<ERActionSheetCellDelegate>)delegate;
- (void)setDelegate:(id<ERActionSheetCellDelegate>)delegate;
- (void)setImage:(UIImage*)image;
- (void)setTitle:(NSString *)title;

@property (strong, nonatomic) UILabel *cellNameLabel;
@property (strong, nonatomic) UIImageView *cellImageView;
@property (weak, nonatomic) id<ERActionSheetCellDelegate> delegate;

@end
