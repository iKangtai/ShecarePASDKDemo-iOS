//
//  AppDelegate.m
//  ShecarePASDKDemo
//
//  Created by mac on 2019/11/4.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "UIColor+YCExtension.h"
#import "YCCustomTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 配置 Shecare SDK 参数
    SCPaperAnalysiserConfiguration *scConfig = [SCPaperAnalysiserConfiguration shared];
    // 内部测试专用 appID 和 appSecret，第三方厂商集成时需要替换为自己的
    scConfig.appID = YC_SAAS_APP_ID;
    scConfig.appSecret = YC_SAAS_APP_SECRET;
        
    scConfig.unionId = @"test@example.com";
    scConfig.extended = true;
    scConfig.pixelOfExtended = 0;
#warning SDK 运行环境在正式上线时需要改为 YCSEnvironmentRelease
    scConfig.environment = YCSEnvironmentDebug;
    scConfig.cImage = [UIImage imageNamed:@"c_line_slices"];
    scConfig.tImage = [UIImage imageNamed:@"t_line_slices"];
    scConfig.mainColor = [UIColor colorWithHex:0xFF7486];
    // YCTakeLHPhotoResultView 的 feedbackLbl 属性受语言环境影响，只在中、英文下显示。建议设置为当前应用的语言，和当前应用保持一致。
    scConfig.language = @"en-US";
    // scConfig.resultView UI 相关设置应该放在最后，且在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        YCTakeLHPhotoResultView *reView = scConfig.resultView;
        reView.titleLbl.text = @"拍照结果";
        reView.exampleImg = [UIImage imageNamed:@"confirm_sample_pic_LH"];
        reView.exampleImgView.contentMode = UIViewContentModeScaleToFill;
        [reView.exampleImgView.bottomAnchor constraintEqualToAnchor:reView.imgView.topAnchor constant:-16].active = true;
        reView.flipLbl.text = @"水平翻转";
        [reView.flipLbl.bottomAnchor constraintEqualToAnchor:reView.commentLbl.topAnchor constant:-16].active = true;
        [reView.imgView.bottomAnchor constraintEqualToAnchor:reView.tcView.topAnchor constant:-4].active = true;
        reView.commentLbl.text = @"请拖动TC线以确认TC线标注正确，水平翻转保证MAX箭头指向左边";
        [reView.closeBtn setImage:[UIImage imageNamed:@"test_paper_return"] forState:UIControlStateNormal];
        [reView.saveBtn setImage:[UIImage imageNamed:@"test_paper_confirm"] forState:UIControlStateNormal];
        // contentView 的部分圆角的设定
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:reView.contentView.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerTopLeft) cornerRadii:CGSizeMake(15,15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = reView.contentView.bounds;
        maskLayer.path = maskPath.CGPath;
        reView.contentView.layer.mask = maskLayer;
    });
    [[SCPaperAnalysiser shared] setLoggerLevel:YCLoggerLevelAll];
    
    YCCustomTabBarController *tabC = [[YCCustomTabBarController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabC;
    [self.window makeKeyAndVisible];
    
    // 暂不兼容 iOS 13 的黑暗模式
    if (@available(iOS 13.0, *)) {
        [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    }
    
    return YES;
}

@end
