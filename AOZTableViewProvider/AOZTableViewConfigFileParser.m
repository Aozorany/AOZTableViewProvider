//
//  AOZTableViewConfigFileParser.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/26.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import "AOZTableViewConfigFileParser.h"


@implementation AOZTableViewConfigFileParser

#pragma mark lifeCircle
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
    }
    return self;
}

#pragma mark public: general
- (NSArray *)parseFile:(NSError **)pError {
    @autoreleasepool {
        //读取，并分行
        NSString *fileContentStr = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:pError];
        NSArray *linesArray = [fileContentStr componentsSeparatedByString:@"\n"];
        if (linesArray.count == 0) {
            if (pError) {
                *pError = [NSError errorWithDomain:AOZTableViewConfigFileParserErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"文件内容为空"}];
            }
            return nil;
        }
        
        
    }
    return nil;
}

@end
