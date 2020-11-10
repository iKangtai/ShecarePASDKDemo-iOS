//
//  YCLHCardEditView.m
//  Shecare
//
//  Created by mac on 2019/6/1.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHCardEditView.h"
#import <Masonry/Masonry.h>
#import "YCLHCardCell.h"
#import "YCLHTCBubbleView.h"
#import "UIColor+YCExtension.h"

@interface YCLHCardEditView()

@property (strong, nonatomic) NSArray<YCLHCardCellModel *> *colors;
@property (strong, nonatomic) YCLHTCBubbleView *bubbleView;
@property (nonatomic, strong) UILabel *titleLbl;

@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) UIView *slideBGView;
@property (strong, nonatomic) UIView *slideView;
@property (strong, nonatomic) UIView *roundView;
@property (nonatomic, strong) YCLHCardColorsView *colorsView;

@end

@implementation YCLHCardEditView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.progress = 0.0;
        [self setupColors];
    }
    return self;
}

-(void)setupColors {
    [self titleLbl];
    self.colors = @[[YCLHCardCellModel modelWithResult:1],  //  手动输入的结果使用 int 数据里的8位保存，8位的值初始为0，会造成 “手动输入0” 和 “没有输入” 的结果一样，使用 1 表示用户输入 0
                    [YCLHCardCellModel modelWithResult:5],
                    [YCLHCardCellModel modelWithResult:10],
                    [YCLHCardCellModel modelWithResult:15],
                    [YCLHCardCellModel modelWithResult:20],
                    [YCLHCardCellModel modelWithResult:25],
                    [YCLHCardCellModel modelWithResult:45],
                    [YCLHCardCellModel modelWithResult:65]];
    self.bubbleView.tColor = self.colors[0].color;
    [self slideBGView];
    [self.slideBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo([self centerXWithIndex:0]);
        make.right.mas_equalTo(self.mas_left).mas_offset([self centerXWithIndex:(self.colors.count-1)]);
        make.bottom.mas_equalTo(-70.0);
        make.height.mas_equalTo(8.0);
    }];
    self.slideBGView.layer.masksToBounds = true;
    self.slideBGView.layer.cornerRadius = 4.0;
    [self.bubbleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_left).mas_offset([self centerXWithIndex:0]);
        make.bottom.mas_equalTo(self.slideBGView.mas_top).mas_offset(-8);
        make.width.mas_equalTo(36);
        make.height.mas_equalTo(40);
    }];
    [self slideView];
    [self roundView];
    [self addTouchEvent];
    YCWeakSelf(self)
    self.colorsView.touchesEndedHandler = ^(CGFloat pointX) {
        YCStrongSelf(self)
        [self adjustProgressWithPointX:pointX];
    };
}

-(void)setResult:(NSInteger)result {
    _result = result;
    
    NSUInteger idx = [self indexWithResult:result];
    [self updateProgressWithCenterX:[self centerXWithIndex:idx]];
}

-(void)addTouchEvent {
    UIPanGestureRecognizer *panG = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.roundView addGestureRecognizer:panG];
    //  一个 UIPanGestureRecognizer 只能加到一个 View 上
    UIPanGestureRecognizer *panG2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [self.bubbleView addGestureRecognizer:panG2];
}

-(NSUInteger)indexWithResult:(NSInteger)result {
    NSUInteger normResult = (NSUInteger)result;
    for (NSUInteger i = 0; i < self.colors.count; i++) {
        YCLHCardCellModel *modelI = self.colors[i];
        if (modelI.result == normResult) {
            return i;
        }
    }
    return 0;
}

-(void)setColors:(NSArray *)colors {
    _colors = colors;
    
    for (NSUInteger i = 0; i < colors.count; i++) {
        YCLHCardCellModel *cellModelI = colors[i];
        [self addCell:cellModelI atIndex:i];
    }
}

-(CGFloat)averageWidth {
    CGFloat totalW = self.frame.size.width;
    if (self.colors.count == 0) {
        return 0;
    }
    return totalW / self.colors.count;
}

-(CGFloat)centerXWithIndex:(NSUInteger)index {
    CGFloat avgW = [self averageWidth];
    CGFloat centerX = (index + 0.5) * avgW;
    return centerX;
}

