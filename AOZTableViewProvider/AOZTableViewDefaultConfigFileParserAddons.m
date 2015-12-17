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


/** 从一个正则表达式匹配结果中取得第index个字符串 */
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

NSArray<NSString *> *getChunksArray(NSString *lineStr) {
    if (lineStr.length == 0) {
        return nil;
    }
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"-{0,1}\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchesArray = [regEx matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
    NSMutableArray<NSString *> *chunksArray = [NSMutableArray array];
    for (int index = 0; index < matchesArray.count; index++) {
        NSString *chunkStr = getChunkFromMatchesArray(lineStr, matchesArray, index);
        if (chunkStr) {
            [chunksArray addObject:chunkStr];
        }
    }
    return chunksArray;
}

/** 检查str是否是int */
BOOL stringIsInt(NSString *str);
BOOL stringIsInt(NSString *str) {
    if (str.length == 0) {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

/** 检查derivedClass是否是baseClass的派生类 */
BOOL checkClassRelation(Class derivedClass, Class baseClass);
BOOL checkClassRelation(Class derivedClass, Class baseClass) {
    if (derivedClass == NULL || baseClass == NULL) {
        return NO;
    }
    if ([NSStringFromClass(baseClass) isEqualToString:NSStringFromClass([NSObject class])]) {
        return YES;
    }
    if ([NSStringFromClass(derivedClass) isEqualToString:NSStringFromClass([NSObject class])]) {
        return NO;
    }
    Class currentClass = derivedClass;
    while (YES) {
        if ([NSStringFromClass(currentClass) isEqualToString:NSStringFromClass(baseClass)]) {
            return YES;
        }
        currentClass = class_getSuperclass(currentClass);
        if (currentClass == NULL || [NSStringFromClass(currentClass) isEqualToString:NSStringFromClass([NSObject class])]) {
            return NO;
        }
    }
    return NO;
}

/** 根据传入的class和错误原因创建错误，把这个错误保存在pError中，如果传入的pError为nil，则不创建这个错误 */
void createAndLogError(Class class, NSString *localizedDescription, NSError **pError);
void createAndLogError(Class class, NSString *localizedDescription, NSError **pError) {
    if (localizedDescription.length == 0) {
        localizedDescription = @"Unknown error";
    }
    
#if DEBUG
    NSLog(@"%@", localizedDescription);
#endif
    
    if (pError && class) {
        NSString *className = NSStringFromClass(class);
        NSString *errorDomain = [NSString stringWithFormat:@"%@Domain", className];
        *pError = [NSError errorWithDomain:errorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: localizedDescription}];
    }
}


#pragma mark -
NSString * const AOZTableViewDefaultDataConfigParserDomain = @"AOZTableViewDefaultDataConfigParserDomain";
@implementation AOZTableViewDefaultDataConfigParser

#pragma mark public: general
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError {
    if (chunksArray.count == 0) {
        createAndLogError(self.class, @"chunksArray has nothing, return nil", pError);
        return nil;
    }
    
    AOZTVPDataConfig *dataConfig = [[AOZTVPDataConfig alloc] init];
    if (chunksArray.count == 1) {
        return dataConfig;
    }
    
    for (int index = 1; index < chunksArray.count;) {
        NSString *chunk = chunksArray[index];
        if ([chunk isEqualToString:@"-s"]) {//-s指示符，下一个参数是数据源
            if (index < chunksArray.count - 1) {
                if (_dataProvider) {
                    NSString *nextChunk = chunksArray[index + 1];
                    @try {
                        dataConfig.source = [_dataProvider valueForKey:nextChunk];
                    }
                    @catch (NSException *exception) {
                        //如果根据参数找到数据源，则返回空
                        createAndLogError(self.class, [NSString stringWithFormat:@"No value for -s arg %@, ignore", nextChunk], NULL);
                    }
                } else {//如果_dataProvider为空，报错并忽略
                    createAndLogError(self.class, @"_dataProvider is nil, ignore", NULL);
                }
            } else {//如果-s是最后一个，报错并忽略
                createAndLogError(self.class, @"-s is last, ignore", NULL);
            }
            index += 2;
        } else if ([chunk isEqualToString:@"-c"]) {//-c指示符，下一个参数是单元格类型
            if (index < chunksArray.count - 1) {//如果-c不是最后一个参数
                NSString *nextChunk = chunksArray[index + 1];
                Class cellClass = objc_getClass([nextChunk UTF8String]);
                if (cellClass) {
                    if (checkClassRelation(cellClass, [AOZTableViewCell class])) {//如果cellClass符合条件
                        dataConfig.cellClass = cellClass;
                    } else {//如果cellClass不符合条件，则报错并忽略
                        createAndLogError(self.class, [NSString stringWithFormat:@"Irregular class for -c arg %@", nextChunk], NULL);
                    }
                } else {//如果没查找到对应的类，则报错并忽略
                    createAndLogError(self.class, [NSString stringWithFormat:@"No class for -c arg %@", nextChunk], NULL);
                }
            } else {//如果是最后一个参数，报错并忽略
                createAndLogError(self.class, @"-c is last, ignore", NULL);
            }
            index += 2;
        } else if ([chunk isEqualToString:@"-n"]) {
            //-n指示符，下一参数是每一行元素个数
            if (index < chunksArray.count - 1) {
                //如果-n不是最后一个参数
                NSString *nextChunk = chunksArray[index + 1];
                if (stringIsInt(nextChunk)) {//如果nextChunk是整数
                    int elementsPerRow = [nextChunk intValue];
                    if (elementsPerRow > 0) {//如果nextChunk大于0，则直接指定
                        dataConfig.elementsPerRow = elementsPerRow;
                    } else {//如果是负数，报错，并且忽略
                        createAndLogError(self.class, [NSString stringWithFormat:@"Negative -n arg %@, ignore", nextChunk], NULL);
                    }
                } else {//如果不是合法的整数，报错，并且忽略
                    createAndLogError(self.class, [NSString stringWithFormat:@"Irregular -n arg %@, ignore", nextChunk], NULL);
                }
            } else {
                //如果-n是最后一个参数，报错，并且忽略
                createAndLogError(self.class, @"-n is last, ignore", NULL);
            }
            index += 2;//读取下一个指示符
        } else if ([chunk isEqualToString:@"-all"]) {//-all指示符，所有参数都在同一行中
            dataConfig.elementsPerRow = -1;
            index++;//读取下一个指示符
        } else {//如果不属于以上任何一种情况，则直接读取下一个
            createAndLogError(self.class, [NSString stringWithFormat:@"Unrecognized prefix %@", chunk], NULL);
            index++;
        }
    }
    return dataConfig;
}

@end


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
    
    //如果第一个部分不是row，则返回
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
                //如果没查找到对应的类，则非法
                return nil;
            }
            if (!checkClassRelation(cellClass, [AOZTableViewCell class])) {
                //如果不是AOZTableViewCell的派生类，则非法
                return nil;
            }
            rowCollection.dataConfig.cellClass = cellClass;
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
@implementation AOZTableViewDefaultSectionParser {
    AOZTVPSectionCollection *_sectionCollection;
}

