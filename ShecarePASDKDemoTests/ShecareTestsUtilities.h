//
//  ShecareTestsUtilities.h
//  ShecareTests
//
//  Created by MacBook Pro 2016 on 2020/6/4.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShecareTestsUtilities : NSObject

+(NSArray <NSString *>*)filePathsWithFolderPath:(NSString *)folderPath;

+(NSArray <NSString *>*)filePathsWithFolder:(NSString *)folder endStr:(NSString *)endStr;

+(NSString *)getStringWithContentsOfFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
