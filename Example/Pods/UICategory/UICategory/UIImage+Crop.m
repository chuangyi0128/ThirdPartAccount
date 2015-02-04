//
//  UIImage+Crop.m
//  Pods
//
//  Created by SongLi on 2/3/15.
//
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)cropToSquareInCenter
{
    CGSize size = self.size;
    if (size.width > size.height) {
        CGFloat d = (size.width - size.height) / 2.0f;
        return [self cropWithEdgeInsets:UIEdgeInsetsMake(0, d, 0, d)];
    } else if (size.width < size.height) {
        CGFloat d = (size.height - size.width) / 2.0f;
        return [self cropWithEdgeInsets:UIEdgeInsetsMake(d, 0, d, 0)];
    } else {
        return self;
    }
}

- (UIImage *)cropWithEdgeInsets:(UIEdgeInsets)edgeInsets
{
    if (edgeInsets.top < 0 || edgeInsets.bottom < 0 || edgeInsets.left < 0 || edgeInsets.right < 0) {
        return self;
    }
    
    CGSize size = self.size;
    if (edgeInsets.top + edgeInsets.bottom >= size.height || edgeInsets.left + edgeInsets.right >= size.width) {
        return self;
    }
    
    CGRect rect = CGRectMake(edgeInsets.left, edgeInsets.top, size.width - edgeInsets.left - edgeInsets.right, size.height - edgeInsets.top - edgeInsets.bottom);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
