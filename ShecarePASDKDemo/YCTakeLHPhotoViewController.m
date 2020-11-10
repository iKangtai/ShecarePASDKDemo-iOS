//
//  YCTakeLHPhotoViewController.m
//  Shecare
//
//  Created by 罗培克 on 2019/4/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCTakeLHPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "YCTakeLHPhotoManualView.h"
#import <Photos/Photos.h>
#import "YCLHPaperManualClipViewController.h"
#import "YCLHResultViewController.h"
#import "YCImage+Extension.h"
#import "YCDeviceInfo.h"
#import "UIColor+YCExtension.h"
#import "YCViewController+Extension.h"

@interface YCTakeLHPhotoViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, SCPaperAnalysiserDelegate>

@property (strong, nonatomic) UIButton *flashButton;
/// 扫描提示信息
@property (nonatomic, strong) UILabel *topTintLbl;
/// 错误提示信息
@property (nonatomic, strong) UIButton *errorLbl;
/// 错误提示信息：着重强调
@property (nonatomic, strong) UIButton *errorLblIM;
@property (nonatomic, strong) UIImageView *borderImgV;
@property (strong, nonatomic) UIView *bottomView;
@property (nonatomic, strong) UILabel *topCommentLbl;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, strong) UIImageView *albumView;
@property (strong, nonatomic) UIButton *takePictureButton;
/// “手动裁剪”和“智能扫描” 功能切换按钮
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) YCTakeLHPhotoManualView *manualView;
@property (nonatomic, strong) CALayer *drawLayer;

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/// 是否正在扫描（用于控制页面 UI 状态）
@property (nonatomic, assign, getter=isScanning) BOOL scanning;

@property (nonatomic, assign) float currentScale;

/// 试纸区域指示
@property (nonatomic, strong) CAShapeLayer *maskLayer;
/// 当前视频流输出的图片（已裁剪为算法需要的正方形）
@property (nonatomic, strong) UIImage *curOutputImage;

@property (nonatomic, strong) SCPaperAnalysiser *paperAnalysiser;

@end

@implementation YCTakeLHPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"试纸拍照";
}

-(CFTimeInterval)defaultOutofTime {
#if DEBUG
    return 8.0;
#else
    return 15.0;
#endif
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 配置 Shecare SDK 参数
    SCPaperAnalysiserConfiguration *scConfig = SCPaperAnalysiserConfiguration.shared;
//    scConfig.numberOfSuccess = 3;
    scConfig.numberOfErrors = 3;
//    scConfig.timeIntervalOfScan = self.defaultOutofTime;
    scConfig.operation = SCImageOperationAuto;
    scConfig.source = SCImageSourceCamera;
    self.scanning = true;
    [self setupUI];
    [self setupNavigationItem];
    [self setupGesture];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupSession];
    [self setupLayers];
#if TARGET_VERSION_LITE == 0
    // 避免 “手动裁剪” 模式进入结果页后，再返回，页面 UI 仍然是手动，但已 “开始扫描” 的问题
    [self setupUIWithScanning:true];
#else
    UIButton *btn = [[UIButton alloc] init];
    btn.selected = false;
    [self handleSwitchAction:btn];
#endif
    [self startScan];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopScan];
    [self setupMaskLayer:[self nullPoints]];
    [self setTorchOff];
}

- (void)setupNavigationItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_record"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)setupGesture {
    self.currentScale = 1.0;
    UIPinchGestureRecognizer *pinchG = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self.view addGestureRecognizer:pinchG];
}

- (void)pinchAction:(UIPinchGestureRecognizer *)sender {
    float scale = sqrtf(sender.scale);
    
    self.currentScale *= scale;
    if (self.currentScale > self.device.activeFormat.videoMaxZoomFactor) {
        self.currentScale = self.device.activeFormat.videoMaxZoomFactor;
    } else if (self.currentScale < 1.0) {
        self.currentScale = 1.0;
    }
    
    NSError *error = nil;
    [self.device lockForConfiguration:&error];
    if (!error) {
        self.device.videoZoomFactor = self.currentScale;
    } else {
        NSLog(@"Adjust zoom error: %@", error);
    }
    [self.device unlockForConfiguration];
}

