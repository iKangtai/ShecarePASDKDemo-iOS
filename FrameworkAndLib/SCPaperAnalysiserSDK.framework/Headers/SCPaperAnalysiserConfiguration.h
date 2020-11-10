//
//  SCPaperAnalysiserConfiguration.h
//  SCPaperAnalysiserSDK_iOS
//
//  Created by mac on 2019/10/30.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class YCTakeLHPhotoResultView;
@interface SCPaperAnalysiserConfiguration : NSObject

/** 设置 SDK 环境。默认是测试环境 YCSEnvironmentDebug */
@property (assign, nonatomic) YCSEnvironment environment;
/** 应用授权相关的 appID */
@property (nonatomic, copy) NSString *appID;
/** 应用授权相关的 appSecret */
@property (nonatomic, copy) NSString *appSecret;
/** 用户身份标识符，全局唯一且同一个用户固定不变 */
@property (nonatomic, copy) NSString *unionId;

/** 当前 SDK 运行环境的语言，如 “en-US、zh-Hans” 等，默认为 en-US。 YCTakeLHPhotoResultView 的 feedbackLbl 属性受语言环境影响，只在英文下显示。 */
@property (nonatomic, strong) NSString *language;

/** 结果确认页 UI 主控件 */
@property (nonatomic, strong) YCTakeLHPhotoResultView *resultView;
/** 结果确认页 UI 主色调 */
@property (nonatomic, strong) UIColor *mainColor;
/** 当服务器没有返回 T/C 边缘线位置时，本地用于设置边缘线位置的默认 T/C 线宽度。默认为 5 */
@property (nonatomic, assign) CGFloat defaultTCWidth;
/** 结果确认页 T 滑块图片 */
@property (nonatomic, strong) UIImage *tImage;
/** 结果确认页 C 滑块图片 */
@property (nonatomic, strong) UIImage *cImage;
/** 结果确认页 T/C 指示线颜色 */
@property (nonatomic, strong) UIColor *tagLineColor;

/** 算法返回的图片是否需要 “外扩”，默认否 */
@property (nonatomic, assign, getter=isExtended) BOOL extended;
/** “外扩” 的像素，正整数（仅在 extended=true 时有效） */
@property (nonatomic, assign) NSInteger pixelOfExtended;
/** 裁剪结果图片的最小高度，正整数（仅在 extended=true 时有效）。当设置了 paperMinHeight 时，算法内部会动态地根据此值计算一个 “外扩” 值出来，然后和 pixelOfExtended 对比，取较大的那个 */
@property (nonatomic, assign) NSInteger paperMinHeight;
/** Deprecated, 扫描超时时长。默认为 15s，最少为 1s（仅在视频流扫描模式下有效） */
@property (nonatomic, assign) CFTimeInterval timeIntervalOfScan __attribute__((deprecated));
/** Deprecated, “连续成功” 的最少次数，默认为 5 次。为保证扫描结果准确性，建议采用 “连续多次扫描成功才认为整个流程成功” 的判定方法。（仅在视频流扫描模式下有效） */
@property (nonatomic, assign) NSUInteger numberOfSuccess __attribute__((deprecated));
/** 相同错误码连续出现的次数，默认为 3 次。算法可能在短时间内返回很多错误码，为保证用户体验，建议设置此值。用于控制 “相同错误码连续出现若干次，才在 UI 上提示用户” （仅在视频流扫描模式下有效） */
@property (nonatomic, assign) NSUInteger numberOfErrors;
/** 0未知；1 相册；2 拍照 */
@property (nonatomic, assign) SCImageSource source;
/** 试纸裁剪方式：0 默认值；1 自动抠图；2 手动裁剪 */
@property (nonatomic, assign) SCImageOperation operation;

/** SDK 配置 */
+(instancetype)shared;

@end

NS_ASSUME_NONNULL_END
