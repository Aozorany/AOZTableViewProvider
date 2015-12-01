//
//  AOZTableViewDefaultConfigFileParserAddons.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <objc/runtime.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewCell.h"


NSString *getChunkFromMatchesArray(NSString *str, NSArray<NSTextCheckingResult *> *matchesArray, int index);
NSString *getChunkFromMatchesArray(NSString *str, NSArray<NSTextCheckingResult *> *matchesArray, int index) {
    if (matchesArray == nil || str == nil) {
        return nil;
    }
    if (index < 0 || index >= matchesArray.count) {
        return nil;
    }
    NSTextCheckingResult *checkingResult = matchesArray[index];
    NSString *subStr = nil;
    @try {
        subStr = [str substringWithRange:checkingResult.range];
    }
    @catch (NSException *exception) {
        subStr = nil;
    }
    return subStr;
}

BOOL stringIsInt(NSString *str);
BOOL stringIsInt(NSString *str) {
    if (str.length == 0) {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


#pragma mark -
@implementation AOZTableViewDefaultRowParser
- (AOZTVPRowCollection *)parseNewConfig:(NSString *)lineStr {
    //如果输入参数为空，返回空
    if (lineStr.length == 0) {
        return nil;
    }
    
    //把表达式分开，并解析每个参数，生成rowCollection
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"-{0,1}\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchesArray = [regEx matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
    if (matchesArray.count < 1) {
        return nil;
    }
    
    //如果第一个部分不是row开头，则返回
    NSString *prefix = getChunkFromMatchesArray(lineStr, matchesArray, 0);
    if (![prefix isEqualToString:@"row"]) {
        return nil;
    }
    
    AOZTVPRowCollection *rowCollection = [[AOZTVPRowCollection alloc] init];
    for (int index = 1; index < matchesArray.count;) {
        NSString *chunk = getChunkFromMatchesArray(lineStr, matchesArray, index);
        if ([chunk isEqualToString:@"-s"]) {
            //-s指示符，下一个参数是数据源
            if (_dataProvider == nil) {
                //没有指定数据源的查找范围，返回空
                return nil;
            }
            NSString *nextChunk = getChunkFromMatchesArray(lineStr, matchesArray, index + 1);
            if (nextChunk == nil) {
                //下一个参数为空，返回空
                return nil;
            }
            id source = nil;
            @try {
                source = [_dataProvider valueForKey:nextChunk];
            }
            @catch (NSException *exception) {
                //如果根据参数找到数据源，则返回空
                return nil;
            }
            //找到了数据源，则指定之
            rowCollection.dataConfig.source = source;
            //下一个指示符
            index += 2;
        } else if ([chunk isEqualToString:@"-c"]) {
            //-c指示符，下一个参数是单元格类型
            NSString *nextChunk = getChunkFromMatchesArray(lineStr, matchesArray, index + 1);
            if (nextChunk == nil) {
                return nil;
            }
            Class cellClass = objc_getClass([nextChunk UTF8String]);
            if (cellClass == NULL) {
                return nil;
            }
            rowCollection.dataConfig.cellClass = cellClass? cellClass: [AOZTableViewCell class];
            index += 2;
        } else if ([chunk isEqualToString:@"-n"]) {
            //-n指示符，下一参数是每一行元素个数
            NSString *nextChunk = getChunkFromMatchesArray(lineStr, matchesArray, index + 1);
            if (nextChunk == nil || !stringIsInt(nextChunk)) {
                return nil;
            }
            NSInteger elementsPerRow = [nextChunk integerValue];
            rowCollection.dataConfig.elementsPerRow = elementsPerRow > 0? elementsPerRow: 1;
            index += 2;
        } else if ([chunk isEqualToString:@"-all"]) {
            //-all指示符，所有参数都在同一行中
            rowCollection.dataConfig.elementsPerRow = -1;
            index ++;
        } else {
            index ++;
        }
    }
    //检查rowCollection的可用性，如果不可用则返回空
    if ([rowCollection rearrangeAndCheckAvaliable]) {
        return rowCollection;
    } else {
        return nil;
    }
}
@end


#pragma mark -
@implementation AOZTableViewDefaultSectionParser
- (void)addNewConfig:(NSString *)lineStr {
    
}

- (AOZTVPSectionCollection *)flushAndParse {
    return nil;
}
@end


#pragma mark -
@implementation AOZTableViewDefaultModeParser
- (void)addNewConfig:(NSString *)lineStr {
    
}

- (AOZTVPMode *)flushAndParse {
    return nil;
}
@end
