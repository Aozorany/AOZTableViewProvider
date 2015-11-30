//
//  AOZTableViewDefaultConfigFileParser.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import "AOZTableViewDefaultConfigFileParser.h"
#import "AOZTableViewDefaultConfigFileParserAddons.h"


#pragma mark -
@implementation AOZTableViewDefaultConfigFileParser {
    NSString *_filePath;
    AOZTableViewDefaultModeParser *_modeParser;
}

#pragma mark lifeCircle
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        _modeParser = [[AOZTableViewDefaultModeParser alloc] init];
    }
    return self;
}

#pragma mark public: general
- (NSArray *)parseFile:(NSError **)pError {
    @autoreleasepool {
        //读取，并分行
        NSString *fileContentStr = [NSString stringWithContentsOfFile:_filePath encoding:NSUTF8StringEncoding error:pError];
        NSArray *linesArray = [fileContentStr componentsSeparatedByString:@"\n"];
        
        //如果没有任何内容，则发起异常
        if (linesArray.count == 0) {
            if (pError) {
                *pError = [NSError errorWithDomain:AOZTableViewConfigFileParserErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"文件内容为空"}];
            }
            return nil;
        }
        
        //对每一行进行分析，并存放结果
        NSMutableArray<AOZTVPMode *> *modesArray = [[NSMutableArray alloc] init];
        for (NSString *lineStr in linesArray) {
            NSArray *chunksArray = [lineStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            NSString *configType = chunksArray[0];
            if ([configType isEqualToString:@"mode"]) {
                AOZTVPMode *mode = [_modeParser flushAndParse];
                if (mode) {
                    [modesArray addObject:mode];
                }
            } else {
                [_modeParser addNewConfig:lineStr];
            }
        }
        return [NSArray arrayWithArray:modesArray];
    }
}

@end
