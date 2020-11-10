//
//  YCLHPaperManualClipViewController.m
//  Shecare
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHPaperManualClipViewController.h"
#import <Masonry/Masonry.h>
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "UIColor+YCExtension.h"
#import "YCLHResultViewController.h"

@interface YCLHPaperManualClipViewController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UILabel *topLbl;
@property (strong, nonatomic) UIImageView *exampleImg;
@property (nonatomic, strong) UILabel *tLabel;
@property (nonatomic, strong) UILabel *cLabel;
@property (nonatomic, strong) UILabel *leftComment;
@property (nonatomic, strong) UILabel *rightComment;
@property (strong, nonatomic) UILabel *gestureComment;
@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) UIImage *originalImage;

@property (strong, nonatomic) UIImageView *originalImageView;
@property (nonatomic, strong) UIView *containerView;
@property (strong, nonatomic) UIButton *chooseBtn;
///  缩放的总倍数
@property (assign, nonatomic) CGFloat totalScale;

@property (nonatomic, assign) CGRect clipFrame;
@property (nonatomic, strong) UIImageView *frameImgV;

@end

@implementation YCLHPaperManualClipViewController

- (instancetype)initWithOriginalImage:(UIImage *)image {
    if (self = [super init]) {
        self.originalImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
    [self setupNavigationItem];
    SCPaperAnalysiserConfiguration.shared.operation = SCImageOperationManual;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupClipLayer];
}

- (void)setupNavigationItem {
    NSString *titleStr = @"排卵试纸";
    self.navigationItem.title = titleStr;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_record"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupUI {
    [self maskView];
    [self containerView];
    [self originalImageView];
    [self exampleImg];
    [self topLbl];
    [self tLabel];
    [self cLabel];
    [self chooseBtn];
    [self gestureComment];
}

-(void)setupClipLayer {
    CGFloat left = self.margin;
    CGFloat right = kScreenWidth - self.margin;
    CGFloat topY = CGRectGetMinY(self.exampleImg.frame) - 36;
    CGFloat bottomY = CGRectGetMaxY(self.exampleImg.frame) + 80;
    // left dotline
    [self.view.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(left, topY) endPoint:CGPointMake(left, bottomY)]];
    // right dotline
    [self.view.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(right, topY) endPoint:CGPointMake(right, bottomY)]];
    topY = CGRectGetMaxY(self.exampleImg.frame) + 40;
    bottomY = CGRectGetMaxY(self.exampleImg.frame) + 40 + 28;
    // top dotline
    [self.view.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(left, topY) endPoint:CGPointMake(right, topY)]];
    // bottom dotline
    [self.view.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(left, bottomY) endPoint:CGPointMake(right, bottomY)]];
    // clipRect 和虚线矩形框对应
    self.clipFrame = CGRectMake(left, topY, right - left, bottomY - topY);
    self.maskView.layer.mask = self.manualMaskLayer;
#if TARGET_VERSION_LITE == 1
    CGFloat frX = (kScreenWidth - 2 * self.margin) * 0.38;
    CGFloat frW = (kScreenWidth - 2 * self.margin) * 0.19;
    self.frameImgV.frame = CGRectMake(frX, topY - 4, frW, bottomY - topY + 8);
#endif
}

-(CAShapeLayer *)dotLineLayerWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    CAShapeLayer *layer = [CAShapeLayer layer];
#if TARGET_VERSION_LITE == 0
    [self leftComment];
    [self rightComment];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path closePath];
    layer.path = path.CGPath;
    layer.lineWidth = 2.0;
    layer.strokeColor = [UIColor colorWithHex:0xF9F900].CGColor;
    layer.lineDashPattern = @[@(6), @(6)];
    layer.fillColor = [UIColor clearColor].CGColor;
#endif
    return layer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

-(void)dealloc {
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

- (void)chooseBtnClick:(UIButton *)sender {
    CGFloat resultW =  self.containerView.frame.size.width;
    // 为避免浮点数精度，造成裁剪出来的图片有 “黑边”，使用 floor 对结果 “向下取整”
    CGFloat resultH = self.containerView.frame.size.height;

    //  重新绘制图片到指定大小
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(resultW, resultH), true, [UIScreen mainScreen].scale);
    [self.containerView drawViewHierarchyInRect:CGRectMake(0, 0, resultW, resultH) afterScreenUpdates:true];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //  生成图片 并 修复图片方向
    NSArray *points = [self pointsFromRect:self.clipFrame scale:[UIScreen mainScreen].scale];
    [self paperAnalysisWith:result points:points];
}

