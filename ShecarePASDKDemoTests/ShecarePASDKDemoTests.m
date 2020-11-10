//
//  ShecarePASDKDemoTests.m
//  ShecarePASDKDemoTests
//
//  Created by mac on 2019/11/4.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "ShecareTestsUtilities.h"
#import "UIColor+YCExtension.h"

@interface ShecarePASDKDemoTests : XCTestCase

@end

@implementation ShecarePASDKDemoTests

- (void)setUp {
    [self setupShecareService];
}

-(void)setupShecareService {
    // 配置 Shecare SDK 参数
    SCPaperAnalysiserConfiguration *scConfig = [SCPaperAnalysiserConfiguration shared];
    // 内部测试专用 appID 和 appSecret，第三方厂商集成时需要替换为自己的
    scConfig.appID = YC_SAAS_APP_ID;
    scConfig.appSecret = YC_SAAS_APP_SECRET;
        
    scConfig.unionId = @"example@ikangtai.com";
    scConfig.extended = true;
    scConfig.pixelOfExtended = 0;
    scConfig.paperMinHeight = 20;
    scConfig.cImage = [UIImage imageNamed:@"c_line_slices"];
    scConfig.tImage = [UIImage imageNamed:@"t_line_slices"];
    
    scConfig.mainColor = [UIColor colorWithHex:0x72AAFF];
    scConfig.tagLineColor = [UIColor colorWithHex:0xFF7486];
    // 设置 SDK 环境，可以不设置。默认是 线上环境 .release
    scConfig.environment = YCSEnvironmentDebug;
    // scConfig.resultView UI 相关设置应该放在最后，且在主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        [scConfig.resultView.closeBtn setImage:[UIImage imageNamed:@"test_paper_return"] forState:UIControlStateNormal];
        [scConfig.resultView.saveBtn setImage:[UIImage imageNamed:@"test_paper_confirm"] forState:UIControlStateNormal];
        scConfig.resultView.titleLbl.text = @"拍照结果";
        scConfig.resultView.flipLbl.text = @"水平翻转";
        scConfig.resultView.commentLbl.text = @"请拖动TC线以确认TC线标注正确，水平翻转保证MAX箭头指向左边";
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testResultImageFromSnapShot {
    NSArray *imgPaths = [ShecareTestsUtilities filePathsWithFolder:@"result_images" endStr:@".jpg"];
    for (NSString *path in imgPaths) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image == nil) {
            continue;
        }
        CGPoint point1 = {0, 0};
        CGPoint point2 = {image.size.width, image.size.height};
        NSValue *val1 = [NSValue valueWithCGPoint:point1];
        NSValue *val2 = [NSValue valueWithCGPoint:point2];
        NSArray *points = @[val1, val2];
        [[SCPaperAnalysiser shared] getScanResultFromSnapShot:image points:points completion:^(SCPaperAnalysiserResult * _Nonnull result) {
            if (result.error.code == SCErrorCodeUserCanceled) {
                return;
            }
            result.source = SCImageSourceAlbum;
            result.lhTime = [NSDate date];
            NSLog(@"Result: %@", result);
        }];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:20]];
    }
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:4]];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
