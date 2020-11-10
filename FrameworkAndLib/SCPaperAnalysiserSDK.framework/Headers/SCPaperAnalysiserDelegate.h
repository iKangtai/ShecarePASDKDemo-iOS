//
//  SCPaperAnalysiserDelegate.h
//  SCPaperAnalysiserSDK_iOS
//
//  Created by mac on 2019/10/30.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class SCPaperAnalysiser;
@class SCPaperAnalysiserResult;
@protocol SCPaperAnalysiserDelegate<NSObject>

@required

@optional

/*! @brief 视频流扫描 “中间结果” 的回调
* @param analysiser 用于获取此数据的对象
* @param result 扫描的结果，包括错误信息 Error
* @param bkImage 当前视频背景
*/
-(void)analysiser:(SCPaperAnalysiser *)analysiser didGetVideoResult:(SCPaperAnalysiserResult *)result bkImage:(UIImage *)bkImage;

/*! @brief 视频流扫描 “最终结果” 的回调
* @param analysiser 用于获取此数据的对象
* @param result 扫描的结果
*/
-(void)analysiser:(SCPaperAnalysiser *)analysiser didFinishVideoScan:(SCPaperAnalysiserResult *)result;

@end

NS_ASSUME_NONNULL_END
