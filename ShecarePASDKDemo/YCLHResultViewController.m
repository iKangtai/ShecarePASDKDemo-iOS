//
//  YCLHResultViewController.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 2017/12/26.
//  Copyright © 2017年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCLHResultViewController.h"
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import <Masonry/Masonry.h>
#import "YCLHResultView.h"
#import "UIColor+YCExtension.h"

@interface YCLHResultViewController ()

///  “比色卡” 输入页
@property (strong, nonatomic) YCLHResultView *semiQuantitativeView;
///  SDK 输出的结果
@property (nonatomic, strong) SCPaperAnalysiserResult *anaResult;
@property (strong, nonatomic) UIButton *saveButton;

@end

@implementation YCLHResultViewController

-(instancetype)initWithResult:(SCPaperAnalysiserResult *)result {
    if (self = [super init]) {
        self.anaResult = result;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.semiQuantitativeView.debugInfo = [self debugInfo:self.anaResult];
    NSString *titleStr = @"检测结果";
    self.navigationItem.title = titleStr;
    [self saveButton];
    [self setupNavigationItem];
}

- (void)setupNavigationItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_record"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(NSString *)debugInfo:(SCPaperAnalysiserResult *)result {
    NSMutableString *msg = [NSMutableString stringWithFormat:@"errorCode: %@", @(result.error.code)];
    [msg appendFormat:@"\nerrorMsg: %@", result.error.localizedDescription];
    [msg appendFormat:@"\npaperBrand: %@", @(result.paperBrand)];
#if TARGET_VERSION_LITE == 0
    [msg appendFormat:@"\nlhResult: %@", @(result.lhResult)];
#endif
    [msg appendFormat:@"\nlhRatio: %@", @(result.lhRatio)];
    [msg appendFormat:@"\nflipped: %@", result.flipped ? @"true" : @"false"];
    [msg appendFormat:@"\nlhTime: %@", result.lhTime];
    [msg appendFormat:@"\nblurExtent: %@", @(result.blurExtent)];
    [msg appendFormat:@"\ntPosition: %@", @(result.tPosition)];
    [msg appendFormat:@"\nlhTlineLeft: %@", @(result.lhTlineLeft)];
    [msg appendFormat:@"\nlhTlineRight: %@", @(result.lhTlineRight)];
    [msg appendFormat:@"\ncPosition: %@", @(result.cPosition)];
    [msg appendFormat:@"\nlhClineLeft: %@", @(result.lhClineLeft)];
    [msg appendFormat:@"\nlhClineRight: %@", @(result.lhClineRight)];
//    [msg appendFormat:@"\nNumber of success: %@", [result valueForKey:@"successNum"]];
    return msg.copy;
}

// 退出当前页面，需要 Close Session
- (void)goBack {
#warning 注意：流程结束，需要 closeSession
    [[SCPaperAnalysiser shared] closeSession:self.anaResult];
    [self.navigationController popToRootViewControllerAnimated:true];
}

// 用户保存结果，需要 Close Session
-(void)handleSaveAction {
#warning 注意：流程结束，需要 closeSession
    [[SCPaperAnalysiser shared] closeSession:self.anaResult];
    [self.navigationController popToRootViewControllerAnimated:true];
}

-(void)dealloc {
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

#pragma mark - lazy load

-(YCLHResultView *)semiQuantitativeView {
    if (_semiQuantitativeView == nil) {
        _semiQuantitativeView = [[YCLHResultView alloc] initWitResult:self.anaResult valueChangedAction:^(SCPaperAnalysiserResult *result) {
            
        }];
        [self.view insertSubview:_semiQuantitativeView atIndex:0];
        [_semiQuantitativeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _semiQuantitativeView;
}

-(UIButton *)saveButton {
    if (_saveButton == nil) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton addTarget:self action:@selector(handleSaveAction) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setBackgroundColor:[UIColor colorWithHex:0xFF7486]];
        CGFloat btnH = 34;
        _saveButton.layer.cornerRadius = btnH * 0.5;
        _saveButton.layer.masksToBounds = YES;
        [self.view addSubview:_saveButton];
        [_saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(-20);
            make.width.mas_equalTo(kScreenWidth-100);
            make.height.mas_equalTo(btnH);
        }];
    }
    return _saveButton;
}

@end
