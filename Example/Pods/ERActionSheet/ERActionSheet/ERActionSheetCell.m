//
//  ERActionSheetCell.m
//  ERActionSheet
//
//  Created by Mac on 12-11-30.
//  Copyright (c) 2012年 SongLi. All rights reserved.
//

#import "ERActionSheetCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ERActionSheetCell ()

@end

@implementation ERActionSheetCell

- (id)initWithDelegate:(id<ERActionSheetCellDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 70, 80)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        CALayer *layer = [self.cellImageView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:8.0f];
        
        self.cellNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.5, 55, 65, 20)];
        [self.cellNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.cellNameLabel setBackgroundColor:[UIColor clearColor]];
        [self.cellNameLabel setTextColor:[UIColor whiteColor]];
        [self.cellNameLabel setFont:[UIFont systemFontOfSize:12]];
        [self.cellNameLabel setAdjustsFontSizeToFitWidth:NO];
        [self addSubview:self.cellNameLabel];
        [self addSubview:self.cellImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)handleTap:(UIGestureRecognizer*)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCell:)]) {
        [self.delegate didClickCell:self];
    }
}

- (void)setImage:(UIImage*)image
{
    [self.cellImageView setImage:image];
}

- (void)setTitle:(NSString *)title
{
    [self.cellNameLabel setText:title];
}

@end
