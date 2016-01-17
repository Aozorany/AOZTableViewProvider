//
//  AOZTableViewProvider.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import <objc/runtime.h>
#import "AOZTableViewProvider.h"
#import "AOZTableViewProviderUtils.h"
#import "AOZTableViewConfigFileParser.h"
#import "AOZTableViewCell.h"


#pragma mark -
id collectionForIndex(id parentCollection, NSInteger index);
id collectionForIndex(id parentCollection, NSInteger index) {
    if ((![parentCollection isKindOfClass:[AOZTVPSectionCollection class]] && ![parentCollection isKindOfClass:[AOZTVPMode class]])
        || index < 0) {//如果parentCollection不是sectionCollection，也不是mode，而且index不合法，则返回空
        return nil;
    }
    
    if ([parentCollection isKindOfClass:[AOZTVPSectionCollection class]]) {
        AOZTVPSectionCollection *sectionCollection = (AOZTVPSectionCollection *) parentCollection;
        if (sectionCollection.rowCollectionsArray.count == 0) {
            return nil;
        }
        for (AOZTVPRowCollection *rowCollection in sectionCollection.rowCollectionsArray) {
            if (NSLocationInRange(index, rowCollection.rowRange)) {
                return rowCollection;
            }
        }
    } else if ([parentCollection isKindOfClass:[AOZTVPMode class]]) {
        AOZTVPMode *mode = (AOZTVPMode *) parentCollection;
        if (mode.sectionCollectionsArray.count == 0) {
            return nil;
        }
        for (AOZTVPSectionCollection *sectionCollection in mode.sectionCollectionsArray) {
            if (NSLocationInRange(index, sectionCollection.sectionRange)) {
                return sectionCollection;
            }//end for index in range check
        }//end for
    }//end for mode and section
    
    //其他情况：找不到，或者又不是mode也不是section，则直接返回空
    return nil;
}


#pragma mark -
@implementation AOZTableViewProvider {
    NSMutableArray<AOZTVPMode *> *_modesArray;
    NSMutableDictionary *_currentConfigDictionary;
}

#pragma mark lifeCircle
- (instancetype)init {
    self = [super init];
    if (self) {
        _modesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithFileName:(NSString *)fileName dataProvider:(id)dataProvider tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        _modesArray = [[NSMutableArray alloc] init];
        self.dataProvider = dataProvider;
        self.configBundleFileName = fileName;
        [self connectToTableView:tableView];
    }
    return self;
}

#pragma mark delegate: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *lastSectionCollection = currentMode.sectionCollectionsArray.lastObject;
    sectionCount = lastSectionCollection.sectionRange.location + lastSectionCollection.sectionRange.length;
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, section);
    AOZTVPSectionCollection *newSectionCollection = nil;
    if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]] && sectionCollection.dataConfig.elementsPerRow == 1) {
        newSectionCollection = [sectionCollection copy];
        [newSectionCollection reloadRowsWithSectionElement:((NSArray *) newSectionCollection.dataConfig.source)[section - newSectionCollection.sectionRange.location]];
    } else {
        newSectionCollection = sectionCollection;
    }
    AOZTVPRowCollection *lastRowCollection = newSectionCollection.rowCollectionsArray.lastObject;
    rowCount = lastRowCollection.rowRange.location + lastRowCollection.rowRange.length;
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, indexPath.section);
    AOZTVPSectionCollection *newSectionCollection = nil;
    if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]] && sectionCollection.dataConfig.elementsPerRow == 1) {
        newSectionCollection = [sectionCollection copy];
        [newSectionCollection reloadRowsWithSectionElement:((NSArray *) newSectionCollection.dataConfig.source)[indexPath.section - newSectionCollection.sectionRange.location]];
    } else {
        newSectionCollection = sectionCollection;
    }
    AOZTVPRowCollection *rowCollection = collectionForIndex(newSectionCollection, indexPath.row);
    
    id contents = nil;
    if (![rowCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在row里面设置了数据源，则使用row的设置
        if ([rowCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (rowCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = rowCollection.dataConfig.source;
            } else if (rowCollection.dataConfig.elementsPerRow == 0 || rowCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) rowCollection.dataConfig.source)[indexPath.row - rowCollection.rowRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.row - rowCollection.rowRange.location) * rowCollection.dataConfig.elementsPerRow, rowCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) rowCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) rowCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) rowCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = rowCollection.dataConfig.source;
        }
    } else if (![sectionCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在section里面设置了数据源，则使用section的设置
        if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (sectionCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = sectionCollection.dataConfig.source;
            } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) sectionCollection.dataConfig.source)[indexPath.section - sectionCollection.sectionRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = sectionCollection.dataConfig.source;
        }
    }
    
    AOZTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(rowCollection.dataConfig.cellClass)];
    [cell setContents:contents];
    
    if ([_delegate respondsToSelector:@selector(tableViewProvider:cellForRowAtIndexPath:contents:cell:)]) {
        [_delegate tableViewProvider:self cellForRowAtIndexPath:indexPath contents:contents cell:cell];
    }
    
    return cell;
}

