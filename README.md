# ShecarePASDKDemo-iOS

## Demo
<http://fir.ikangtai.cn/wmfg>

English | [中文文档](README_zh.md)

## Access Guide

### Demo run Notes

After executing `git clone`, you need to download the following two files separately

OpenCV 3.4.5: <https://yuncheng.coding.net/s/cffb8c5b-3f57-4f71-9343-41ac8633310f>

TensorFlow: <https://yuncheng.coding.net/s/6f6adfe7-3045-49b0-a9c4-4d6b48cab0d9>

And unzip it to `Project Path/FrameworkAndLib`.

### Integration considerations
1. The minimum compatible version is iOS 9.0;
2. Need to introduce AVFoundation, CoreMedia, Accelerate, libc++.tbd and other system libraries;
3. Need to introduce libraries such as SCPaperAnalysiserSDK.framework, nsync.a, libtensorflow-core.a, libprotobuf.a, libturbojpeg.a, opencv2.framework, etc.;
4. In Other Linker Flags, libtensorflow-core.a needs to add Linker Flag "-force_load";
5. SCPaperAnalysiserSDK does not support Bitcode at the moment.


### Class definition
#### Core service class: SCPaperAnalysiser

```Objective-C
/** Proxy object, need to implement SCPaperAnalysiserDelegate protocol */
@property (nonatomic, weak) id<SCPaperAnalysiserDelegate> analysiserDelegate;

/** Singleton */
+(instancetype)shared;

/*! @brief Start scanning the video stream
* @param videoDataOutput The video output stream object used for scanning
* @param device current video device
*/
-(void)setVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput device:(AVCaptureDevice *)device session:(AVCaptureSession *)session;

/*! @brief End the scanning and analysis process
*/
-(void)closeSession:(SCPaperAnalysiserResult * _Nullable)result;

/*! @brief Get the scan and analysis results of a picture
* @param image Test strip photo for scanning
* @param completion completion callback, used to return the results of scanning and analysis
*/
-(void)getScanResultFromImage:(UIImage *)image completion:(void (^)(SCPaperAnalysiserResult *result))completion;
```

#### Constant definition: SCDefine

```Objective-C
/// error code
typedef NS_ENUM(NSInteger, SCErrorCode) {
    /// unknown error
    SCErrorCodeUnknownError = -1,
    /// The processing is normal, you can cut out the picture;
    SCErrorCodeNoError = 0,
    /// No test paper;
    SCErrorCodeNoPaper = 1,
    /// The distance is too far;
    SCErrorCodeTooFar = 2,
    /// The background is dirty;
    SCErrorCodeTooDirty = 3,
    /// The distance is too close;
    SCErrorCodeTooClose = 4,
    /// Incomplete;
    SCErrorCodeNotCompleted = 5,
    /// Neural network processing errors, NSLog records;
    SCErrorCodeHedNetError = 6,
    /// Two test papers;
    SCErrorCodeTooManyPapers = 7,
    /// Underexposure;
    SCErrorCodeUnderExposure = 8,
    /// Overexposure;
    SCErrorCodeExposed = 9,
    /// The test paper is partially overexposed;
    SCErrorCodePartlyExposed = 10,
    /// The picture is blurred;
    SCErrorCodeBlurred = 11,
    /// Underexposed
    SCErrorCodeUnderExposure2 = 12,
    /// User canceled (the scan result was not confirmed). The analysis results should not be saved at this time.
    SCErrorCodeUserCanceled = 13,
    /// The reference line is not detected, please make sure that the reference line is displayed on the test paper
    SCErrorCodeNoCLine = 14,
    /// Test paper analysis error
    SCErrorCodeGetValueError = 15,
    /// SDK verification failed or invalid
    SCErrorCodeSDKError = 16,
    /// Video stream scan timeout
    SCErrorCodeVideoOutofDate = 17,
};

/// Test paper brand
typedef NS_ENUM(NSInteger, SCPaperType) {
    /// None
    SCPaperTypeNone,
    /// David
    SCPaperTypeDaWei,
    /// Kim Sooah
    SCPaperTypeJinXiuEr,
    /// Other
    SCPaperTypeOther,
    /// David semi-quantitative
    SCPaperTypeDaWeiSemi,
    /// Jin Xiuer semi-quantitative
    SCPaperTypeJinXiuErSemi,
    /// Xiu'er
    SCPaperTypeXiuer,
    /// Pregnant orange
    SCPaperTypeShecare,
};

/// Application scenarios of the current SDK
typedef NS_ENUM(NSInteger, SCImageType) {
    /// unknown
    SCImageTypeUnknown = 0,
    /// select from album
    SCImageTypeAlbum,
    /// Video stream scanning
    SCImageTypeCamera,
};

/// The server environment used by the SDK
typedef NS_ENUM(NSInteger, YCSEnvironment) {
    /// Official server
    YCSEnvironmentRelease,
    /// Test server
    YCSEnvironmentDebug
};

/// Enumeration of debug levels
typedef NS_ENUM(NSInteger, SCDebugLevel) {
    /// Cancel debug
    SCDebugLevelDisable = 0,
    /// Used for debugging and outputting error information (used when publishing to users)
    SCDebugLevelLow,
    /// Debug and output general information, including error information (used for general real machine debugging)
    SCDebugLevelNormal,
    /// Display the least common debugging information (used in full debugging)
    SCDebugLevelHigh
};
```

