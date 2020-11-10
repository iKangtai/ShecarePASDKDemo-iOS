//
//  YCTakeLHPhotoResultView.h
//  Shecare
//
//  Created by mac on 2019/5/30.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class SCPaperAnalysiserResult;
@class YCLHPhotoResultTCView;
@interface YCTakeLHPhotoResultView : UIViewController

/** 背景蒙版 UI */
@property (nonatomic, strong) UIView *maskView;
/** Content View */
@property (nonatomic, strong) UIView *contentView;
/** 标题 UI */
@property (nonatomic, strong) UILabel *titleLbl;
/** 示例图片，为空时，示例图片默认不显示 */
@property (nonatomic, strong) UIImage *exampleImg;
/** 示例图 */
@property (nonatomic, strong) UIImageView *exampleImgView;
/** T、C 气泡视图 */
@property (nonatomic, strong) YCLHPhotoResultTCView *tcView;
/** 结果图 */
@property (nonatomic, strong) UIImageView *imgView;
/** 翻转按钮 UI */
@property (nonatomic, strong) UILabel *flipLbl;
/** 是否模糊 UI（此控件只在英文环境显示，且可以由 SaaS 后台控制是否显示） */
@property (nonatomic, strong) UILabel *feedbackLbl;
/** 提示信息 UI */
@property (nonatomic, strong) UILabel *commentLbl;
/** “确认”按钮 UI */
@property (nonatomic, strong) UIButton *saveBtn;
/** “取消”按钮 UI */
@property (nonatomic, strong) UIButton *closeBtn;

/** 分析结果 */
@property (nonatomic, strong) SCPaperAnalysiserResult *anaResult;
/** 全景图 */
@property (nonatomic, strong) UIImage *completeImage;
/** 完成回调 */
@property (nonatomic, copy) void (^completion)(SCPaperAnalysiserResult *result);

-(void)show;

@end

NS_ASSUME_NONNULL_END
