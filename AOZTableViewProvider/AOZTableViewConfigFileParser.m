//
//  AOZTableViewConfigFileParser.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/26.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import "AOZTableViewConfigFileParser.h"
#import "AOZTableViewDefaultConfigFileParser.h"


@implementation AOZTableViewConfigFileParser

#pragma mark lifeCircle
- (instancetype)initWithFilePath:(NSString *)filePath {
    return [[AOZTableViewDefaultConfigFileParser alloc] initWithFilePath:filePath];
}

#pragma mark public: general
- (NSArray *)parseFile:(NSError **)pError {
    return nil;
}

@end
