//
//  SCPaperAnalysiserResult.h
//  SCPaperAnalysiserSDK_iOS
//
//  Created by mac on 2019/10/30.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCPaperAnalysiserResult : NSObject

/** 最终返回的抠图结果 */
@property (nonatomic, strong, readonly) UIImage *finalImage;

/** 算法返回的 四边形 坐标点 */
@property (nonatomic, strong, nullable) NSArray <NSValue *>*maskPoints;
/** 算法返回的 错误码 */
@property (nonatomic, strong) NSError *error;
/** 算法返回的 模糊度 */
@property (nonatomic, assign) CGFloat blurExtent;

/** 算法返回的 C 线位置 */
@property (nonatomic, assign) CGFloat cPosition;
/** 算法返回的 T 线位置 */
@property (nonatomic, assign) CGFloat tPosition;
/** 算法返回的 T 线区域左边缘位置 */
@property (nonatomic, assign) CGFloat lhTlineLeft;
/** 算法返回的 T 线区域右边缘位置 */
@property (nonatomic, assign) CGFloat lhTlineRight;
/** 算法返回的 C 线区域左边缘位置 */
@property (nonatomic, assign) CGFloat lhClineLeft;
/** 算法返回的 C 线区域右边缘位置 */
@property (nonatomic, assign) CGFloat lhClineRight;

/** 用户确认的 C 线位置 */
@property (nonatomic, assign) CGFloat newCPosition;
/** 用户确认的 T 线位置 */
@property (nonatomic, assign) CGFloat newTPosition;
/** T/C 线位置是否被用户修改了 */
@property (nonatomic, assign, readonly) BOOL tcLocationChanged;
/** 是否翻转 */
@property (nonatomic, assign) BOOL flipped;
/** 算法返回的试纸分析结果，初始值 -1 表示算法还没有返回结果 */
@property (nonatomic, assign) NSInteger lhResult;
/** 用户确认的试纸结果，初始值 -1 表示用户没有修改结果。注意：只有当用户修改了试纸结果时，才设置这个值。 */
@property (nonatomic, assign) NSInteger newLHResult;
/** 算法返回的 Ratio 值 */
@property (nonatomic, assign) CGFloat lhRatio;
/** 算法返回的试纸类型 */
@property (nonatomic, assign) SCPaperBrand paperBrand;
/** 算法返回的 孕橙试纸 条码值 */
@property (nonatomic, copy) NSString *barcode;
/** 试纸测试时间 */
@property (nonatomic, strong) NSDate *lhTime;
/** 试纸图片来源：1 相册；2 拍照 */
@property (nonatomic, assign) SCImageSource source;
/** 扫描时长 */
@property (nonatomic, assign) NSTimeInterval scanTime;

@property (nonatomic, assign) BOOL alreadyGetAnalyseResult;

@end

NS_ASSUME_NONNULL_END
