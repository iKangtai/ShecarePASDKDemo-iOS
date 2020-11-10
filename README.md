# SCPaperAnalysiserSDKDemo_iOS

### Demo 运行注意事项
1. 需要把 opencv2.framework 放在 FrameworkAndLib 文件夹下； 

#### 集成注意事项
1. 最低兼容版本 iOS 9.0；
2. 需要引入 AVFoundation、CoreMedia、Accelerate、libc++.tbd 等系统库；
3. 需要引入 SCPaperAnalysiserSDK.framework、nsync.a、libtensorflow-core.a、libprotobuf.a、libturbojpeg.a、opencv2.framework 等库；
4. Other Linker Flags 里， libtensorflow-core.a 需要加 Linker Flag “-force_load”（debug 和 release 都需要）；
5. SCPaperAnalysiserSDK 暂不支持 Bitcode，需要把工程的 Bitcode 关掉。

### Demo 地址
[https://e.coding.net/yuncheng/SCPaperAnalysiserSDKDemo-iOS.git](https://e.coding.net/yuncheng/SCPaperAnalysiserSDKDemo-iOS.git)

#### Demo 注意事项
项目使用的部分文件过大，被设置了 gitignore。所以在执行 `git clone` 之后，需要手动下载这部分文件，下载地址

OpenCV 3.2.0（推荐）: <https://yuncheng.coding.net/s/dbbc8796-1ac0-44b2-b899-e9329490fdda>

OpenCV 3.4.5: <https://yuncheng.coding.net/s/cffb8c5b-3f57-4f71-9343-41ac8633310f>

TensorFlow: <https://yuncheng.coding.net/s/6f6adfe7-3045-49b0-a9c4-4d6b48cab0d9>

把这两个压缩包下载后，解压缩到 `项目路径/FrameworkAndLib`  里即可。

### 类定义
#### 核心服务类：SCPaperAnalysiser

```Objective-C
/** 代理对象，需要实现 SCPaperAnalysiserDelegate 协议 */
@property (nonatomic, weak) id<SCPaperAnalysiserDelegate> analysiserDelegate;

/** 单例 */
+(instancetype)shared;

/*! @brief 开始扫描视频流
* @param videoDataOutput 用于扫描的视频输出流对象
* @param device 当前视频设备
*/
-(void)setVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput device:(AVCaptureDevice *)device session:(AVCaptureSession *)session;

/*! @brief 结束扫描和分析流程
*/
-(void)closeSession:(SCPaperAnalysiserResult * _Nullable)result;

/*! @brief 获取一张图片的扫描和分析结果
* @param image 用于扫描的试纸照片
* @param completion 完成回调，用于返回扫描和分析的结果
*/
-(void)getScanResultFromImage:(UIImage *)image completion:(void (^)(SCPaperAnalysiserResult *result))completion;
```

#### 常量定义：SCDefine

```Objective-C
/// 错误码
typedef NS_ENUM(NSInteger, SCErrorCode) {
    /// 未知错误
    SCErrorCodeUnknownError = -1,
    /// 处理正常，可以抠图处理；
    SCErrorCodeNoError = 0,
    /// 没有试纸；
    SCErrorCodeNoPaper = 1,
    /// 距离过远；
    SCErrorCodeTooFar = 2,
    /// 背景过脏；
    SCErrorCodeTooDirty = 3,
    /// 距离过近；
    SCErrorCodeTooClose = 4,
    /// 有残缺；
    SCErrorCodeNotCompleted = 5,
    /// 神经网络处理错误，NSLog 记录；
    SCErrorCodeHedNetError = 6,
    /// 两张试纸；
    SCErrorCodeTooManyPapers = 7,
    /// 曝光不足；
    SCErrorCodeUnderExposure = 8,
    /// 曝光过度；
    SCErrorCodeExposed = 9,
    /// 试纸局部过度曝光；
    SCErrorCodePartlyExposed = 10,
    /// 画面模糊；
    SCErrorCodeBlurred = 11,
    /// 曝光不足
    SCErrorCodeUnderExposure2 = 12,
    /// 用户取消（没有确认扫描结果）。此时不应该保存分析结果。
    SCErrorCodeUserCanceled = 13,
    /// 未检测到参考线，请确认试纸有参考线显示
    SCErrorCodeNoCLine = 14,
    /// 试纸分析出错
    SCErrorCodeGetValueError = 15,
    /// SDK 校验失败或无效
    SCErrorCodeSDKError = 16,
    /// 视频流扫描超时
    SCErrorCodeVideoOutofDate = 17,
};

///  试纸品牌
typedef NS_ENUM(NSInteger, SCPaperType) {
    ///  无
    SCPaperTypeNone,
    ///  大卫
    SCPaperTypeDaWei,
    ///  金秀儿
    SCPaperTypeJinXiuEr,
    ///  其它
    SCPaperTypeOther,
    ///  大卫半定量
    SCPaperTypeDaWeiSemi,
    ///  金秀儿半定量
    SCPaperTypeJinXiuErSemi,
    ///  秀儿
    SCPaperTypeXiuer,
    ///  孕橙
    SCPaperTypeShecare,
};

/// 当前 SDK 的应用场景
typedef NS_ENUM(NSInteger, SCImageType) {
    /// 未知
    SCImageTypeUnknown = 0,
    /// 从相册选择
    SCImageTypeAlbum,
    /// 视频流扫描
    SCImageTypeCamera,
};

///  SDK 使用的服务器环境
typedef NS_ENUM(NSInteger, YCSEnvironment) {
    ///  正式服务器
    YCSEnvironmentRelease,
    ///  测试服务器
    YCSEnvironmentDebug
};

///  debug 等级的枚举
typedef NS_ENUM(NSInteger, SCDebugLevel) {
    ///  取消掉debug
    SCDebugLevelDisable  = 0,
    ///  用来调试输出错误信息（发布给用户时使用）
    SCDebugLevelLow,
    ///  调试输出普通的信息，包含错误信息（普通真机调试使用）
    SCDebugLevelNormal,
    ///  显示最不常见的调试信息（完全调试时使用）
    SCDebugLevelHigh
};
```

#### SDK 配置类：SCPaperAnalysiserConfiguration
```Objective-C
/** 设置 SDK 环境。默认是测试环境 YCSEnvironmentDebug */
@property (assign, nonatomic) YCSEnvironment environment;
/** 应用授权相关的 appID */
@property (nonatomic, copy) NSString *appID;
/** 应用授权相关的 appSecret */
@property (nonatomic, copy) NSString *appSecret;
/** 固定值，不需要设置 */
@property (nonatomic, copy) NSString *sessionId;
/** 用户身份标识符，全局唯一且同一个用户固定不变 */
@property (nonatomic, copy) NSString *userID;

/** UI 主色调 */
@property (nonatomic, strong) UIColor *mainColor;
/** 字体 主色调 */
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIImage *cancelImg;
@property (nonatomic, strong) UIImage *confirmImg;
@property (nonatomic, strong) UIImage *tImage;
@property (nonatomic, strong) UIImage *cImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *flipTitle;
@property (nonatomic, copy) NSString *comment;

/** 算法返回的图片是否需要 “外扩”，默认否 */
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
/** 扫描超时时长。默认为 15s，最少为 1s */
@property (nonatomic, assign) CFTimeInterval timeIntervalOfScan;
/** “连续成功” 的最少次数，默认为 5 次。为保证扫描结果准确性，建议采用 “连续多次扫描成功才认为整个流程成功” 的判定方法。 */
@property (nonatomic, assign) NSUInteger numberOfSuccess;
/** 相同错误码连续出现的次数，默认为 3 次。算法可能在短时间内返回很多错误码，为保证用户体验，建议设置此值。用于控制 “相同错误码连续出现若干次，才在 UI 上提示用户”  */
@property (nonatomic, assign) NSUInteger numberOfErrors;
/** 是否 “外扩” */
@property (nonatomic, assign) BOOL extended;
/** “外扩” 的像素（仅在 “外扩” 模式下有效） */
@property (nonatomic, assign) NSInteger pixelOfExtended;
/** 0未知；1 相册；2 拍照 */
@property (nonatomic, assign) SCImageType source;
```

#### SDK 返回结果类：SCPaperAnalysiserResult
```Objective-C
/** 扫描算法返回的 图片 */
@property (nonatomic, strong, nullable) UIImage *transferedImage;
/** 扫描算法返回的经过 “外扩” 的最小外接矩形图片 */
@property (nonatomic, strong, nullable) UIImage *presentedImage;
/** “翻转” 的结果图 */
@property (nonatomic, strong, nullable) UIImage *reverseImage;
/** 根据 “是否外扩” 返回的抠图结果 */
@property (nonatomic, strong, readonly) UIImage *anaImage;
/** 最终返回的抠图结果 */
@property (nonatomic, strong, readonly) UIImage *finalImage;

/** 算法返回的 四边形 坐标点 */
@property (nonatomic, strong, nullable) NSArray <NSValue *>*maskPoints;
/** 算法返回的 错误码 */
@property (nonatomic, assign) SCErrorCode errorCode;


/** 算法返回的 C 线位置 */
@property (nonatomic, assign) CGFloat cPosition;
/** 算法返回的 T 线位置 */
@property (nonatomic, assign) CGFloat tPosition;
/** 用户确认的 C 线位置 */
@property (nonatomic, assign) CGFloat newCPosition;
/** 用户确认的 T 线位置 */
@property (nonatomic, assign) CGFloat newTPosition;
/** 是否翻转 */
@property (nonatomic, assign, getter=isFlipped) BOOL flipped;
/** 算法返回的试纸分析结果 */
@property (nonatomic, assign) NSInteger lhResult;
/** 用户确认的试纸结果 */
@property (nonatomic, assign) NSInteger newLHResult;
/** 算法返回的 Ratio 值 */
@property (nonatomic, assign) CGFloat lhRatio;
/** 算法返回的试纸类型 */
@property (nonatomic, assign) SCPaperType paperType;
/** 试纸测试时间 */
@property (nonatomic, strong) NSDate *lhTime;
/** 试纸图片来源：1 相册；2 拍照 */
@property (nonatomic, assign) SCImageType source;
```