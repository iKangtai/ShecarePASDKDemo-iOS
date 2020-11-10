//
//  YCLHResultView.h
//  Shecare
//
//  Created by 罗培克 on 2017/12/28.
//  Copyright © 2017年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCPaperAnalysiserResult;
@interface YCLHResultView : UIView

@property (nonatomic, copy) NSString *debugInfo;

-(instancetype)initWitResult:(SCPaperAnalysiserResult *)result valueChangedAction:(void (^)(SCPaperAnalysiserResult *))valueChangedAction;

@end