- (void)goBack {
    [[SCPaperAnalysiser shared] closeSession:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleFlashAction:(UIButton *)sender {
    if (self.device.torchMode != AVCaptureTorchModeOn) {
        [sender setSelected:true];
        [self setTorchOn];
    } else {
        [sender setSelected:false];
        [self setTorchOff];
    }
}

//  开启 闪光灯
- (void)setTorchOn {
    [self setTorchMode:AVCaptureTorchModeOn];
}

//  关闭 闪光灯
- (void)setTorchOff {
    [self setTorchMode:AVCaptureTorchModeOff];
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {
    if (self.device.isTorchAvailable) {
        NSError *error = nil;
        [self.device lockForConfiguration:&error];
        if (error == nil) {
            self.device.torchMode = mode;
        } else {
            NSLog(@"Set Torch Mode to %@ Error：%@", @(mode), error);
        }
        [self.device unlockForConfiguration];
    }
}

#pragma mark - Help Method

-(void)handleSwitchAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    SCPaperAnalysiserConfiguration.shared.operation = !sender.isSelected ? SCImageOperationAuto : SCImageOperationManual;
    [self setupUIWithScanning:!sender.isSelected];
    if (!sender.isSelected) {
        [self startScan];
    }
}

-(void)setupUIWithScanning:(BOOL)scanning {
#if TARGET_VERSION_LITE == 0
    self.switchBtn.selected = !scanning;
#endif
    self.manualView.alpha = scanning ? 0.0 : 1.0;
    self.takePictureButton.alpha = scanning ? 0.0 : 1.0;
    self.takePictureButton.enabled = true;
    self.topTintLbl.alpha = scanning ? 1.0 : 0.0;
    self.borderImgV.hidden = !scanning;
    if (!scanning) {
        [self setupMaskLayer:[self nullPoints]];
        self.drawLayer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6].CGColor;
        self.drawLayer.mask = self.manualMaskLayer;
    } else {
        self.drawLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.drawLayer.mask = nil;
    }
}

- (void)handleImagePicker:(UIButton *)sender {
    SCPaperAnalysiserConfiguration.shared.source = SCImageSourceAlbum;
    // 从相册选择时，置空 analysiserDelegate，避免视频扫描的代理方法和图片扫描互相影响
    self.paperAnalysiser.analysiserDelegate = nil;
    self.errorLbl.alpha = 0.0f;
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)setupUI {
    [self bottomView];
    [self borderImgV];
    [self topTintLbl];
    [self topCommentLbl];
    [self takePictureButton];
    [self manualView];
#if TARGET_VERSION_LITE == 0
    [self switchBtn];
#endif
    [self albumView];
    [self flashButton];
    [self errorLbl];
    [self errorLblIM];
    
    YCWeakSelf(self)
    [self convertToCameraWithCancelCompletion:^{
        YCStrongSelf(self)
        [self goBack];
    } confirmedCompletion:nil];
}

- (void)convertToCameraWithCancelCompletion:(void (^)(void))cancelCompletion confirmedCompletion:(void (^)(void))confirmedCompletion {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        NSLog(@"相机未授权，请到系统的“设置-隐私-相机”中授权孕橙使用您的相机");
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) {
                if (cancelCompletion != nil) {
                    cancelCompletion();
                }
            } else {
                if (confirmedCompletion != nil) {
                    confirmedCompletion();
                }
            }
        }];
    } else {
        if (confirmedCompletion != nil) {
            confirmedCompletion();
        }
    }
}

- (void)takePictureBtnClick:(UIButton *)sender {
    [self stopScan];
    [SCPaperAnalysiserConfiguration shared].operation = SCImageOperationManual;
    [[SCPaperAnalysiser shared] getScanResultFromSnapShot:self.curOutputImage points:[self defaultPoints:self.curOutputImage] completion:^(SCPaperAnalysiserResult * _Nonnull result) {
        result.source = SCImageSourceCamera;
        if (result.error.code != SCErrorCodeUserCanceled) {
            [self gotoResultViewController:result];
        }
    }];
}

- (CGRect)clippedRect:(UIImage *)image {
    CGFloat originalW = image.size.width;
    CGRect clipRect = self.clipRect;
    CGFloat scale = originalW / kScreenWidth;
    CGFloat newImgW = clipRect.size.width * scale;
    CGFloat newImgH = clipRect.size.height * scale;
    CGFloat newImgX = clipRect.origin.x * scale;
    CGFloat newImgY = clipRect.origin.y * scale;
    
    return CGRectMake(newImgX, newImgY, newImgW, newImgH);
}

