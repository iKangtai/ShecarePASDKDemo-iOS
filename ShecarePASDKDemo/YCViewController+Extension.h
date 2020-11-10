//
//  YCViewController+Extension.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 16/5/12.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Extension)

///  获取当前正在显示的 ViewController
+(UIViewController *)currentViewController;
///  获取 self 的 TabBarController
+(UITabBarController *)currentTabBarController;
///  判断是否是 NavigationController 的 root
-(BOOL)isNavigationRootViewController;

@end
