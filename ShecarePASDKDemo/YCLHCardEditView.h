//
//  YCLHCardEditView.h
//  Shecare
//
//  Created by mac on 2019/6/1.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCLHCardEditView : UIView


@property (assign, nonatomic) NSInteger result;

@property (nonatomic, copy) void (^resultDidChange)(NSInteger result);

@end

NS_ASSUME_NONNULL_END
