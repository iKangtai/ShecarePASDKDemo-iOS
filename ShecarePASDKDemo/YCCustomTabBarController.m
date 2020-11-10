//
//  YCCustomTabBarController.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCCustomTabBarController.h"
#import "ViewController.h"
#import "YCCustomNavigationController.h"


@interface YCCustomTabBarController () <UITabBarControllerDelegate>

@end

@implementation YCCustomTabBarController

-(instancetype)init {
    if (self = [super init]) {
        [self prepareUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    //  修复 iOS 12.1 从隐藏 Tabbar 的二级页面返回时， Tabbar 会 “跳动” 的问题
    self.tabBar.translucent = false;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self prepareUI];
//    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)prepareUI {
    ViewController *vc = [[ViewController alloc] init];
    YCCustomNavigationController *paperNav = [[YCCustomNavigationController alloc] initWithRootViewController:vc];
    paperNav.showBottomLineView = true;
    paperNav.tabBarItem = [self tabBarItemWithDictionary:self.itemDicts[@"homepage"]];
    paperNav.tabBarItem.accessibilityIdentifier = @"tab_paper";
    
    self.viewControllers = @[
        paperNav
    ];
    self.currentTabIndex = 0;
}

-(NSDictionary *)itemDicts {
    return @{
        @"homepage": @{@"imgName": @"homepage", @"title": @"首页"}
    };
}

- (UITabBarItem *)tabBarItemWithDictionary:(NSDictionary *)dict {
    NSString *normalImageName = [NSString stringWithFormat:@"tabbar_button_%@_normal", dict[@"imgName"]];
    UIImage *normalgeImage = [UIImage imageNamed:normalImageName];
    normalgeImage = [normalgeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    NSString *selectedImageName = [NSString stringWithFormat:@"tabbar_button_%@_selected", dict[@"imgName"]];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *result = [[UITabBarItem alloc] initWithTitle:dict[@"title"] image:normalgeImage selectedImage:selectedImage];
    [result setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightRegular]} forState:UIControlStateNormal];
    [result setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0xFF green:0x74 blue:0x86 alpha:1.0], NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightRegular]} forState:UIControlStateSelected];
    result.accessibilityIdentifier = [NSString stringWithFormat:@"tabbar_%@", dict[@"imgName"]];
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

-(void)dealloc {
}

#pragma mark - InterfaceOrientations

- (BOOL)shouldAutorotate {
    return false;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.currentTabIndex = tabBarController.selectedIndex;
}

@end