- (NSArray *)pointsFromRect:(CGRect)clipRect scale:(CGFloat)scale {
    NSMutableArray *resultM = [NSMutableArray arrayWithCapacity:2];
    [resultM addObject:[NSValue valueWithCGPoint:CGPointMake(clipRect.origin.x * scale, clipRect.origin.y * scale)]];
    [resultM addObject:[NSValue valueWithCGPoint:CGPointMake((clipRect.origin.x + clipRect.size.width) * scale, (clipRect.origin.y + clipRect.size.height) * scale)]];
    return resultM.copy;
}

- (void)paperAnalysisWith:(UIImage *)image points:(NSArray *)points {
    // 调用方使用以下方法处理 “照片手动裁剪” 模式下的 SDK 调用
    // 传入的 image 是 “经过了用户拖动、缩放、旋转等操作后的当前页面截图”
    // points 是 “裁剪框” 的左上角和右下角顶点坐标
    [[SCPaperAnalysiser shared] getScanResultFromSnapShot:image points:points completion:^(SCPaperAnalysiserResult * _Nonnull result) {
        result.source = SCImageSourceAlbum;
        if (result.error.code != SCErrorCodeUserCanceled) {
            dispatch_async(dispatch_get_main_queue(), ^{
                YCLHResultViewController *vc = [[YCLHResultViewController alloc] initWithResult:result];
                [self.navigationController pushViewController:vc animated:YES];
            });
        }
    }];
}

#pragma mark - GestureRecognizer Handle

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint trans = [gesture translationInView:self.view];
        self.originalImageView.center = CGPointMake(self.originalImageView.center.x + trans.x,self.originalImageView.center.y + trans.y);
        [gesture setTranslation:CGPointZero inView:self.view];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = gesture.scale;
        CGFloat oldScale = self.totalScale;
        self.totalScale = self.totalScale * scale;
        if (self.totalScale >= 0.5 && self.totalScale <= 2.0) {
            self.originalImageView.transform = CGAffineTransformScale(self.originalImageView.transform, scale, scale);
            gesture.scale = 1;
        } else {
            self.totalScale = oldScale;
        }
    }
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.originalImageView.transform = CGAffineTransformRotate(self.originalImageView.transform, gesture.rotation);
        gesture.rotation = 0;
    }
}

#pragma mark - lazy load

-(UILabel *)topLbl {
    if (_topLbl == nil) {
        _topLbl = [[UILabel alloc] init];
        _topLbl.text = @"请务必保持试纸处在取景框内";
        _topLbl.font = [UIFont systemFontOfSize:14];
        _topLbl.textColor = [UIColor whiteColor];
        _topLbl.textAlignment = NSTextAlignmentCenter;
        _topLbl.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_topLbl];
        [_topLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.cLabel.mas_top).mas_offset(-4);
        }];
    }
    return _topLbl;
}

-(UILabel *)tLabel {
    if (_tLabel == nil) {
        _tLabel = [[UILabel alloc] init];
        _tLabel.textColor = [UIColor whiteColor];
        _tLabel.text = @"T";
        _tLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:_tLabel];
        CGFloat tlblX = 310.0 / 710.0 * (kScreenWidth - 2 * self.margin);
        [_tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.exampleImg.mas_left).mas_offset(tlblX);
            make.bottom.mas_equalTo(self.exampleImg.mas_top).offset(-4);
        }];
    }
    return _tLabel;
}

-(UILabel *)cLabel {
    if (_cLabel == nil) {
        _cLabel = [[UILabel alloc] init];
        _cLabel.textColor = [UIColor whiteColor];
        _cLabel.text = @"C";
        _cLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.view addSubview:_cLabel];
        CGFloat clblX = 355.0 / 710.0 * (kScreenWidth - 2 * self.margin);
        [_cLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.exampleImg.mas_left).mas_offset(clblX);
            make.bottom.mas_equalTo(self.tLabel.mas_bottom);
        }];
    }
    return _cLabel;
}

-(UIImageView *)exampleImg {
    if (_exampleImg == nil) {
        UIImage *image = [UIImage imageNamed:@"record_ovu_paper"];
        _exampleImg = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:_exampleImg];
        [_exampleImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.margin);
            make.right.mas_equalTo(-self.margin);
            make.bottom.mas_equalTo(self.view.mas_centerY).offset(-70);
        }];
    }
    return _exampleImg;
}

