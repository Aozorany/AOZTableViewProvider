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
NSString *_getChunkFromMatchesArray(NSString *str, NSArray<NSTextCheckingResult *> *matchesArray, int index);
NSString *_getChunkFromMatchesArray(NSString *str, NSArray<NSTextCheckingResult *> *matchesArray, int index) {
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
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"-{0,1}\\S+" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> *matchesArray = [regEx matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
    NSMutableArray<NSString *> *chunksArray = [[NSMutableArray alloc] init];
    for (int index = 0; index < matchesArray.count; index++) {
        NSString *chunkStr = _getChunkFromMatchesArray(lineStr, matchesArray, index);
        if (chunkStr) {
            [chunksArray addObject:chunkStr];
        }
    }
    return [NSArray arrayWithArray:chunksArray];
}

NSArray<NSArray<NSString *> *> *getLinesAndChunksArray(NSString *linesStr) {
    //特殊情况处理
    if (linesStr.length == 0) {
        return nil;
    }
    //分成多行，结果为linesArray
    NSArray<NSString *> *linesArray = [linesStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    //对linesArray的每一个元素singleLineStr，按空格分开
    NSMutableArray<NSArray<NSString *> *> *linesAndChunksArray = [[NSMutableArray alloc] init];/**< 结果集 */
    for (NSString *singleLineStr in linesArray) {
        NSArray<NSString *> *chunksArray = getChunksArray(singleLineStr);
        if (chunksArray.count > 0) {
            [linesAndChunksArray addObject:chunksArray];
        }
    }
    return [NSArray arrayWithArray:linesAndChunksArray];
}

/** 检查str是否是int */
BOOL _stringIsInt(NSString *str);
BOOL _stringIsInt(NSString *str) {
    if (str.length == 0) {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:str];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

/** 检查derivedClass是否是baseClass的派生类 */
BOOL _checkClassRelation(Class derivedClass, Class baseClass);
BOOL _checkClassRelation(Class derivedClass, Class baseClass) {
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
void _createAndLogError(Class class, NSString *localizedDescription, NSError **pError);
void _createAndLogError(Class class, NSString *localizedDescription, NSError **pError) {
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
    return [self parseNewConfig:chunksArray error:pError dataConfig:nil rowCollection:nil sectionCollection:nil];
}

- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig {
    return [self parseNewConfig:chunksArray error:pError dataConfig:presetDataConfig rowCollection:nil sectionCollection:nil];
}

- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig rowCollection:(AOZTVPRowCollection *)rowCollection {
    return [self parseNewConfig:chunksArray error:pError dataConfig:presetDataConfig rowCollection:rowCollection sectionCollection:nil];
}

- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig rowCollection:(AOZTVPRowCollection *)rowCollection sectionCollection:(AOZTVPSectionCollection *)sectionCollection {
    if (chunksArray.count == 0) {
        _createAndLogError(self.class, @"chunksArray has nothing, return nil", pError);
        return nil;
    }
    
    AOZTVPDataConfig *dataConfig = [[AOZTVPDataConfig alloc] init];
    if (presetDataConfig) {
        dataConfig.cellClass = presetDataConfig.cellClass;
        dataConfig.emptyCellClass = presetDataConfig.emptyCellClass;
        dataConfig.source = [presetDataConfig.source isKindOfClass:[NSArray class]]? [NSNull null]: presetDataConfig.source;
        dataConfig.elementsPerRow = presetDataConfig.elementsPerRow;
    }
    
    if (chunksArray.count == 1) {
        return dataConfig;
    }
    
    for (int index = 1; index < chunksArray.count;) {
        NSString *chunk = chunksArray[index];
        if ([chunk isEqualToString:@"-s"]) {//-s指示符，下一个参数是数据源
            if (index < chunksArray.count - 1) {
                if (_dataProvider) {
                    NSString *nextChunk = chunksArray[index + 1];
                    if (![nextChunk hasPrefix:@"-"]) {
                        dataConfig.sourceKey = nextChunk;
                        if (rowCollection) {
                            rowCollection.elementSourceKey = nil;
                        }
                        //尝试绑定数据
                        [dataConfig rebindSourceWithDataProvider:_dataProvider];
                    } else {
                        _createAndLogError(self.class, [NSString stringWithFormat:@"Invalid value for -s arg %@, ignore", nextChunk], NULL);
                    }
                } else {//如果_dataProvider为空，报错并忽略
                    _createAndLogError(self.class, @"_dataProvider is nil, ignore", NULL);
                }
            } else {//如果-s是最后一个，报错并忽略
                _createAndLogError(self.class, @"-s is last, ignore", NULL);
            }
            index += 2;
        } else if ([chunk isEqualToString:@"-c"] || [chunk isEqualToString:@"-ec"]) {//-c指示符，下一个参数是单元格类型
            if (index < chunksArray.count - 1) {//如果-c不是最后一个参数
                NSString *nextChunk = chunksArray[index + 1];
                Class cellClass = objc_getClass([nextChunk UTF8String]);
                if (cellClass) {
                    if ([cellClass conformsToProtocol:@protocol(AOZTableViewCell)] && _checkClassRelation(cellClass, [UITableViewCell class])) {//如果cellClass符合条件
                        if ([chunk isEqualToString:@"-c"]) {
                            dataConfig.cellClass = cellClass;
                        } else {
                            dataConfig.emptyCellClass = cellClass;
                        }
                        [_tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
                    } else {//如果cellClass不符合条件，则报错并忽略
                        _createAndLogError(self.class, [NSString stringWithFormat:@"Irregular class for %@ arg %@", chunk, nextChunk], NULL);
                    }
                } else {//如果没查找到对应的类，则报错并忽略
                    _createAndLogError(self.class, [NSString stringWithFormat:@"No class for %@ arg %@", chunk, nextChunk], NULL);
                }
            } else {//如果是最后一个参数，报错并忽略
                _createAndLogError(self.class, [NSString stringWithFormat:@"%@ is last, ignore", chunk], NULL);
            }
            index += 2;
        } else if ([chunk isEqualToString:@"-h"]) {//-c指示符，下一个参数是section header类型
            if (index < chunksArray.count - 1) {//如果-c不是最后一个参数
                NSString *nextChunk = chunksArray[index + 1];
                Class headerClass = objc_getClass([nextChunk UTF8String]);
                if (headerClass) {
                    if ([headerClass conformsToProtocol:@protocol(AOZTableViewHeaderFooterView)] && _checkClassRelation(headerClass, [UITableViewHeaderFooterView class]) && sectionCollection) {//如果cellClass符合条件
                        sectionCollection.headerClass = headerClass;
                        [_tableView registerClass:headerClass forHeaderFooterViewReuseIdentifier:NSStringFromClass(headerClass)];
                    } else {//如果cellClass不符合条件，则报错并忽略
                        _createAndLogError(self.class, [NSString stringWithFormat:@"Irregular class for -h arg %@", nextChunk], NULL);
                    }
                } else {//如果没查找到对应的类，则报错并忽略
                    _createAndLogError(self.class, [NSString stringWithFormat:@"No class for -h arg %@", nextChunk], NULL);
                }
            } else {//如果是最后一个参数，报错并忽略
                _createAndLogError(self.class, @"-c is last, ignore", NULL);
            }
            index += 2;
        } else if ([chunk isEqualToString:@"-n"]) {
            //-n指示符，下一参数是每一行元素个数
            if (index < chunksArray.count - 1) {
                //如果-n不是最后一个参数
                NSString *nextChunk = chunksArray[index + 1];
                if (_stringIsInt(nextChunk)) {//如果nextChunk是整数
                    int elementsPerRow = [nextChunk intValue];
                    if (elementsPerRow > 0) {//如果nextChunk大于0，则直接指定
                        dataConfig.elementsPerRow = elementsPerRow;
                    } else {//如果是负数，报错，并且忽略
                        _createAndLogError(self.class, [NSString stringWithFormat:@"Negative -n arg %@, ignore", nextChunk], NULL);
                    }
                } else {//如果不是合法的整数，报错，并且忽略
                    _createAndLogError(self.class, [NSString stringWithFormat:@"Irregular -n arg %@, ignore", nextChunk], NULL);
                }
            } else {
                //如果-n是最后一个参数，报错，并且忽略
                _createAndLogError(self.class, @"-n is last, ignore", NULL);
            }
            index += 2;//读取下一个指示符
        } else if ([chunk isEqualToString:@"-all"]) {//-all指示符，所有参数都在同一行中
            dataConfig.elementsPerRow = -1;
            index++;//读取下一个指示符
        } else if ([chunk isEqualToString:@"-es"]) {//-es指示符，元素参数名称
            if (index < chunksArray.count - 1) {
                NSString *nextChunk = chunksArray[index + 1];
                if (rowCollection && nextChunk.length > 0) {
                    rowCollection.elementSourceKey = nextChunk;
                    dataConfig.sourceKey = nil;
                    dataConfig.source = [NSNull null];
                }
            } else {
                //如果-n是最后一个参数，报错，并且忽略
                _createAndLogError(self.class, @"-n is last, ignore", NULL);
            }
            index += 2;//读取下一个指示符
        } else {//如果不属于以上任何一种情况，则直接读取下一个
            _createAndLogError(self.class, [NSString stringWithFormat:@"Unrecognized prefix %@", chunk], NULL);
            index++;
        }
    }
    return dataConfig;
}

@end


#pragma mark -
@implementation AOZTableViewDefaultRowParser
- (AOZTVPRowCollection *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError {
    return [self parseNewConfig:chunksArray error:pError dataConfig:nil];
}

- (AOZTVPRowCollection *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig {
    if (chunksArray.count == 0) {
        _createAndLogError(self.class, @"chunksArray has nothing, return nil", pError);
        return nil;
    }
    
    NSString *prefix = chunksArray[0];
    if (![prefix isEqualToString:@"row"]) {
        _createAndLogError(self.class, @"chunksArray is not row config, return nil", pError);
        return nil;
    }
    
    //解析dataConfig部分
    AOZTVPRowCollection *rowCollection = [[AOZTVPRowCollection alloc] init];
    AOZTableViewDefaultDataConfigParser *dataConfigParser = [[AOZTableViewDefaultDataConfigParser alloc] init];
    NSError *dataConfigParserError = nil;
    dataConfigParser.dataProvider = _dataProvider;
    dataConfigParser.tableView = _tableView;
    AOZTVPDataConfig *dataConfig = [dataConfigParser parseNewConfig:chunksArray error:&dataConfigParserError dataConfig:presetDataConfig rowCollection:rowCollection];
    if (dataConfig == nil) {
        *pError = dataConfigParserError;
        return nil;
    }
    
    rowCollection.dataConfig = dataConfig;
    
    return rowCollection;
}
@end


#pragma mark -
@implementation AOZTableViewDefaultSectionParser {
    AOZTVPSectionCollection *_sectionCollection;
}

#pragma mark public: general
- (AOZTVPSectionCollection *)parseNewConfigs:(NSArray<NSArray<NSString *> *> *)linesArray error:(NSError **)pError {
    //清除上次解析的结果
    _sectionCollection = nil;
    
    //处理特殊情况
    if (linesArray.count == 0) {
        _createAndLogError(self.class, @"linesArray is empty", pError);
        return nil;
    }
    
    //遍历每一行
    for (int index = 0; index < linesArray.count; index++) {
        NSArray<NSString *> *chunksArray = linesArray[index];/**< 单独的一行 */

        if (chunksArray.count == 0) {//如果空行，则忽略
            continue;
        }
        NSString *prefix = chunksArray[0];
        if ([prefix isEqualToString:@"section"]) {//本行是一个关于section的设置
            if (_sectionCollection == nil) {//如果_sectionCollection没初始化，则初始化
                [self _createSectionCollectionWithConfig:chunksArray];
            } else {//如果在_sectionCollection被初始化好的情况下再出现一个section，则被判断为违规
                _createAndLogError(self.class, @"Multiple section prefix in linesArray", pError);
                return nil;
            }
        } else if ([prefix isEqualToString:@"row"]) {//本行是一个关于row的设置
            if (_sectionCollection == nil) {//如果_sectionCollection没初始化，则初始化
                [self _createSectionCollectionWithConfig:nil];
            }
            //解析出rowCollection实例
            NSError *rowParserError = nil;
            AOZTableViewDefaultRowParser *rowParser = [[AOZTableViewDefaultRowParser alloc] init];
            rowParser.dataProvider = ![_sectionCollection.dataConfig.source isEqual:[NSNull null]]? _sectionCollection.dataConfig.source: _dataProvider;
            rowParser.tableView = _tableView;
            AOZTVPRowCollection *rowCollection = [rowParser parseNewConfig:chunksArray error:&rowParserError dataConfig:_sectionCollection.dataConfig];
            if (rowCollection) {
                [_sectionCollection.rowCollectionsArray addObject:rowCollection];
            }//如果rowCollection解析不成功，则忽略
        }//如果是其他prefix，则忽略
    }
    
    return _sectionCollection;
}

#pragma mark private: general
- (void)_createSectionCollectionWithConfig:(NSArray<NSString *> *)chunksArray {
    //传入空串或只传入section，结果都是默认
    _sectionCollection = [[AOZTVPSectionCollection alloc] init];
    //如果传入了更多的值，则交给AOZTableViewDefaultDataConfigParser来解析
    if (chunksArray.count > 1) {
        NSError *sectionDataParserError = nil;
        AOZTableViewDefaultDataConfigParser *dataConfigParser = [[AOZTableViewDefaultDataConfigParser alloc] init];
        dataConfigParser.dataProvider = _dataProvider;
        dataConfigParser.tableView = _tableView;
        AOZTVPDataConfig *dataConfig = [dataConfigParser parseNewConfig:chunksArray error:&sectionDataParserError dataConfig:nil rowCollection:nil sectionCollection:_sectionCollection];
        if (sectionDataParserError == nil) {
            _sectionCollection.dataConfig = dataConfig;
        }
    }
}

@end


#pragma mark -
@implementation AOZTableViewDefaultModeParser {
    AOZTVPMode *_mode;
}

- (AOZTVPMode *)parseNewConfigs:(NSArray<NSArray<NSString *> *> *)linesArray error:(NSError **)pError {
    //清除上次的结果
    _mode = nil;
    
    //处理特殊情况
    if (linesArray.count == 0) {
        _createAndLogError(self.class, @"linesArray is empty", pError);
        return nil;
    }
    
    //遍历每一行
    NSMutableArray<NSArray<NSString *> *> *singleSectionLinesArray = nil;/**< 以section和若干row所组成的配置组 */
    for (int index = 0; index < linesArray.count; index++) {
        NSArray<NSString *> *chunksArray = linesArray[index];/**< 单独的一行 */
        
        if (chunksArray.count == 0) {//如果空行，则忽略
            continue;
        }
        NSString *prefix = chunksArray[0];
        
        if ([prefix isEqualToString:@"mode"]) {//如果是mode节点
            if (_mode == nil) {//如果_mode没有被创建，则创建
                _mode = [[AOZTVPMode alloc] init];
            } else {//如果已经被创建了，则认为这些lines非法
                _createAndLogError(self.class, @"Multiple mode prefix in linesArray", pError);
                return nil;
            }
        } else if ([prefix isEqualToString:@"section"] || [prefix isEqualToString:@"row"]) {
            if (_mode == nil) {//如果_mode没有被创建，则创建
                _mode = [[AOZTVPMode alloc] init];
            }
            if ([prefix isEqualToString:@"section"]) {
                if (singleSectionLinesArray == nil) {//如果singleSectionLinesArray没被创建，则创建
                    singleSectionLinesArray = [[NSMutableArray alloc] init];
                    [singleSectionLinesArray addObject:chunksArray];
                } else {//如果已经被创建了，又来了一个section打头的，则解析singleSectionLinesArray里面已经有的内容（不包括这一行）
                    AOZTableViewDefaultSectionParser *sectionParser = [[AOZTableViewDefaultSectionParser alloc] init];
                    sectionParser.dataProvider = _dataProvider;
                    sectionParser.tableView = _tableView;
                    AOZTVPSectionCollection *sectionCollection = [sectionParser parseNewConfigs:singleSectionLinesArray error:nil];
                    if (sectionCollection) {
                        [_mode.sectionCollectionsArray addObject:sectionCollection];
                    }
                    //解析完成以后，重新把这一行压入一个新的singleSectionLinesArray
                    singleSectionLinesArray = [[NSMutableArray alloc] init];
                    [singleSectionLinesArray addObject:chunksArray];
                }
            } else if ([prefix isEqualToString:@"row"]) {
                if (singleSectionLinesArray == nil) {
                    singleSectionLinesArray = [[NSMutableArray alloc] init];
                }
                [singleSectionLinesArray addObject:chunksArray];
            }
        }
    }
    
    //解析尾端数据
    AOZTableViewDefaultSectionParser *sectionParser = [[AOZTableViewDefaultSectionParser alloc] init];
    sectionParser.dataProvider = _dataProvider;
    sectionParser.tableView = _tableView;
    AOZTVPSectionCollection *sectionCollection = [sectionParser parseNewConfigs:singleSectionLinesArray error:nil];
    if (sectionCollection) {
        [_mode.sectionCollectionsArray addObject:sectionCollection];
    }
    
    return _mode;
}
@end
