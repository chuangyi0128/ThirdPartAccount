//
//  UIColor+Hex.h
//  Pods
//
//  Created by SongLi on 2/28/15.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

/**
 *  RGB，如0x887766
 */
+ (instancetype)colorWithHex:(NSInteger)hexValue;

/**
 *  RGBA，如0x887766ff
 */
+ (instancetype)colorWithAlphaHex:(NSInteger)hexValue;

@end