-(UILabel *)gestureComment {
    if (_gestureComment == nil) {
        _gestureComment = [[UILabel alloc] init];
        _gestureComment.userInteractionEnabled = YES;
        _gestureComment.text = @"可以拖动、旋转、放大或缩小来操作照片";
        _gestureComment.font = [UIFont systemFontOfSize:16];
        _gestureComment.textColor = [UIColor whiteColor];
        [self.view addSubview:_gestureComment];
        [_gestureComment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.chooseBtn.mas_top).mas_offset(-8);
        }];
    }
    return _gestureComment;
}

-(UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.4;
        _maskView.userInteractionEnabled = true;
        [self.view insertSubview:_maskView atIndex:0];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    return _maskView;
}

-(UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor lightGrayColor];
        _containerView.userInteractionEnabled = true;
        [self.view insertSubview:_containerView atIndex:0];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _containerView;
}

-(UIImageView *)originalImageView {
    if (_originalImageView == nil) {
        _originalImageView = [[UIImageView alloc] initWithImage:self.originalImage];
        _originalImageView.userInteractionEnabled = YES;
        _originalImageView.backgroundColor = self.view.backgroundColor;
        
        // 这里的手势不能添加到 originalImageView 上，因为 originalImageView 的父视图为 clipView，clipView 的 frame 很小（子视图的 Frame 大于父视图），会造成能够响应手势交互的区域也很小，造成手势失效
        UIPanGestureRecognizer *panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panG.delegate = self;
        [self.view addGestureRecognizer:panG];
        
        UIPinchGestureRecognizer *pinchG = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        pinchG.delegate = self;
        self.totalScale = 1.0f;
        [self.view addGestureRecognizer:pinchG];
        
        UIRotationGestureRecognizer *rotationG = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
        rotationG.delegate = self;
        [self.view addGestureRecognizer:rotationG];
        
        CGFloat imgH = self.originalImage.size.height * kScreenWidth / self.originalImage.size.width;
        [self.containerView addSubview:_originalImageView];
        [_originalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top);
            make.left.mas_equalTo(self.view.mas_left);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(imgH);
        }];
    }
    return _originalImageView;
}

-(UIButton *)chooseBtn {
    if (_chooseBtn == nil) {
        _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseBtn.backgroundColor = [UIColor colorWithHex:0xFF7486];
        [_chooseBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_chooseBtn addTarget:self action:@selector(chooseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat btnH = 40;
        _chooseBtn.layer.cornerRadius = btnH * 0.5;
        _chooseBtn.layer.masksToBounds = YES;
        [self.view addSubview:_chooseBtn];
        [_chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-4);
            make.height.mas_equalTo(btnH);
            make.width.mas_equalTo(kScreenWidth-200);
        }];
    }
    return _chooseBtn;
}

-(UILabel *)leftComment {
    if (_leftComment == nil) {
        _leftComment = [[UILabel alloc] init];
        _leftComment.textColor = [UIColor whiteColor];
        _leftComment.text = @"左边缘";
        _leftComment.font = [UIFont boldSystemFontOfSize:14];
        [self.view addSubview:_leftComment];
        [_leftComment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.margin);
            make.top.mas_equalTo(self.exampleImg.mas_bottom).offset(90);
        }];
    }
    return _leftComment;
}

-(UILabel *)rightComment {
    if (_rightComment == nil) {
        _rightComment = [[UILabel alloc] init];
        _rightComment.textColor = [UIColor whiteColor];
        _rightComment.text = @"右边缘";
        _rightComment.font = [UIFont boldSystemFontOfSize:14];
        [self.view addSubview:_rightComment];
        [_rightComment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.margin);
            make.top.mas_equalTo(self.leftComment.mas_top);
        }];
    }
    return _rightComment;
}

-(CAShapeLayer *)manualMaskLayer {
    UIBezierPath *tempPath = [UIBezierPath bezierPathWithRoundedRect:self.clipFrame byRoundingCorners:(UIRectCornerTopLeft |UIRectCornerTopRight |UIRectCornerBottomRight|UIRectCornerBottomLeft) cornerRadii:CGSizeZero];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    [path appendPath:tempPath];
    path.usesEvenOddFillRule = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;  //其他颜色都可以，只要不是透明的
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

-(UIImageView *)frameImgV {
    if (_frameImgV == nil) {
        _frameImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finder_frame_record_test"]];
        [self.view addSubview:_frameImgV];
    }
    return _frameImgV;
}

-(CGFloat)margin {
    return 0.0f;
}

@end