- (NSArray *)defaultPoints:(UIImage *)image {
    CGRect clipRect = [self clippedRect:image];
    NSMutableArray *resultM = [NSMutableArray arrayWithCapacity:4];
    [resultM addObject:[NSValue valueWithCGPoint:CGPointMake(clipRect.origin.x, clipRect.origin.y)]];
    [resultM addObject:[NSValue valueWithCGPoint:CGPointMake(clipRect.origin.x + clipRect.size.width, clipRect.origin.y + clipRect.size.height)]];
    return resultM.copy;
}

- (void)startScan {
    [SCPaperAnalysiser shared].analysiserDelegate = self;
    // 每次 “重新开始扫描” 都需要执行此方法，重置 SDK 内部数据设置
    [[SCPaperAnalysiser shared] setVideoDataOutput:self.videoDataOutput device:self.device session:self.session];
    if (self.session.running) {
        NSLog(@"the capture session is running!");
        return;
    }
    [self.session startRunning];
}

- (void)stopScan {
    if (!self.session.running) {
        NSLog(@"the capture session is not running!");
        return;
    }
    [self.session stopRunning];
    // 如果闪光灯是打开状态，stopRunning 时闪光灯会自动关闭。会导致 flashButton 显示状态错误
    self.flashButton.selected = false;
}

//  设置预览图层
- (void)setupLayers {
    // 视频预览区为 “正方形”
    self.drawLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    [self.view.layer insertSublayer:self.drawLayer atIndex:0];
    
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    self.previewLayer.masksToBounds = true;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

///  设置 session
- (void)setupSession {
    //  1. 判断能否添加输入设备
    if (![self.session canAddInput:self.inputDevice]) {
        NSLog(@"无法添加输入设备!");
        return;
    }
    
    //  2. 判断能否添加输出数据
    if (![self.session canAddOutput:self.videoDataOutput]) {
        NSLog(@"无法添加输出设备!");
        return;
    }
    
    if (self.session.running) {
        NSLog(@"the capture session is running!");
        return;
    }
    
    //  3. 添加设备
    [self.session addInput:self.inputDevice];
    [self.session addOutput:self.videoDataOutput];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"running"] && [object isEqual:self.session]) {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.takePictureButton != nil) {
                self.takePictureButton.enabled = isRunning;
            }
        });
    } else if ([keyPath isEqualToString:@"adjustingFocus"] && [object isEqual:self.device]) {
        NSLog(@"adjustingFocus: %@", change[NSKeyValueChangeNewKey]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

- (void)dealloc {
    // Note: I needed to stop camera capture before the view went off the screen in order to prevent a crash from the camera still sending frames
    [self stopScan];
    [self setTorchOff];
    [self.session removeObserver:self forKeyPath:@"running"];
    [self.device removeObserver:self forKeyPath:@"adjustingFocus"];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

#pragma mark - SCPaperAnalysiserDelegate

/// 视频流扫描 “中间结果” 的回调
-(void)analysiser:(SCPaperAnalysiser *)analysiser didGetVideoResult:(SCPaperAnalysiserResult *)result bkImage:(UIImage *)bkImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.curOutputImage = bkImage;
        // 根据 SDK 返回的 “试纸区域” 顶点坐标，绘制 “试纸区域” 到页面 UI
        if (result.maskPoints.count == 0) {
            // 没有返回顶点坐标时，刷新页面
            [self setupMaskLayer:[self nullPoints]];
        } else {
            [self addMaskLayerWithPoints:result.maskPoints onImage:bkImage];
        }
        NSString *errInfo = [self errorMsgWith:result.error];
        if (errInfo.length > 0) {
            [self.errorLbl setTitle:errInfo forState:UIControlStateNormal];
            self.errorLbl.alpha = 1.0f;
        } else {
            self.errorLbl.alpha = 0.0f;
        }
    });
}

