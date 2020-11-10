//
//  UIColor+YCExtension.h
//  YCUtility
//
//  Created by mac on 2018/7/5.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

///  快捷使用RGBA颜色的宏定义方法
#define RGBA(R,G,B,A) ((UIColor*)[UIColor colorWithRed:(R/255.0) green:(G/255.0) blue:(B/255.0) alpha:(A)])

@interface UIColor(YCExtension)

/**
 *  @brief  把 hex 颜色值转换成 UIColor 的颜色
 *  @return iOS 中可用的 UIColor 对象
 */
+ (UIColor *)colorWithHex:(unsigned long)hexColor;

/**
 *  @brief  把 hex 颜色值转换成 UIColor 的颜色
 *  @return iOS 中可用的 UIColor 对象
 */
+ (UIColor *)colorWithHex:(unsigned long)hexColor alpha:(CGFloat)alpha;

@end
