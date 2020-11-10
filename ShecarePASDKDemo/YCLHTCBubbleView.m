//
//  YCLHTCBubbleView.m
//  Shecare
//
//  Created by 罗培克 on 2018/5/4.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHTCBubbleView.h"
#import <Masonry/Masonry.h>

@interface YCLHTCBubbleView()

@property (strong, nonatomic) UIImageView *borderImgView;
@property (strong, nonatomic) UIView *tView;
@property (strong, nonatomic) UIView *cView;
@property (strong, nonatomic) UILabel *tLabel;
@property (strong, nonatomic) UILabel *cLabel;

@end

@implementation YCLHTCBubbleView
static CGFloat tcCellWidth = 36.0;

-(instancetype)init {
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    [self borderImgView];
    [self tView];
    [self cView];
    [self tLabel];
    [self cLabel];
}

-(void)setTColor:(UIColor *)tColor {
    _tColor = tColor;
    
    self.tView.backgroundColor = tColor;
}

-(void)setCColor:(UIColor *)cColor {
    _cColor = cColor;
    
    self.cView.backgroundColor = cColor;
}

-(UIImageView *)borderImgView {
    if (_borderImgView == nil) {
        _borderImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cr_lh_card_tc"]];
        [self addSubview:_borderImgView];
        [_borderImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
    }
    return _borderImgView;
}

-(UIView *)tView {
    if (_tView == nil) {
        _tView = [[UIView alloc] init];
        [self insertSubview:_tView belowSubview:self.borderImgView];
        CGFloat width = 5.0;
        [_tView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tcCellWidth * 0.33 - width * 0.5);
            make.width.mas_equalTo(width);
            make.top.mas_equalTo(self.borderImgView.mas_top);
            make.height.mas_equalTo(21);
        }];
    }
    return _tView;
}

-(UIView *)cView {
    if (_cView == nil) {
        _cView = [[UIView alloc] init];
        [self insertSubview:_cView belowSubview:self.borderImgView];
        CGFloat width = 5.0;
        [_cView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tcCellWidth * 0.67 - width * 0.5);
            make.width.mas_equalTo(width);
            make.top.mas_equalTo(self.borderImgView.mas_top);
            make.height.mas_equalTo(21);
        }];
    }
    return _cView;
}

-(UILabel *)tLabel {
    if (_tLabel == nil) {
        _tLabel = [[UILabel alloc] init];
        _tLabel.text = @"T";
        [self addSubview:_tLabel];
        [_tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.tView.mas_centerX);
            make.bottom.mas_equalTo(self.tView.mas_top).offset(-4);
        }];
    }
    return _tLabel;
}

-(UILabel *)cLabel {
    if (_cLabel == nil) {
        _cLabel = [[UILabel alloc] init];
        _cLabel.text = @"C";
        [self addSubview:_cLabel];
        [_cLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.cView.mas_centerX);
            make.bottom.mas_equalTo(self.cView.mas_top).offset(-4);
        }];
    }
    return _cLabel;
}

@end
