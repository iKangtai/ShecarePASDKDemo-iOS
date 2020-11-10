//
//  SCDefine.h
//  SCPaperAnalysiserSDK_iOS
//
//  Created by mac on 2019/10/30.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SCDefine_h
#define SCDefine_h

/// 试纸抠图、分析错误码
typedef NS_ENUM(NSInteger, SCErrorCode) {
    
    /// 抠图成功、分析成功，流程内没有错误产生；
    SCErrorCodeNoError = 0,
    
    /// SDK 校验失败或无效
    SCErrorCodeSDKError = -2,
    /// 未知错误（默认值）；
    SCErrorCodeUnknownError = -1,
    
    /* 阶段 1 中间过程错误码（或单张照片扫描结果的错误码） */
    /// 没有找到试纸；
    SCErrorCodeNoPaper = 1,
    /// 距离过远；
    SCErrorCodeTooFar = 2,
    /// 背景过脏；
    SCErrorCodeTooDirty = 3,
    /// 距离过近；
    SCErrorCodeTooClose = 4,
    /// 试纸不全；
    SCErrorCodeNotCompleted = 5,
    /// 神经网络加载错误；
    SCErrorCodeHedNetError = 6,
    /// 背景内不止一张试纸；
    SCErrorCodeTooManyPapers = 7,
    /// 曝光不足；
    SCErrorCodeUnderExposure = 8,
    /// 曝光过度；
    SCErrorCodeExposed = 9,
    /// 试纸局部曝光过度；
    SCErrorCodePartlyExposed = 10,
    /// 画面模糊；
    SCErrorCodeBlurred = 11,
    /// 曝光不足（OpenCV 二次确认）；
    SCErrorCodeUnderExposure2 = 12,
    
    /* 阶段 1 结束错误码 */
    /// 抠图失败，视频流扫描超时
    SCErrorCodeVideoOutofDate = 17,
    /// 手动裁剪失败，请检查传入的图片和坐标点
    SCErrorCodeManualClipError = 50,
    
    /* 阶段 2 错误码 */
    /// 抠图成功，但是分析失败
    SCErrorCodeGetValueError = 101,
    
    /* 阶段 3 错误码 */
    /// 抠图成功，分析成功，但是用户取消确认抠图和分析结果
    SCErrorCodeUserCanceled = 201,
    /// 抠图成功，分析成功，但未检测到 C 线，请确认试纸有 C 线显示
    SCErrorCodeNoCLine = 202,
    /// 抠图成功，分析成功，但未检测到 T 线，请确认试纸有 T 线显示
    SCErrorCodeNoTLine = 203,
    
    /* SaaS 接口返回的错误码 */
    /// 请求参数不合法
    SCErrorCodeInvalidParam = 301,
    /// 分析结果转化为 JSON 时出错
    SCErrorCodeResultToJSONFailed = 302,
    /// 分析失败，服务返回
    SCErrorCodeAnalysisFailedForServer = 303,
    /// 图片 Base64 编解码失败
    SCErrorCodeBase64Failed = 304,

    /// 认证错误
    SCErrorCodeAuthFailed = 500,
    /// 超时，认证无效
    SCErrorCodeAuthOutOfTime = 502,
    /// 请求频率过高，访问受限
    SCErrorCodeAccessDenied = 503,
    /// 认证时缺少相关参数
    SCErrorCodeInvalidParamForAuth = 510,
    /// 试纸无效
    SCErrorCodeInvalidPaper = 511,
    /// 分析失败
    SCErrorCodeAnalysisFailed = 512,
};

///  试纸品牌
typedef NS_ENUM(NSInteger, SCPaperBrand) {
    ///  无
    SCPaperBrandNone,
    ///  大卫
    SCPaperBrandDaWei,
    ///  金秀儿
    SCPaperBrandJinXiuEr,
    ///  其它
    SCPaperBrandOther,
    ///  大卫半定量
    SCPaperBrandDaWeiSemi,
    ///  金秀儿半定量
    SCPaperBrandJinXiuErSemi,
    ///  秀儿
    SCPaperBrandXiuer,
    ///  孕橙
    SCPaperBrandShecare,
    ///  Premom
    SCPaperBrandPremom,
    ///  Easy@Home
    SCPaperBrandEasyHome,
    ///  Clearblue
    SCPaperBrandClearblue,
};

/// 当前 SDK 的应用场景
typedef NS_ENUM(NSInteger, SCImageSource) {
    /// 未知
    SCImageSourceUnknown = 0,
    /// 从相册选择
    SCImageSourceAlbum,
    /// 视频流扫描
    SCImageSourceCamera,
};

/// 当前 SDK 使用的图片裁剪方式
typedef NS_ENUM(NSInteger, SCImageOperation) {
    /// 默认值
    SCImageOperationDefault = 0,
    /// 自动抠图
    SCImageOperationAuto,
    /// 手动裁剪
    SCImageOperationManual,
};

///  SDK 使用的服务器环境
typedef NS_ENUM(NSInteger, YCSEnvironment) {
    ///  正式服务器
    YCSEnvironmentRelease,
    ///  测试服务器
    YCSEnvironmentDebug
};

/// Logger Level
typedef NS_ENUM(int, YCLoggerLevel) {
    /// All
    YCLoggerLevelAll  = 0,
    /// Info
    YCLoggerLevelInfo,
    /// Error
    YCLoggerLevelError
};

#endif /* SCDefine_h */
