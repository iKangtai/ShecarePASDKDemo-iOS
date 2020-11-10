//
//  ShecareTestsUtilities.m
//  ShecareTests
//
//  Created by MacBook Pro 2016 on 2020/6/4.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "ShecareTestsUtilities.h"

@implementation ShecareTestsUtilities


+(NSArray <NSString *>*)filePathsWithFolderPath:(NSString *)folderPath {
    NSError *error = nil;
    NSArray *filePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error];
    if (error != nil) {
        NSLog(@"Folder Path: %@", folderPath);
        NSLog(@"Error: %@", error);
        return @[];
    }
    return filePaths;
}

+(NSArray <NSString *>*)filePathsWithFolder:(NSString *)folder endStr:(NSString *)endStr {
    NSString *bundleRoot = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *folderPath = [bundleRoot stringByAppendingPathComponent:folder];
    NSArray <NSString *>*filePaths = [ShecareTestsUtilities filePathsWithFolderPath:folderPath];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self ENDSWITH '%@'", endStr]];
    NSArray <NSString *>*mockPaths = [filePaths filteredArrayUsingPredicate:fltr];
    NSMutableArray <NSString *>*resultM = [NSMutableArray arrayWithCapacity:mockPaths.count];
    for (NSString *pathI in mockPaths) {
        NSString *reI = [folderPath stringByAppendingPathComponent:pathI];
        [resultM addObject:reI];
    }
    return resultM.copy;
}

+(NSString *)getStringWithContentsOfFile:(NSString *)path {
    NSError *error = nil;
    NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"PATH: %@, \nError: %@", path, error);
        return @"";
    }
    return jsonStr;
}

@end