/// 视频流扫描 “最终结果” 的回调
-(void)analysiser:(SCPaperAnalysiser *)analysiser didFinishVideoScan:(SCPaperAnalysiserResult *)result {
    // SDK 回调，后续处理取决于业务需求，Demo 仅为示例
    // SDK 成功返回抠图和分析结果
    if (result.error.code == SCErrorCodeNoError) {
        NSLog(@"Result: %@", result);

        [self gotoResultViewController:result];
    } else if (SCErrorCodeUserCanceled == result.error.code) {
        
    } else if (SCErrorCodeNoCLine == result.error.code || SCErrorCodeNoTLine == result.error.code) {
        [self didGetIMError:[self errorMsgWith:result.error]];
    } else if (result.error.code == NSURLErrorTimedOut) {
        // 阶段二超时
        [self didGetIMError:@"请求超时"];
    } else if (SCErrorCodeVideoOutofDate == result.error.code) {
        // 扫描超时，切换到手动裁剪模式
        dispatch_async(dispatch_get_main_queue(), ^{
            SCPaperAnalysiserConfiguration.shared.operation = SCImageOperationManual;
            [self setupUIWithScanning:false];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.errorLbl.alpha = 0.0f;
            });
        });
    } else {
        // 其他错误
        [self analysiser:analysiser didGetVideoResult:result bkImage:self.curOutputImage];
        // 此 “最终错误” 持续显示 1s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startScan];
        });
    }
}

-(void)gotoResultViewController:(SCPaperAnalysiserResult *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self gotoLHResultVCWithResult:result];
    });
}

- (void)gotoLHResultVCWithResult:(SCPaperAnalysiserResult *)result {
    YCLHResultViewController *vc = [[YCLHResultViewController alloc] initWithResult:result];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

-(void)didGetIMError:(NSString *)errInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errInfo.length > 0) {
            [self.errorLblIM setTitle:errInfo forState:UIControlStateNormal];
            self.errorLblIM.alpha = 1.0f;
            [[UIViewController currentViewController].view addSubview:self.errorLblIM];
            [self.errorLblIM mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(0);
                make.bottom.mas_equalTo(-kBottomHeight - 80);
                make.width.mas_lessThanOrEqualTo(kScreenWidth - 100);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.errorLblIM.alpha = 0.0f;
            });
        }
    });
}

/// image 传入的是用于算法识别的 “正方形” 图片
-(void)addMaskLayerWithPoints:(NSArray *)points onImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *transPoints = [NSMutableArray arrayWithCapacity:points.count];
        CGFloat scale = MIN(image.size.height, image.size.width) / kScreenWidth;
        for (NSValue *pointValueI in points) {
            CGPoint pointI = [pointValueI CGPointValue];
            CGPoint uiPoint = CGPointMake(pointI.x / scale, pointI.y / scale);
            [transPoints addObject:[NSValue valueWithCGPoint:uiPoint]];
        }
//        NSLog(@"TransPoints: %@", transPoints)
        [self setupMaskLayer:transPoints];
    });
}

-(void)setupMaskLayer:(NSArray <NSValue *>*)points {
    UIBezierPath *path = [self pathWithRectPoints:points];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (path != nil) {
            self.maskLayer.path = path.CGPath;
            if (self.maskLayer.superlayer == nil) {
                [self.drawLayer addSublayer:self.maskLayer];
            }
        } else {
            for (CALayer *layerI in self.drawLayer.sublayers) {
                [layerI removeFromSuperlayer];
            }
        }
    });
}

-(NSArray <NSValue *>*)nullPoints {
    return @[[NSValue valueWithCGPoint:CGPointZero]];
}

-(UIBezierPath *)pathWithRectPoints:(NSArray <NSValue *>*)transPoints {
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *firstPV = transPoints[0];
    CGPoint firstPoint = [firstPV CGPointValue];
    
    if (transPoints.count == 1 && CGPointEqualToPoint(firstPoint, CGPointZero)) {
        return nil;
    }
    [path moveToPoint:firstPoint];
    for (int i = 1; i < transPoints.count; i++) {
        NSValue *valueI = transPoints[i];
        CGPoint pointI = [valueI CGPointValue];
        [path addLineToPoint:pointI];
    }
    [path addLineToPoint:firstPoint];
    [path closePath];
    
    return path;
}

#pragma mark - UIImagePicker delegate

//  选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        // 用于 QYNetLib 算法的图片，需要是 “正方形” 的(此处截取拍摄图片上、中、下三个区域的正方形截图用于分析)
        UIImage *oriImage = ((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]).fixOrientation;
        NSURL *imgURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSDate *creationDate = [PHAsset fetchAssetsWithALAssetURLs:@[imgURL] options:nil].firstObject.creationDate;
        if (creationDate == nil) {
            creationDate = [NSDate date];
        }
