//
//  YCLHResultView.m
//  Shecare
//
//  Created by 罗培克 on 2017/12/28.
//  Copyright © 2017年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHResultView.h"
#import <Masonry/Masonry.h>
#import "YCLHCardEditView.h"
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "UIColor+YCExtension.h"

@interface YCLHResultView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *topContainer;
@property (strong, nonatomic) UIView *centerContainer;
@property (strong, nonatomic) UILabel *resultLbl;

@property (assign, nonatomic, readonly) NSInteger topMargin;
@property (assign, nonatomic, readonly) NSInteger leftMargin;
@property (assign, nonatomic, readonly) NSInteger margin;
@property (nonatomic, strong) YCLHCardEditView *cardEditView;
@property (strong, nonatomic) UIView *bottomContainer;
//@property (nonatomic, strong) YCDatePickerView *dateTimePicker;
@property (strong, nonatomic) UIButton *dateBtn;
@property (nonatomic, strong) UITextView *debugTV;
@property (nonatomic, strong) UILabel *subTitle1;
@property (strong, nonatomic) UIImageView *pictureView;
@property (nonatomic, strong) SCPaperAnalysiserResult *anaResult;
@property (nonatomic, copy) void (^valueChangedAction)(SCPaperAnalysiserResult *);

@end

@implementation YCLHResultView

-(instancetype)initWitResult:(SCPaperAnalysiserResult *)result valueChangedAction:(void (^)(SCPaperAnalysiserResult *))valueChangedAction {
    if (self = [super init]) {
        [self setupUI];
        self.anaResult = result;
        self.valueChangedAction = valueChangedAction;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    [self topContainer];
    [self subTitle1];
    [self pictureView];
    [self resultLbl];
    [self centerContainer];
#if TARGET_VERSION_LITE == 0
    [self cardEditView];
#endif
    [self bottomContainer];
    [self dateBtn];
    [self debugTV];
}

- (NSString *)yyyyMMddHHmmssStringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

-(void)setDebugInfo:(NSString *)debugInfo {
    _debugInfo = debugInfo;
    
    self.debugTV.text = debugInfo;
}

-(void)setAnaResult:(SCPaperAnalysiserResult *)anaResult {
    _anaResult = anaResult;
    
    NSString *dateStr = [self yyyyMMddHHmmssStringFromDate:anaResult.lhTime];
    [self.dateBtn setTitle:dateStr forState:UIControlStateNormal];
#if TARGET_VERSION_LITE == 0
    if (anaResult.lhResult >= 0) {
        self.cardEditView.result = anaResult.lhResult;
    } else {
        self.cardEditView.result = 10;
    }
    [self setCommentResult];
#else
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"LH Ratio："];
    NSString *result = [NSString stringWithFormat:@"%@", @(self.anaResult.lhRatio)];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0xFF7486]}]];
    self.resultLbl.attributedText = attrStr.copy;
#endif
    self.pictureView.image = self.anaResult.finalImage;
}

-(void)setCommentResult {
    NSNumber *lhR = self.anaResult.newLHResult > 0 ? @(self.anaResult.newLHResult) : @(self.anaResult.lhResult);
    NSString *result = [NSString stringWithFormat:@"%@", lhR];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"参考值："];
    if (result.length > 0) {
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:result attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHex:0xFF7486]}]];
    }
    self.resultLbl.attributedText = attrStr.copy;
}

#pragma mark - Lazy load

-(UIView *)topContainer {
    if (_topContainer == nil) {
        _topContainer = [[UIView alloc] init];
        _topContainer.backgroundColor = [UIColor whiteColor];
        [self addSubview:_topContainer];
        [_topContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(8);
#if TARGET_VERSION_LITE == 0
            make.height.mas_equalTo(240);
#else
            make.height.mas_equalTo(80);
#endif
        }];
    }
    return _topContainer;
}