#### SDK configuration class: SCPaperAnalysiserConfiguration
```Objective-C
/** Set up the SDK environment. The default is the test environment YCSEnvironmentDebug */
@property (assign, nonatomic) YCSEnvironment environment;
/** AppID related to application authorization */
@property (nonatomic, copy) NSString *appID;
/** AppSecret related to application authorization */
@property (nonatomic, copy) NSString *appSecret;
/** Fixed value, no need to set */
@property (nonatomic, copy) NSString *sessionId;
/** User ID, globally unique and fixed for the same user */
@property (nonatomic, copy) NSString *userID;

/** UI main color */
@property (nonatomic, strong) UIColor *mainColor;
/** Font main color */
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIImage *cancelImg;
@property (nonatomic, strong) UIImage *confirmImg;
@property (nonatomic, strong) UIImage *tImage;
@property (nonatomic, strong) UIImage *cImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *flipTitle;
@property (nonatomic, copy) NSString *comment;

/** Does the image returned by the algorithm need to be "extended", default is no */
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
/** Scan timeout period. The default is 15s, and the minimum is 1s */
@property (nonatomic, assign) CFTimeInterval timeIntervalOfScan;
/** The minimum number of "continuous success", the default is 5 times. In order to ensure the accuracy of the scanning results, it is recommended to adopt the judgment method of "the whole process is considered successful only when the scanning is successful multiple times in succession". */
@property (nonatomic, assign) NSUInteger numberOfSuccess;
/** The number of consecutive occurrences of the same error code. The default is 3 times. The algorithm may return many error codes in a short time. To ensure user experience, it is recommended to set this value. Used to control "the same error code appears several times in a row before prompting the user on the UI" */
@property (nonatomic, assign) NSUInteger numberOfErrors;
/** Whether to "extend" */
@property (nonatomic, assign) BOOL extended;
/** "Extended" pixels (only valid in "Extended" mode) */
@property (nonatomic, assign) NSInteger pixelOfExtended;
/** 0 unknown; 1 photo album; 2 photos */
@property (nonatomic, assign) SCImageType source;
```

#### SDK return result class: SCPaperAnalysiserResult
```Objective-C
/** Picture returned by scanning algorithm */
@property (nonatomic, strong, nullable) UIImage *transferedImage;
/** The smallest enclosing rectangle image returned by the scanning algorithm */
@property (nonatomic, strong, nullable) UIImage *presentedImage;
/** "Flip" result map */
@property (nonatomic, strong, nullable) UIImage *reverseImage;
/** The result of the cutout returned according to "Whether to expand" */
@property (nonatomic, strong, readonly) UIImage *anaImage;
/** The final cutout result returned */
@property (nonatomic, strong, readonly) UIImage *finalImage;

/** The coordinates of the quadrilateral returned by the algorithm */
@property (nonatomic, strong, nullable) NSArray <NSValue *>*maskPoints;
/** Error code returned by the algorithm */
@property (nonatomic, assign) SCErrorCode errorCode;


/** The position of the C line returned by the algorithm */
@property (nonatomic, assign) CGFloat cPosition;
/** T line position returned by the algorithm */
@property (nonatomic, assign) CGFloat tPosition;
/** C line position confirmed by the user */
@property (nonatomic, assign) CGFloat newCPosition;
/** T line position confirmed by the user */
@property (nonatomic, assign) CGFloat newTPosition;
/** Whether to flip */
@property (nonatomic, assign, getter=isFlipped) BOOL flipped;
/** The test paper analysis result returned by the algorithm */
@property (nonatomic, assign) NSInteger lhResult;
/** Test paper result confirmed by user */
@property (nonatomic, assign) NSInteger newLHResult;
/** Ratio value returned by the algorithm */
@property (nonatomic, assign) CGFloat lhRatio;
/** The type of test paper returned by the algorithm */
@property (nonatomic, assign) SCPaperType paperType;
/** Test paper test time */
@property (nonatomic, strong) NSDate *lhTime;
/** Source of test paper pictures: 1 photo album; 2 photos */
@property (nonatomic, assign) SCImageType source;
```

## Privacy Agreement

Third-party SDK: Pregnant Orange Test Strip SDK

1. Purpose/purpose of collecting personal information: optimizing and improving test strip algorithm
2. The type of personal information collected: device model, operating system, mobile phone developer identifier, network data
3. Required permissions: network permissions, camera permissions
4. Third-party SDK privacy policy link: https://static.shecarefertility.com/shecare/resource/dist/#/papersdk_privacy_policy
5. Provider: Beijing Aikangtai Technology Co., Ltd.