#if TARGET_VERSION_LITE == 0
        [self getResultWithImage:oriImage creationDate:creationDate];
#else
        [self gotoClipPhotoViewController:oriImage imgDate:creationDate];
#endif
    }];
}

//  取消选择图片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.paperAnalysiser.analysiserDelegate = self;
    // 执行扫描
    SCPaperAnalysiserConfiguration.shared.source = SCImageSourceCamera;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getResultWithImage:(UIImage *)oriImage creationDate:(NSDate *)creationDate {
    SCPaperAnalysiserConfiguration.shared.operation = SCImageOperationAuto;
    SCPaperAnalysiserConfiguration.shared.source = SCImageSourceAlbum;
    YCWeakSelf(self)
    [[SCPaperAnalysiser shared] getScanResultFromImage:oriImage completion:^(SCPaperAnalysiserResult * _Nonnull result) {
        YCStrongSelf(self)
        if (creationDate != nil) {
            result.lhTime = creationDate;
        }
        // SDK 回调，后续处理取决于业务需求，Demo 仅为示例
        if (result.error.code == SCErrorCodeNoError) {
            NSLog(@"Result: %@", result);

            [self gotoResultViewController:result];
        } else if (SCErrorCodeUserCanceled == result.error.code) {
            // 用户取消从相册选择图片结果的确认，继续扫描
            SCPaperAnalysiserConfiguration.shared.source = SCImageSourceCamera;
            self.paperAnalysiser.analysiserDelegate = self;
        } else if (result.error.code == SCErrorCodeNoCLine || result.error.code == SCErrorCodeNoTLine) {
            [self didGetIMError:[self errorMsgWith:result.error]];
        } else if (result.error.code == NSURLErrorTimedOut) {
            // 阶段二超时
            [self didGetIMError:@"请求超时"];
        } else {
            UIAlertAction *manualAction = [UIAlertAction actionWithTitle:@"图片裁剪" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self gotoClipPhotoViewController:oriImage imgDate:creationDate];
            }];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self handleImagePicker:nil];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                SCPaperAnalysiserConfiguration.shared.operation = SCImageOperationAuto;
                self.paperAnalysiser.analysiserDelegate = self;
                [self setupUIWithScanning:true];
                [self startScan];
            }];
            
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:[self errorMsgWith:result.error] preferredStyle:UIAlertControllerStyleActionSheet];
            [alertC addAction:manualAction];
            [alertC addAction:retryAction];
            [alertC addAction:cancelAction];
            
            [self presentViewController:alertC animated:true completion:^{
                [self stopScan];
            }];
        }
    }];
}

- (void)gotoClipPhotoViewController:(UIImage *)image imgDate:(NSDate *)imgDate {
    dispatch_async(dispatch_get_main_queue(), ^{
        YCLHPaperManualClipViewController *vc = [[YCLHPaperManualClipViewController alloc] initWithOriginalImage:image];
        
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - lazy load

-(UILabel *)topTintLbl {
    if (_topTintLbl == nil) {
        _topTintLbl = [[UILabel alloc] init];
        _topTintLbl.text = @"请将完整试纸放入取景框内";
        _topTintLbl.font = [UIFont systemFontOfSize:18];
        _topTintLbl.textColor = [UIColor whiteColor];
        _topTintLbl.textAlignment = NSTextAlignmentCenter;
        _topTintLbl.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_topTintLbl];
        [_topTintLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(35);
        }];
    }
    return _topTintLbl;
}

-(UIButton *)flashButton {
    if (_flashButton == nil) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_flashButton setTitle:@"打开闪光灯" forState:UIControlStateNormal];
        [_flashButton setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
        [_flashButton setImage:[UIImage imageNamed:@"icon_lamp_close"] forState:UIControlStateNormal];
        [_flashButton setImage:[UIImage imageNamed:@"icon_lamp_open"] forState:UIControlStateSelected];
        [_flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flashButton setTitleColor:[UIColor colorWithHex:0xF4F400] forState:UIControlStateSelected];
        [_flashButton addTarget:self action:@selector(handleFlashAction:) forControlEvents:UIControlEventTouchUpInside];
        [_flashButton setImageEdgeInsets:UIEdgeInsetsMake(-14, 28, 14, -28)];
        [_flashButton setTitleEdgeInsets:UIEdgeInsetsMake(14, -19, -14, 19)];
        [self.view addSubview:_flashButton];
        [_flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.bottomView.mas_top).mas_offset(-10);
        }];
    }
    return _flashButton;
}

