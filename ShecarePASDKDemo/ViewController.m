//
//  ViewController.m
//  ShecarePASDKDemo
//
//  Created by mac on 2019/11/4.
//  Copyright © 2019 ikangtai. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <SCPaperAnalysiserSDK/SCPaperAnalysiserSDK.h>
#import "YCLHResultViewController.h"
#import "YCTakeLHPhotoViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *takePictureBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    self.navigationController.navigationBar.translucent = NO;
    [self takePictureBtn];
}

-(void)handleTakePicture:(UIButton *)sender {
    YCTakeLHPhotoViewController *vc = [[YCTakeLHPhotoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - Lazy Load

-(UIButton *)takePictureBtn {
    if (_takePictureBtn == nil) {
        _takePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takePictureBtn setTitle:@"条型试纸拍照" forState:UIControlStateNormal];
        [_takePictureBtn addTarget:self action:@selector(handleTakePicture:) forControlEvents:UIControlEventTouchUpInside];
        [_takePictureBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [self.view addSubview:_takePictureBtn];
        [_takePictureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-20);
        }];
    }
    return _takePictureBtn;
}

@end
