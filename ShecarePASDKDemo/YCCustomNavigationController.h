//
//  YCCustomNavigationController.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCCustomNavigationController : UINavigationController

///  控制是否允许屏幕旋转
@property (nonatomic, assign) BOOL shouldRotate;
///  是否显示底部分割线
@property (nonatomic, assign) BOOL showBottomLineView;

@end