-(UIImageView *)borderImgV {
    if (_borderImgV == nil) {
        _borderImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photopage_pic_scan"]];
       [self.view addSubview:_borderImgV];
       [_borderImgV mas_makeConstraints:^(MASConstraintMaker *make) {
           make.top.mas_equalTo(20);
           make.leading.mas_equalTo(10);
           make.trailing.mas_equalTo(-10);
           make.bottom.mas_equalTo(self.bottomView.mas_top).mas_offset(-10);
       }];
    }
    return _borderImgV;
}

-(UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(kScreenHeight - kTopHeight - kScreenWidth);
        }];
    }
    return _bottomView;
}

-(UIColor *)borderColor {
    return [UIColor colorWithHex:0x79FA1E];
}

-(UILabel *)topCommentLbl {
    if (_topCommentLbl == nil) {
        _topCommentLbl = [[UILabel alloc] init];
        _topCommentLbl.textAlignment = NSTextAlignmentCenter;
        _topCommentLbl.numberOfLines = 0;
        _topCommentLbl.font = [UIFont systemFontOfSize:14];
        _topCommentLbl.adjustsFontSizeToFitWidth = true;
        _topCommentLbl.textColor = [UIColor whiteColor];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"为避免失效，孕橙试纸请在显色后5-10分钟内拍照\n其他试纸请参照相关说明进行拍照识别。"]];
        [attrStr addAttributes:@{NSForegroundColorAttributeName : self.borderColor} range:NSMakeRange(15, 4)];
        _topCommentLbl.attributedText = attrStr.copy;
        [self.bottomView addSubview:_topCommentLbl];
        [_topCommentLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(35);
        }];
    }
    return _topCommentLbl;
}

-(UIView *)buttonContainer {
    if (_buttonContainer == nil) {
        _buttonContainer = [[UIView alloc] init];
        [self.bottomView addSubview:_buttonContainer];
        [_buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(self.topCommentLbl.mas_bottom);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _buttonContainer;
}

-(UIImageView *)albumView {
    if (_albumView == nil) {
        _albumView = [[UIImageView alloc] init];
        _albumView.image = [UIImage imageNamed:@"test_icon_album"];
        [_albumView setUserInteractionEnabled:true];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImagePicker:)];
        [_albumView addGestureRecognizer:tapG];
        [self.buttonContainer addSubview:_albumView];
        [_albumView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.takePictureButton.mas_centerY);
            make.centerX.mas_equalTo(-kScreenWidth * 0.25-22);
        }];
    }
    return _albumView;
}

-(UIButton *)takePictureButton {
    if (_takePictureButton == nil) {
        _takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePictureButton setBackgroundImage:[UIImage imageNamed:@"record_ovu_take_photo"] forState:UIControlStateNormal];
        [_takePictureButton addTarget:self action:@selector(takePictureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:_takePictureButton];
        [_takePictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
        }];
        
        //  刚进入界面立即点击拍照，会因为还没有加载到图像而崩溃
        _takePictureButton.enabled = NO;
        _takePictureButton.alpha = 0.0;
    }
    return _takePictureButton;
}

-(UIButton *)switchBtn {
    if (_switchBtn == nil) {
        _switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchBtn setTitle:@"手动裁剪" forState:UIControlStateNormal];
        _switchBtn.selected = false;
        [_switchBtn setTitle:@"智能扫描" forState:UIControlStateSelected];
        [_switchBtn setImage:[UIImage imageNamed:@"test_ic_change"] forState:UIControlStateNormal];
        [_switchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_switchBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
        [_switchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 73.5, 0, -73.5)];
        [_switchBtn addTarget:self action:@selector(handleSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainer addSubview:_switchBtn];
        [_switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.takePictureButton.mas_centerY);
            make.right.mas_equalTo(0);
            make.left.mas_equalTo(self.takePictureButton.mas_right);
        }];
    }
    return _switchBtn;
}

