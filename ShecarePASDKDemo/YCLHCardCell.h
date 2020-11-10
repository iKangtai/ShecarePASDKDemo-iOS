//
//  YCLHCardCell.h
//  Shecare
//
//  Created by mac on 2019/6/1.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCLHCardCellModel: NSObject

@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) NSUInteger result;


+(YCLHCardCellModel *)modelWithResult:(NSInteger)result;

@end

@interface YCLHCardCell : UIControl

@property (nonatomic, strong) YCLHCardCellModel *model;

-(instancetype)initWithModel:(YCLHCardCellModel *)model;

@end

@interface YCLHCardColorsView : UIControl

@property (nonatomic, copy) void (^touchesEndedHandler)(CGFloat pointX);

@end

NS_ASSUME_NONNULL_END
