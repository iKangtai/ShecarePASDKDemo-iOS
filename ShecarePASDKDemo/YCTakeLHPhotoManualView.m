//
//  YCTakeLHPhotoManualView.m
//  Shecare
//
//  Created by mac on 2019/5/29.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCTakeLHPhotoManualView.h"
#import "Masonry.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface YCTakeLHPhotoManualView()

@property (strong, nonatomic) UILabel *topLbl;
@property (strong, nonatomic) UIImageView *exampleImg;
@property (nonatomic, strong) UILabel *tLabel;
@property (nonatomic, strong) UILabel *cLabel;
@property (nonatomic, strong) UILabel *leftComment;
@property (nonatomic, strong) UILabel *rightComment;
@property (nonatomic, strong) UIImageView *frameImgV;

@end

@implementation YCTakeLHPhotoManualView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self exampleImg];
    [self tLabel];
    [self cLabel];
    [self topLbl];
    
    CGFloat topY = kScreenWidth * 0.5 - 89 - 14;
    CGFloat bottomY = kScreenWidth * 0.5 + 16 + 14;
    // left dotline
    [self.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(self.margin, topY) endPoint:CGPointMake(self.margin, bottomY)]];
    // right dotline
    [self.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(kScreenWidth - self.margin, topY) endPoint:CGPointMake(kScreenWidth - self.margin, bottomY)]];
    topY = kScreenWidth * 0.5 - 14;
    bottomY = kScreenWidth * 0.5 + 14;
    // top dotline
    [self.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(self.margin, topY) endPoint:CGPointMake(kScreenWidth - self.margin, topY)]];
    // bottom dotline
    [self.layer addSublayer:[self dotLineLayerWithStartPoint:CGPointMake(self.margin, bottomY) endPoint:CGPointMake(kScreenWidth - self.margin, bottomY)]];
    // clipRect 和虚线矩形框对应
    self.clipRect = CGRectMake(self.margin, topY, kScreenWidth - 2 * self.margin, 28);
#if TARGET_VERSION_LITE == 1
    CGFloat frX = (kScreenWidth - 2 * self.margin) * 0.38;
    CGFloat frW = (kScreenWidth - 2 * self.margin) * 0.19;
    self.frameImgV.frame = CGRectMake(frX, topY - 4, frW, 28 + 8);
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
    layer.strokeColor = [UIColor yellowColor].CGColor;
    layer.lineDashPattern = @[@(6), @(6)];
    layer.fillColor = [UIColor clearColor].CGColor;
#endif
    return layer;
}

-(CGFloat)margin {
    return 0.0;
}

#pragma mark - Lazy load

-(UILabel *)topLbl {
    if (_topLbl == nil) {
        _topLbl = [[UILabel alloc] init];
        _topLbl.text = @"请务必保持试纸处在取景框内";
        _topLbl.font = [UIFont systemFontOfSize:14];
        _topLbl.textColor = [UIColor whiteColor];
        _topLbl.textAlignment = NSTextAlignmentCenter;
        _topLbl.backgroundColor = [UIColor clearColor];
        [self addSubview:_topLbl];
        [_topLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.cLabel.mas_top).mas_offset(-4);
        }];
    }
    return _topLbl;
}

-(UIImageView *)exampleImg {
    if (_exampleImg == nil) {
        UIImage *image = [UIImage imageNamed:@"record_ovu_paper"];
        _exampleImg = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_exampleImg];
        [_exampleImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.margin);
            make.right.mas_equalTo(-self.margin);
            make.bottom.mas_equalTo(self.mas_centerY).offset(-14-36);
        }];
    }
    return _exampleImg;
}

-(UILabel *)tLabel {
    if (_tLabel == nil) {
        _tLabel = [[UILabel alloc] init];
        _tLabel.textColor = [UIColor whiteColor];
        _tLabel.text = @"T";
        _tLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:_tLabel];
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
        [self addSubview:_cLabel];
        CGFloat clblX = 355.0 / 710.0 * (kScreenWidth - 2 * self.margin);
        [_cLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.exampleImg.mas_left).mas_offset(clblX);
            make.bottom.mas_equalTo(self.tLabel.mas_bottom);
        }];
    }
    return _cLabel;
}

-(UILabel *)leftComment {
    if (_leftComment == nil) {
        _leftComment = [[UILabel alloc] init];
        _leftComment.textColor = [UIColor whiteColor];
        _leftComment.text = @"左边缘";
        _leftComment.font = [UIFont boldSystemFontOfSize:14];
        [self addSubview:_leftComment];
        [_leftComment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.margin);
            make.top.mas_equalTo(self.mas_centerY).offset(14+24);
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
        [self addSubview:_rightComment];
        [_rightComment mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.margin);
            make.top.mas_equalTo(self.leftComment.mas_top);
        }];
    }
    return _rightComment;
}

-(UIImageView *)frameImgV {
    if (_frameImgV == nil) {
        _frameImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finder_frame_record_test"]];
        [self addSubview:_frameImgV];
    }
    return _frameImgV;
}

@end
