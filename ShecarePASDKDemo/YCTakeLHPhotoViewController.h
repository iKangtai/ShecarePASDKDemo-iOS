//
//  YCTakeLHPhotoViewController.h
//  Shecare
//
//  Created by 罗培克 on 2019/4/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCTakeLHPhotoViewController : YCViewController

@property (strong, nonatomic) UIViewController *originalVC;

/// 开始扫描
- (void)startScan;

@end

NS_ASSUME_NONNULL_END
