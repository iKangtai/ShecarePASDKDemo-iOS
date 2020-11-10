//
//  YCLHPaperManualClipViewController.h
//  Shecare
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCLHPaperManualClipViewController : UIViewController

@property (nonatomic, assign, readonly) CGFloat margin;

- (instancetype)initWithOriginalImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
