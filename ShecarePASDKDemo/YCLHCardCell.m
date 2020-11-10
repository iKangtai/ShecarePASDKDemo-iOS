//
//  YCLHCardCell.m
//  Shecare
//
//  Created by mac on 2019/6/1.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHCardCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+YCExtension.h"

@implementation YCLHCardCellModel

-(instancetype)initWithResult:(NSInteger)result {
    if (self = [super init]) {
        self.color = [self colorWithLHResult:result];
        self.result = result;
    }
    return self;
}

+(YCLHCardCellModel *)modelWithResult:(NSInteger)result {
    return [[self alloc] initWithResult:result];
}

-(UIColor *)colorWithLHResult:(NSInteger)number {
    if (65 == number) {
        return [UIColor colorWithHex:0x894058];
    } else if (45 == number) {
        return [UIColor colorWithHex:0xA05E74];
    } else if (25 == number) {
        return [UIColor colorWithHex:0xC2859A];
    } else if (20 == number) {
        return [UIColor colorWithHex:0xD8A8BE];
    } else if (15 == number) {
        return [UIColor colorWithHex:0xDEB9CA];
    } else if (10 == number) {
        return [UIColor colorWithHex:0xFDE1EB];
    } else if (5 == number) {
        return [UIColor colorWithHex:0xFFEFF5];
    } else {
        return [UIColor colorWithHex:0xF7F0F0];
    }
}

@end

@implementation YCLHCardCell

-(instancetype)initWithModel:(YCLHCardCellModel *)model {
    if (self = [super initWithFrame:CGRectZero]) {
        self.model = model;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    UILabel *lblI = [[UILabel alloc] init];
    lblI.text = [NSString stringWithFormat:@"%@", @(self.model.result)];
    [self addSubview:lblI];
    [lblI mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-8);
    }];
    
    UIView *subV = [[UIView alloc] init];
    subV.backgroundColor = self.model.color;
    [self addSubview:subV];
    [subV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(lblI.mas_centerX);
        make.width.mas_equalTo(6.0);
        make.height.mas_equalTo(20.0);
        make.bottom.mas_equalTo(lblI.mas_top).mas_offset(-4);
    }];
}

@end

@implementation YCLHCardColorsView

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGFloat pointX = [touch locationInView:self].x;
    if (self.touchesEndedHandler != nil) {
        self.touchesEndedHandler(pointX);
    }
}

@end
