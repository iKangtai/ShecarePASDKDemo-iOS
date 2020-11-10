//
//  SCPaperAnalysiser.h
//  SCPaperAnalysiserSDK_iOS
//
//  Created by mac on 2019/10/30.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefine.h"
#import "SCPaperAnalysiserDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class AVCaptureVideoDataOutput;
@class AVCaptureDevice;
@class AVCaptureSession;
@class SCPaperAnalysiserResult;
@interface SCPaperAnalysiser : NSObject

/** 代理对象，需要实现 SCPaperAnalysiserDelegate 协议 */
@property (nonatomic, weak) id<SCPaperAnalysiserDelegate> analysiserDelegate;

/** 单例 */
+(instancetype)shared;

/*! @brief Set Logger Level
* @param level YCLoggerLevel 日志等级
*/
-(void)setLoggerLevel:(YCLoggerLevel)level;

/*! @brief 开始扫描视频流
* @param videoDataOutput 用于扫描的视频输出流对象
* @param device 当前的 AVCaptureDevice
* @param session 当前的 AVCaptureSession
*/
-(void)setVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput device:(AVCaptureDevice *)device session:(AVCaptureSession *)session;

/*! @brief 结束扫描和分析流程
* @param result 当前分析流程使用的 SCPaperAnalysiserResult 对象
*/
-(void)closeSession:(SCPaperAnalysiserResult * _Nullable)result;

/*! @brief 获取一张图片的扫描和分析结果
* @param image 用于扫描的试纸照片
* @param completion 完成回调，用于返回扫描和分析的结果
*/
-(void)getScanResultFromImage:(UIImage *)image completion:(void (^)(SCPaperAnalysiserResult *result))completion;

/*! @brief 获取一张图片的手动裁剪和分析结果
* @param snapShot 用于手动裁剪的试纸 “屏幕截图”
* @param points “裁剪框” 的左上角和右下角顶点坐标
* @param completion 完成回调，用于返回手动裁剪和分析的结果
*/
-(void)getScanResultFromSnapShot:(UIImage *)snapShot points:(NSArray <NSValue *>*)points completion:(void (^)(SCPaperAnalysiserResult *result))completion;

/*! @brief 获取一张图片的 Logo 识别结果
* @param image 用于扫描的试纸照片
* @param completion 完成回调，用于返回识别结果
*/
-(void)getPaperBrandFromImage:(UIImage *)image completion:(void (^)(SCPaperBrand paperBrand, NSError * _Nullable error))completion;

/*! @brief 获取一个月经周期内所有试纸的分析结果，包括 “排卵日、同房建议” 等内容
* @param papers 给算法传递的本周期内所有试纸，形式为 [{"value":5,"timestamp":时间戳}] 的数组
* @param language 语言。用于国际化处理，目前仅支持 zh-CN 和 en-US
* @param completion 完成回调，用于返回分析结果
*/
-(void)getCycleResultWithPapers:(NSArray <NSDictionary *>*)papers language:(NSString *)language completion:(void (^)(id _Nullable responseObject, NSError * _Nullable error))completion;

/*! @brief 获取 孕橙试纸条码 相关信息，比如 “批次提醒信息” 等
* @param params 接口所需参数，包括两个字段 lhPaperId 和 barcode
* @param completion 完成回调，用于返回数据
*/
///
-(void)getBarcodeInfoWithParams:(NSDictionary *)params completion:(void (^ _Nonnull)(id  _Nullable responseObject, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