-(void)addCell:(YCLHCardCellModel *)cellModel atIndex:(NSUInteger)index {
    CGFloat centerX = [self centerXWithIndex:index];
    CGFloat width = [self averageWidth];
    YCLHCardCell *cell = [[YCLHCardCell alloc] initWithModel:cellModel];
    [self insertSubview:cell belowSubview:self.colorsView];
    [cell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.colorsView.mas_left).mas_offset(centerX);
        make.width.mas_equalTo(width);
        make.bottom.mas_equalTo(self.colorsView.mas_bottom);
        make.top.mas_equalTo(self.colorsView.mas_top);
    }];
}

-(void)handleDrag:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint trans = [gesture translationInView:self];
            [self updateProgressWithCenterX:gesture.view.center.x + trans.x];
            [gesture setTranslation:CGPointZero inView:self];
        }
            break;
        default:
            [self adjustProgressWithPointX:gesture.view.center.x];
            break;
    }
}

-(void)updateProgressWithCenterX:(CGFloat)centerX {
    CGFloat minCX = [self centerXWithIndex:0];
    CGFloat maxCX = [self centerXWithIndex:(self.colors.count-1)];
    if (centerX < minCX) {
        centerX = minCX;
    } else if (centerX > maxCX) {
        centerX = maxCX;
    }
    [self.bubbleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_left).mas_offset(centerX);
    }];
    NSInteger idx = [self indexWithPoint:centerX];
    self.bubbleView.tColor = self.colors[idx].color;
}

-(NSInteger)indexWithPoint:(CGFloat)pointX {
    CGFloat avgW = [self averageWidth];
    if (avgW == 0) {
        return 0;
    }
    NSInteger result = (NSInteger)(pointX / avgW);
    if (result < 0 || result >= self.colors.count) {
        return 0;
    }
    return result;
}

-(void)adjustProgressWithPointX:(CGFloat)pointX {
    NSInteger idx = [self indexWithPoint:pointX];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.result = self.colors[idx].result;
            if (self.resultDidChange != nil) {
                self.resultDidChange(self.result);
            }
        }];
    });
}

#pragma mark - lazy load

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"T线色值参考条，拖动色卡修正结果！"];
        _titleLbl.attributedText = attrStr;
        [self addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(4);
        }];
    }
    return _titleLbl;
}

-(YCLHTCBubbleView *)bubbleView {
    if (_bubbleView == nil) {
        _bubbleView = [[YCLHTCBubbleView alloc] init];
        _bubbleView.cColor = [UIColor colorWithHex:0xC2859A];
        [self addSubview:_bubbleView];
        _bubbleView.userInteractionEnabled = true;
    }
    return _bubbleView;
}

-(UIView *)slideBGView {
    if (_slideBGView == nil) {
        _slideBGView = [[UIView alloc] init];
        _slideBGView.backgroundColor = [UIColor colorWithHex:0xD8D8D8];
        [self addSubview:_slideBGView];
    }
    return _slideBGView;
}

-(UIView *)slideView {
    if (_slideView == nil) {
        _slideView = [[UIView alloc] init];
        [self.slideBGView addSubview:_slideView];
        [_slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(self.bubbleView.mas_centerX);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        _slideView.backgroundColor = [UIColor colorWithHex:0xFF7486];
    }
    return _slideView;
}

-(UIView *)roundView {
    if (_roundView == nil) {
        _roundView = [[UIView alloc] init];
        [self addSubview:_roundView];
        [_roundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.bubbleView.mas_centerX);
            make.centerY.mas_equalTo(self.slideView.mas_centerY);
            make.width.mas_equalTo(self.bubbleView.mas_width);
            make.top.mas_equalTo(self.bubbleView.mas_bottom);
        }];
        _roundView.userInteractionEnabled = true;
        
        UIView *circleView = [[UIView alloc] init];
        circleView.userInteractionEnabled = true;
        circleView.layer.masksToBounds = true;
        circleView.layer.cornerRadius = 8.0;
        circleView.backgroundColor = [UIColor colorWithHex:0xFF7486];
        [_roundView addSubview:circleView];
        [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.width.mas_equalTo(16);
            make.height.mas_equalTo(16);
        }];
    }
    return _roundView;
}

-(YCLHCardColorsView *)colorsView {
    if (_colorsView == nil) {
        _colorsView = [[YCLHCardColorsView alloc] init];
        [self addSubview:_colorsView];
        [_colorsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.top.mas_equalTo(self.slideBGView.mas_top).mas_offset(-4);
        }];
    }
    return _colorsView;
}

@end
