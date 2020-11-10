//
//  YCImageExtension.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(YCImageExtension)

///  让 image 旋转 degrees（角度）
- (UIImage *)imageRotatedOnDegrees:(CGFloat)degrees;
///  图片保存之前，修复方向信息
- (UIImage *)fixOrientation;
///  方法二：图片保存之前，修复方向信息
- (UIImage *)normalizedImage;
///  把图片 压缩或放大 到特定尺寸
- (UIImage *)compress:(CGSize)toSize;
///  把 矩形 图片剪切为 正方形
- (UIImage *)squareImage;
///  把 矩形 图片剪切为 上、中、下 三个区域的正方形
- (NSArray<UIImage *> *)squareImages;
///  给 Image 添加 EdgeInsets
- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color;

@end
