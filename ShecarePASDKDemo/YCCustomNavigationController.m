//
//  YCCustomNavigationController.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCCustomNavigationController.h"

@interface YCCustomNavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation YCCustomNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.delegate = self;
        self.shouldRotate = false;
        self.navigationBar.translucent = NO;
        // 隐藏底部分割线，使用自定义 bottomLineView 实现
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        self.showBottomLineView = false;
        self.navigationBar.accessibilityIdentifier = @"currentVCNavigationBar";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    
    // 修改 tabBra 的 frame，用于修复 iPhone X push 的时候，tabbar 突然上移的问题
    if (self.tabBarController != nil) {
        CGRect frame = self.tabBarController.tabBar.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
        self.tabBarController.tabBar.frame = frame;
    }
}

-(void)setShowBottomLineView:(BOOL)showBottomLineView {
    _showBottomLineView = showBottomLineView;
    if (showBottomLineView) {
        self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
    } else {
        self.bottomLineView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - UINavigationControllerDelegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //  rootViewController 不能有手势返回
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && (navigationController.viewControllers.count > 1)) {
        navigationController.interactivePopGestureRecognizer.enabled = true;
    } else {
        navigationController.interactivePopGestureRecognizer.enabled = false;
    }
}

#pragma mark - InterfaceOrientations

- (BOOL)shouldAutorotate {
    return self.shouldRotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.shouldRotate ? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.shouldRotate ? (UIInterfaceOrientationLandscapeRight) : UIInterfaceOrientationPortrait;
}

#pragma mark - Lazy Load

-(UIView *)bottomLineView {
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, kScreenWidth, 1)];
        [self.navigationBar addSubview:_bottomLineView];
        _bottomLineView.translatesAutoresizingMaskIntoConstraints = NO;
//        UIView *superView = self.navigationBar;
//        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLineView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
//        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
//        [superView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
//        [_bottomLineView addConstraint:[NSLayoutConstraint constraintWithItem:_bottomLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:1]];
    }
    return _bottomLineView;
}

@end
