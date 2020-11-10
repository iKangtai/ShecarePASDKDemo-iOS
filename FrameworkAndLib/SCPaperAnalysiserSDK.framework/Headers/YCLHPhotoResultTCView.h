//
//  YCLHPhotoResultTCView.h
//  Shecare
//
//  Created by mac on 2019/5/31.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCLHPhotoResultTCView : UIView

///  用户设置的 T 线位置，> 0 认为用户修改过
@property (nonatomic, assign) CGFloat newTLoc;
///  用户设置的 C 线位置，> 0 认为用户修改过
@property (nonatomic, assign) CGFloat newCLoc;

/// 设置 T/C 原始值。一个生命周期里只应该调用一次
-(void)setTLoc:(CGFloat)tLoc cLoc:(CGFloat)cLoc completion:(void (^)(BOOL finished))completion;
/// 更新 T/C 指示位置。不更新 tLoc 和 cLoc 的数值。因为判断 T/C 是否改变，是通过 frame 和当前 数值 对比得到的
-(void)updateTFrame:(CGFloat)tLoc cFrame:(CGFloat)cLoc completion:(void (^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