-(YCTakeLHPhotoManualView *)manualView {
    if (_manualView == nil) {
        _manualView = [[YCTakeLHPhotoManualView alloc] init];
        _manualView.alpha = 0.0;
        [self.view addSubview:_manualView];
        [_manualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(self.bottomView.mas_top);
        }];
    }
    return _manualView;
}

-(CGRect)clipRect {
    CGFloat height = 28.0 + 2.0;
    CGFloat topY = kScreenWidth * 0.5 - height * 0.5;
    return CGRectMake(self.manualView.margin, topY, kScreenWidth - 2 * self.manualView.margin, height);
}

-(CAShapeLayer *)manualMaskLayer {
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:self.clipRect byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeZero];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    [path appendPath:tempPath];
    path.usesEvenOddFillRule = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;  //其他颜色都可以，只要不是透明的
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

-(CAShapeLayer *)maskLayer {
    if (_maskLayer == nil) {
        _maskLayer = [[CAShapeLayer alloc] init];
        _maskLayer.lineWidth = 4.0f;
        _maskLayer.fillColor = [UIColor clearColor].CGColor;
        _maskLayer.strokeColor = self.borderColor.CGColor;
//        _maskLayer.lineDashPattern = @[@4, @3];
    }
    return _maskLayer;
}

-(UIButton *)errorLbl {
    if (_errorLbl == nil) {
        _errorLbl = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorLbl.titleLabel.textColor = [UIColor whiteColor];
        _errorLbl.titleLabel.textAlignment = NSTextAlignmentCenter;
        _errorLbl.titleLabel.numberOfLines = 0;
        _errorLbl.titleLabel.font = [UIFont systemFontOfSize:14];
        _errorLbl.contentEdgeInsets = UIEdgeInsetsMake(10, 18, 10, 18);
        _errorLbl.backgroundColor = [UIColor colorWithHex:0x444444 alpha:0.44];
        _errorLbl.layer.cornerRadius = 4.0;
        _errorLbl.layer.masksToBounds = true;
        _errorLbl.enabled = false;
        _errorLbl.alpha = 0.0f;
        [self.view addSubview:_errorLbl];
        [_errorLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(self.manualView.mas_centerY);
            make.width.mas_lessThanOrEqualTo(kScreenWidth - 80);
        }];
    }
    return _errorLbl;
}

-(UIButton *)errorLblIM {
    if (_errorLblIM == nil) {
        _errorLblIM = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorLblIM.titleLabel.textColor = [UIColor whiteColor];
        _errorLblIM.titleLabel.textAlignment = NSTextAlignmentCenter;
        _errorLblIM.titleLabel.font = [UIFont systemFontOfSize:16];
        _errorLblIM.titleLabel.numberOfLines = 0;
        _errorLblIM.contentEdgeInsets = UIEdgeInsetsMake(20, 28, 20, 28);
        _errorLblIM.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        _errorLblIM.layer.cornerRadius = 10.0;
        _errorLblIM.layer.masksToBounds = true;
        _errorLblIM.enabled = false;
        _errorLblIM.alpha = 0.0f;
    }
    return _errorLblIM;
}

- (AVCaptureDevice *)device {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [_device addObserver:self
                  forKeyPath:@"adjustingFocus"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
//        if ([_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//            NSError *error;
//            if ([_device lockForConfiguration:&error]) {
//                [_device setFocusMode:AVCaptureFocusModeAutoFocus];
////                _device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
////                //设置聚焦在设备坐标的中点
////                if (_device.focusPointOfInterestSupported) {
////                    _device.focusPointOfInterest = CGPointMake(0.5, 0.5);
////                }
//            }
//            [_device unlockForConfiguration];
//        }

    }
    return _device;
}

-(AVCaptureDeviceInput *)inputDevice {
    NSError *error = nil;
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (error == nil) {
        return inputDevice;
    } else {
        NSLog(@"%@--error: %@", [self class], error);
        return nil;
    }
}

-(AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    }
    return _videoDataOutput;
}

-(AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    }
    return _previewLayer;
}

-(CALayer *)drawLayer {
    if (_drawLayer == nil) {
        _drawLayer = [[CALayer alloc] init];
    }
    return _drawLayer;
}

-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
//        _session.sessionPreset = AVCaptureSessionPreset1920x1080;
        [_session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _session;
}

@end
