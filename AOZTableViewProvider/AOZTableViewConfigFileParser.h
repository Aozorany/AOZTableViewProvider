//
//  AOZTableViewConfigFileParser.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/26.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AOZTableViewProviderUtils.h"


#ifndef AOZTableViewConfigFileParserErrorDomain
    #define AOZTableViewConfigFileParserErrorDomain @"AOZTableViewConfigFileParserError"
#endif


/** 配置文件解析器 */
@interface AOZTableViewConfigFileParser : NSObject
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) UITableView *tableView;
- (instancetype)initWithFilePath:(NSString *)filePath;
- (NSArray<AOZTVPMode *> *)parseFile:(NSError **)pError;
@end
