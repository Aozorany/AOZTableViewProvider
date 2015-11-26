//
//  AOZTableViewConfigFileParser.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/26.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <Foundation/Foundation.h>


#ifndef AOZTableViewConfigFileParserErrorDomain
    #define AOZTableViewConfigFileParserErrorDomain @"AOZTableViewConfigFileParserError"
#endif


/** 配置文件解析器 */
@interface AOZTableViewConfigFileParser : NSObject
@property (nonatomic, readonly) NSString *filePath;
- (instancetype)initWithFilePath:(NSString *)filePath;
- (NSArray *)parseFile:(NSError **)pError;
@end
