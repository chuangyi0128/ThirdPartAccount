//
//  UIImage+Crop.h
//  Pods
//
//  Created by SongLi on 2/3/15.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

/**
 *  从正中心裁剪成正方形
 */
- (UIImage *)cropToSquareInCenter;

/**
 *  根据edgeInsets裁剪图片
 */
- (UIImage *)cropWithEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
