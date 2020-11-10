//
//  YCImageExtension.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCImage+Extension.h"

@implementation UIImage(YCImageExtension)

- (UIImage *)imageRotatedOnDegrees:(CGFloat)degrees {
    // Follow ing code can only rotate images on 90, 180, 270.. degrees.
    CGFloat roundedDegrees = (CGFloat)(round(degrees / 90.0) * 90.0);
    BOOL sameOrientationType = ((NSInteger)roundedDegrees) % 180 == 0;
    CGFloat radians = M_PI * roundedDegrees / 180.0;
    CGSize newSize = sameOrientationType ? self.size : CGSizeMake(self.size.height, self.size.width);
    // 保证不丢失清晰度
    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGImageRef cgImage = self.CGImage;
    if (ctx == NULL || cgImage == NULL) {
        UIGraphicsEndImageContext();
        return self;
    }
    
    CGContextTranslateCTM(ctx, newSize.width / 2.0, newSize.height / 2.0);
    CGContextRotateCTM(ctx, radians);
    CGContextScaleCTM(ctx, 1, -1);
    CGPoint origin = CGPointMake(-(self.size.width / 2.0), -(self.size.height / 2.0));
    CGRect rect = CGRectZero;
    rect.origin = origin;
    rect.size = self.size;
    CGContextDrawImage(ctx, rect, cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image ?: self;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

-(UIImage *)compress:(CGSize)toSize {
    UIGraphicsBeginImageContext(toSize);
    [self drawInRect:CGRectMake(0, 0, toSize.width, toSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)squareImage {
    if (self == nil) {
        return nil;
    }
    if (self.size.width == self.size.height) {
        return self;
    }
    CGFloat originalW = self.size.width;
    CGFloat originalH = self.size.height;
    CGFloat newImgY = (originalH - originalW) * 0.5;
    CGRect clipRect = CGRectMake(0, newImgY, originalW, originalW);
    if (newImgY < 0) {
        clipRect = CGRectMake(-newImgY, 0, originalH, originalH);
    }
    
    CGImageRef newImgRef = CGImageCreateWithImageInRect(self.CGImage, clipRect);
    UIImage *result = [UIImage imageWithCGImage:newImgRef];
    CGImageRelease(newImgRef);
    return result;
}

- (NSArray<UIImage *> *)squareImages {
    if (self == nil) {
        return nil;
    }
    if (self.size.width == self.size.height) {
        return @[self];
    }
    CGFloat originalW = self.size.width;
    CGFloat originalH = self.size.height;
    CGFloat newImgY1 = 0;
    CGFloat newImgY2 = (originalH - originalW) * 0.5;
    CGFloat newImgY3 = originalH - originalW;
    CGRect clipRect1 = CGRectMake(0, newImgY1, originalW, originalW);
    CGRect clipRect2 = CGRectMake(0, newImgY2, originalW, originalW);
    CGRect clipRect3 = CGRectMake(0, newImgY3, originalW, originalW);
    if (newImgY2 < 0) {
        clipRect2 = CGRectMake(-newImgY2, 0, originalH, originalH);
    }
    if (newImgY3 < 0) {
        clipRect3 = CGRectMake(-newImgY3, 0, originalH, originalH);
    }
    
    CGImageRef newImgRef1 = CGImageCreateWithImageInRect(self.CGImage, clipRect1);
    UIImage *result1 = [UIImage imageWithCGImage:newImgRef1];
    CGImageRelease(newImgRef1);
    
    CGImageRef newImgRef2 = CGImageCreateWithImageInRect(self.CGImage, clipRect2);
    UIImage *result2 = [UIImage imageWithCGImage:newImgRef2];
    CGImageRelease(newImgRef2);
    
    CGImageRef newImgRef3 = CGImageCreateWithImageInRect(self.CGImage, clipRect3);
    UIImage *result3 = [UIImage imageWithCGImage:newImgRef3];
    CGImageRelease(newImgRef3);
    return @[result1, result2, result3];
}

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color{
    CGSize size = self.size;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    CGRect rect = CGRectMake(-insets.left, -insets.top, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (color) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CGPathAddRect(path, NULL, rect);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        CGPathRelease(path);
    }
    [self drawInRect:rect];
    UIImage *insetEdgedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return insetEdgedImage;
}

@end
