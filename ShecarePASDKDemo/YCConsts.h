//
//  YCConsts.h
//  ShecarePASDKDemo
//
//  Created by mac on 2019/11/7.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#ifndef YCConsts_h
#define YCConsts_h

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kNavBarHeight 44.0
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kTopHeight (kNavBarHeight + kStatusBarHeight)
#define kBottomHeight ([YCDeviceInfo isiPhoneXSeries] ? 34.0 : 0.0)
#define kTabBarHeight (kBottomHeight + 49)

#define YCWeakSelf(args)  __weak typeof(args) weak##args = args;
#define YCStrongSelf(args)  __strong typeof(args) args = weak##args;

#define YC_SAAS_APP_ID      @"100200"
#define YC_SAAS_APP_SECRET  @"6e1b1049a9486d49ba015af00d5a0"

#endif /* YCConsts_h */
