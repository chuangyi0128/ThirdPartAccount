//
//  UIColor+Hex.m
//  Pods
//
//  Created by SongLi on 2/28/15.
//
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (instancetype)colorWithHex:(NSInteger)hexValue
{
    return [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0f
                           green:((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0f
                            blue:((CGFloat)(hexValue & 0xFF)) / 255.0f
                           alpha:1.0f];
}

+ (instancetype)colorWithAlphaHex:(NSInteger)hexValue
{
    return [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF000000) >> 24)) / 255.0f
                           green:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0f
                            blue:((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0f
                           alpha:((CGFloat)(hexValue & 0xFF)) / 255.0f];
}

@end
