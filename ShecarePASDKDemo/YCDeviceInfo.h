//
//  YCDeviceInfo.h
//  YCUtility
//
//  Created by mac on 2018/7/3.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCDeviceInfo : NSObject

///  判断设备是否有摄像头
+ (BOOL)isCameraAvailable;
///  获取设备信息
+ (NSString *)getMachineInfo;
///  获取设备型号和系统版本号
+ (NSString*)getDevicePlatform;
///  获取设备的 “简短” 型号
+ (NSString *)getShortDevicePlatform;
///  判断是否是iPhone X 系列
+ (BOOL)isiPhoneXSeries;

@end