- (AOZTVPSectionCollection *)parseNewConfigs:(NSArray<NSString *> *)linesArray {
    if (linesArray.count == 0) {
        return nil;
    }
    
    AOZTVPSectionCollection *sectionCollection = nil;
    for (NSString *lineStr in linesArray) {
        //对每一行，把表达式分开
        NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"-{0,1}\\w+" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray<NSTextCheckingResult *> *matchesArray = [regEx matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
        
        //如果一行里面没有内容，则继续下一行
        if (matchesArray.count < 1) {
            continue;
        }
        
        //如果第一个部分不是row，则返回
        NSString *prefix = getChunkFromMatchesArray(lineStr, matchesArray, 0);
        if ([prefix isEqualToString:@"section"]) {
            //如果是以section开头
            if (sectionCollection == nil) {
                sectionCollection = [[AOZTVPSectionCollection alloc] init];
            }
            //*********
            
        } else if ([prefix isEqualToString:@"row"]) {
            //如果是以row开头，则交给row解析器
            if (sectionCollection == nil) {
                sectionCollection = [[AOZTVPSectionCollection alloc] init];
            }
            AOZTableViewDefaultRowParser *rowParser = [[AOZTableViewDefaultRowParser alloc] init];
            AOZTVPRowCollection *rowCollection = [rowParser parseNewConfig:lineStr];
            if (rowCollection) {
                [sectionCollection.rowCollectionsArray addObject:rowCollection];
            }
        } else {
            //其他情况，继续下一行
            continue;
        }
    }
    return sectionCollection;
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
