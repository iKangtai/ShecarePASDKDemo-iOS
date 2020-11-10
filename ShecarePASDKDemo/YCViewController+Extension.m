//
//  YCViewController+Extension.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 16/5/12.
//  Copyright © 2016年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCViewController+Extension.h"

@implementation UIViewController (Extension)

-(BOOL)isNavigationRootViewController {
    UINavigationController *navigationC = self.navigationController;
    if (navigationC == nil) {
        return false;
    }
    UIViewController *firstVC = navigationC.viewControllers.firstObject;
    if (firstVC == self) {
        return true;
    }
    return false;
}

+ (UIViewController*) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [UIViewController findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

+ (UIViewController *)currentViewController {
    //  这种写法会造成 viewController 为 nil
//    __block UIViewController *viewController = nil;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    });
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController findBestViewController:viewController];
}

+(UITabBarController *)findTabBarController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [UIViewController findTabBarController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findTabBarController:svc.viewControllers.lastObject];
        else
            return nil;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findTabBarController:svc.topViewController];
        else
            return nil;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return (UITabBarController *)vc;
    } else {
        return nil;
    }
}

+(UITabBarController *)currentTabBarController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findTabBarController:vc];
}

@end