#pragma mark delegate: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, indexPath.section);
    AOZTVPSectionCollection *newSectionCollection = nil;
    if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]] && sectionCollection.dataConfig.elementsPerRow == 1) {
        newSectionCollection = [sectionCollection copy];
        [newSectionCollection reloadRowsWithSectionElement:((NSArray *) newSectionCollection.dataConfig.source)[indexPath.section - newSectionCollection.sectionRange.location]];
    } else {
        newSectionCollection = sectionCollection;
    }
    AOZTVPRowCollection *rowCollection = collectionForIndex(newSectionCollection, indexPath.row);
    
    id contents = nil;
    if (![rowCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在row里面设置了数据源，则使用row的设置
        if ([rowCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (rowCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = rowCollection.dataConfig.source;
            } else if (rowCollection.dataConfig.elementsPerRow == 0 || rowCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) rowCollection.dataConfig.source)[indexPath.row - rowCollection.rowRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.row - rowCollection.rowRange.location) * rowCollection.dataConfig.elementsPerRow, rowCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) rowCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) rowCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) rowCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = rowCollection.dataConfig.source;
        }
    } else if (![sectionCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在section里面设置了数据源，则使用section的设置
        if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (sectionCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = sectionCollection.dataConfig.source;
            } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) sectionCollection.dataConfig.source)[indexPath.section - sectionCollection.sectionRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = sectionCollection.dataConfig.source;
        }
    }

    NSMethodSignature *signiture = [rowCollection.dataConfig.cellClass methodSignatureForSelector:@selector(heightForCell:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signiture];
    [invocation setTarget:rowCollection.dataConfig.cellClass];
    [invocation setSelector:@selector(heightForCell:)];
    if (rowCollection.dataConfig.source) {
        [invocation setArgument:(__bridge void * _Nonnull)(rowCollection.dataConfig.source) atIndex:2];
    }
    CGFloat height = 0;
    [invocation retainArguments];
    [invocation invoke];
    [invocation getReturnValue:&height];

    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(willDisplayCell)]) {
        [((AOZTableViewCell *) cell) willDisplayCell];
    }
    if ([_delegate respondsToSelector:@selector(tableViewProvider:willDisplayCell:forRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:didSelectRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark delegate: UITableViewDelegate section headers and footers
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:viewForHeaderInSection:)]) {
        return [_delegate tableViewProvider:self viewForHeaderInSection:section];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:viewForFooterInSection:)]) {
        return [_delegate tableViewProvider:self viewForFooterInSection:section];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:heightForHeaderInSection:)]) {
        return [_delegate tableViewProvider:self heightForHeaderInSection:section];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:heightForFooterInSection:)]) {
        return [_delegate tableViewProvider:self heightForFooterInSection:section];
    }
    return 0;
}

#pragma mark private: general
- (AOZTVPMode *)currentMode {
    if (_mode < 0 || _mode >= _modesArray.count) {
        return nil;
    }
    return _modesArray[_mode];
}

#pragma mark public: general
- (BOOL)parseConfigFile:(NSError **)pError {
    if (_configBundleFileName.length == 0) {
        return NO;
    }
    
    //检查配置文件存在性
    NSString *configFileName = [_configBundleFileName stringByDeletingPathExtension];
    NSString *configFileExtention = [_configBundleFileName pathExtension];
    if (configFileExtention.length == 0) {
        configFileExtention = @"tableViewConfig";
    }
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:configFileName ofType:configFileExtention];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]) {
        if (pError) {
            *pError = [NSError errorWithDomain:AOZTableViewProviderErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"配置文件不存在"}];
        }
        return NO;
    }
    
    //解析配置文件
    NSError *configParserError = nil;
    AOZTableViewConfigFileParser *parser = [[AOZTableViewConfigFileParser alloc] initWithFilePath:configFilePath];
    parser.dataProvider = _dataProvider;
    parser.tableView = _tableView;
    NSArray *newModesArray = [parser parseFile:&configParserError];
    
    if (configParserError) {
        if (pError) {
            *pError = configParserError;
        }
        return NO;
    }
    
    [_modesArray removeAllObjects];
    [_modesArray addObjectsFromArray:newModesArray];
    
    [_tableView registerClass:[AOZTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AOZTableViewCell class])];
    
    return YES;
}

- (void)connectToTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)reloadTableView {
    [_tableView reloadData];
}

- (void)reloadData {
    AOZTVPMode *currentMode = [self currentMode];
    [currentMode reloadSections];
}

- (void)reloadDataAndTableView {
    [self reloadData];
    [self reloadTableView];
}

@end