-(UILabel *)subTitle1 {
    if (_subTitle1 == nil) {
        _subTitle1 = [[UILabel alloc] init];
        _subTitle1.font = [UIFont systemFontOfSize:17];
        _subTitle1.textColor = [UIColor darkTextColor];
        _subTitle1.text = @"试纸照片";
        [self.topContainer addSubview:_subTitle1];
        [_subTitle1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftMargin);
            make.top.mas_equalTo(self.topMargin);
        }];
    }
    return _subTitle1;
}

-(UIImageView *)pictureView {
    if (_pictureView == nil) {
        _pictureView = [[UIImageView alloc] init];
        _pictureView.contentMode = UIViewContentModeScaleAspectFit;
        _pictureView.clipsToBounds = YES;
        _pictureView.userInteractionEnabled = YES;
        [self.topContainer addSubview:_pictureView];
        [_pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(5);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(self.subTitle1.mas_bottom).mas_offset(4);
            make.height.mas_equalTo((35));
        }];
    }
    return _pictureView;
}

-(YCLHCardEditView *)cardEditView {
    if (_cardEditView == nil) {
        _cardEditView = [[YCLHCardEditView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 130)];
        YCWeakSelf(self)
        _cardEditView.resultDidChange = ^(NSInteger result){
            YCStrongSelf(self)
            self.anaResult.newLHResult = result;
            [self setCommentResult];
            if (self.valueChangedAction != nil) {
                self.valueChangedAction(self.anaResult);
            }
        };
        [self.topContainer addSubview:_cardEditView];
        [_cardEditView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(self.pictureView.mas_bottom).mas_offset(8);
        }];
    }
    return _cardEditView;
}

-(UIView *)centerContainer {
    if (_centerContainer == nil) {
        _centerContainer = [[UIView alloc] init];
        _centerContainer.backgroundColor = [UIColor whiteColor];
        [self addSubview:_centerContainer];
        [_centerContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(self.topContainer.mas_bottom).mas_offset(8);
            make.height.mas_equalTo(40);
        }];
    }
    return _centerContainer;
}

-(UIView *)bottomContainer {
    if (_bottomContainer == nil) {
        _bottomContainer = [[UIView alloc] init];
        _bottomContainer.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bottomContainer];
        [_bottomContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(self.centerContainer.mas_bottom).offset(8);
            make.height.mas_equalTo(40);
        }];
        
        UILabel *timeLbl = [[UILabel alloc] init];
        timeLbl.text = @"检测时间";
        timeLbl.textColor = [UIColor darkTextColor];
        timeLbl.textAlignment = NSTextAlignmentLeft;
        [_bottomContainer addSubview:timeLbl];
        
        [timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftMargin);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _bottomContainer;
}

-(UIButton *)dateBtn {
    if (_dateBtn == nil) {
        _dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bottomContainer addSubview:_dateBtn];
        [_dateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-self.leftMargin);
            make.centerY.mas_equalTo(0);
        }];
        [_dateBtn setTitleColor:[UIColor colorWithHex:0xFF7486] forState:UIControlStateNormal];
    }
    return _dateBtn;
}

-(UILabel *)resultLbl {
    if (_resultLbl == nil) {
        _resultLbl = [[UILabel alloc] init];
        _resultLbl.font = [UIFont systemFontOfSize:17];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"分析中，请稍候……"];
        _resultLbl.attributedText = attrStr;
        [self.centerContainer addSubview:_resultLbl];
        [_resultLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.leftMargin);
            make.top.mas_equalTo(8);
        }];
    }
    return _resultLbl;
}

-(UITextView *)debugTV {
    if (_debugTV == nil) {
        _debugTV = [[UITextView alloc] init];
        _debugTV.editable = false;
        [self addSubview:_debugTV];
        [_debugTV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-74);
            make.top.mas_equalTo(self.bottomContainer.mas_bottom).mas_offset(8);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
    }
    return _debugTV;
}

-(NSInteger)leftMargin {
    return 15.0;
}

-(NSInteger)margin {
    return 8.0;
}

-(NSInteger)topMargin {
    return (8.0);
}

@end
