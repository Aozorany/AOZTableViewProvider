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


#pragma mark -
@implementation AOZTableViewDefaultRowParser
- (AOZTVPRowCollection *)parseNewConfig:(NSString *)lineStr {
    //如果输入参数为空，返回空
    if (lineStr.length == 0) {
        return nil;
    }
    
    //如果不是以row开头则返回空
    if (![lineStr hasPrefix:@"row "]) {
        return nil;
    }
    
    //把表达式分开，并解析每个参数，生成rowCollection
    AOZTVPRowCollection *rowCollection = [[AOZTVPRowCollection alloc] init];
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"-{0,1}\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchesArray = [regEx matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
    if (matchesArray.count <= 1) {
        return nil;
    }
    for (int index = 1; index < matchesArray.count;) {
        NSTextCheckingResult *checkingResult = matchesArray[index];
        if (checkingResult.range.location == NSNotFound
            || checkingResult.range.length == 0) {
            continue;
        }
        NSString *chunk = [lineStr substringWithRange:checkingResult.range];
        if ([chunk isEqualToString:@"-s"]) {
            if (index == matchesArray.count - 1) {
                return nil;
            }
            NSTextCheckingResult *nextCheckingResult = matchesArray[index + 1];
            if (nextCheckingResult.range.location == NSNotFound
                || nextCheckingResult.range.length == 0) {
                continue;
            }
            NSString *nextChunk = [lineStr substringWithRange:nextCheckingResult.range];
            if (_dataProvider == nil) {
                return nil;
            }
            id source = nil;
            @try {
                source = [_dataProvider valueForKey:nextChunk];
            }
            @catch (NSException *exception) {
                NSLog(@"%@ not found", nextChunk);
            }
            rowCollection.dataConfig.source = source;
            index += 2;
        } else if ([chunk isEqualToString:@"-c"]) {
            if (index == matchesArray.count - 1) {
                return nil;
            }
            NSTextCheckingResult *nextCheckingResult = matchesArray[index + 1];
            if (nextCheckingResult.range.location == NSNotFound
                || nextCheckingResult.range.length == 0) {
                continue;
            }
            NSString *nextChunk = [lineStr substringWithRange:nextCheckingResult.range];
            Class cellClass = objc_getClass([nextChunk UTF8String]);
            rowCollection.dataConfig.cellClass = cellClass? cellClass: [AOZTableViewCell class];
            index += 2;
        } else if ([chunk isEqualToString:@"-n"]) {
            if (index == matchesArray.count - 1) {
                return nil;
            }
            NSTextCheckingResult *nextCheckingResult = matchesArray[index + 1];
            if (nextCheckingResult.range.location == NSNotFound
                || nextCheckingResult.range.length == 0) {
                continue;
            }
            NSString *nextChunk = [lineStr substringWithRange:nextCheckingResult.range];
            NSInteger elementsPerRow = [nextChunk integerValue];
            rowCollection.dataConfig.elementsPerRow = elementsPerRow > 0? elementsPerRow: 1;
            index += 2;
        } else if ([chunk isEqualToString:@"-all"]) {
            rowCollection.dataConfig.elementsPerRow = -1;
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
