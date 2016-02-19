//
//  AOZTableViewProviderUtils.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <objc/runtime.h>
#import "AOZTableViewProviderUtils.h"
#import "AOZTableViewCell.h"


@implementation AOZTVPDataConfig
- (instancetype)init {
    self = [super init];
    if (self) {
        _cellClass = [AOZTableViewCell class];
        _emptyCellClass = nil;
        _elementsPerRow = 1;
        _source = [NSNull null];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AOZTVPDataConfig class]]) {
        return NO;
    }
    AOZTVPDataConfig *anotherDataConfig = (AOZTVPDataConfig *)object;
    return _elementsPerRow == anotherDataConfig.elementsPerRow
           && [NSStringFromClass(_cellClass) isEqualToString:NSStringFromClass(anotherDataConfig.cellClass)]
           && ((_emptyCellClass == NULL && anotherDataConfig.emptyCellClass == NULL) || [NSStringFromClass(_emptyCellClass) isEqualToString:NSStringFromClass(anotherDataConfig.emptyCellClass)])
           && ((_source == nil && anotherDataConfig.source == nil) || [_source isEqual:anotherDataConfig.source]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AOZTVPDataConfig: _elementsPerRow: %zd, _cellClass: %@, _emptyCellClass: %@, _source: %@>",
            _elementsPerRow, NSStringFromClass(_cellClass), NSStringFromClass(_emptyCellClass), _source];
}
@end


@implementation AOZTVPRowCollection
- (instancetype)init {
    self = [super init];
    if (self) {
        _dataConfig = [[AOZTVPDataConfig alloc] init];
        _rowRange = NSMakeRange(0, 0);
    }
    return self;
}

- (instancetype)initWithDataConfig:(AOZTVPDataConfig *)dataConfig {
    self = [super init];
    if (self) {
        _dataConfig = [[AOZTVPDataConfig alloc] init];
        if (dataConfig) {
            _dataConfig.cellClass = dataConfig.cellClass;
            _dataConfig.emptyCellClass = dataConfig.emptyCellClass;
            _dataConfig.elementsPerRow = dataConfig.elementsPerRow;
            _dataConfig.source = [dataConfig.source isKindOfClass:[NSArray class]]? [NSNull null]: dataConfig.source;
        }
        _rowRange = NSMakeRange(0, 0);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AOZTVPRowCollection class]]) {
        return NO;
    }
    AOZTVPRowCollection *anotherRowCollection = (AOZTVPRowCollection *)object;
    return NSEqualRanges(_rowRange, anotherRowCollection.rowRange)
        && [_dataConfig isEqual:anotherRowCollection.dataConfig];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AOZTVPRowCollection: _rowRange: %zd - %zd, _dataConfig: %@>",
            _rowRange.location, _rowRange.length, _dataConfig];
}
@end


@implementation AOZTVPSectionCollection
- (instancetype)init {
    self = [super init];
    if (self) {
        _rowCollectionsArray = [[NSMutableArray alloc] init];
        _dataConfig = [[AOZTVPDataConfig alloc] init];
        _sectionRange = NSMakeRange(0, 0);
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AOZTVPSectionCollection *newSectionCollection = [[[self class] allocWithZone:zone] init];
    if (newSectionCollection) {
        newSectionCollection.dataConfig.elementsPerRow = _dataConfig.elementsPerRow;
        newSectionCollection.dataConfig.source = _dataConfig.source;
        newSectionCollection.dataConfig.cellClass = _dataConfig.cellClass;
        newSectionCollection.dataConfig.emptyCellClass = _dataConfig.emptyCellClass;
        newSectionCollection.sectionRange = _sectionRange;
        newSectionCollection.headerClass = _headerClass;
        for (AOZTVPRowCollection *rowCollection in _rowCollectionsArray) {
            AOZTVPRowCollection *newRowCollection = [[AOZTVPRowCollection alloc] init];
            newRowCollection.dataConfig.elementsPerRow = rowCollection.dataConfig.elementsPerRow;
            newRowCollection.dataConfig.source = rowCollection.dataConfig.source;
            newRowCollection.dataConfig.cellClass = rowCollection.dataConfig.cellClass;
            newRowCollection.dataConfig.emptyCellClass = rowCollection.dataConfig.emptyCellClass;
            newRowCollection.rowRange = rowCollection.rowRange;
            newRowCollection.elementSource = rowCollection.elementSource;
            [newSectionCollection.rowCollectionsArray addObject:newRowCollection];
        }
    }
    return newSectionCollection;
}

- (void)reloadRows {
    [self reloadRowsWithSectionElement:nil];
}

/** 根据sectionElement重新确认row的range，sectionElement为分配给每个section的数据源元素，一般sectionCollection的source是array的时候才会用到这个方法 */
- (void)reloadRowsWithSectionElement:(id)sectionElement {
    NSInteger currentLocation = 0;
    if (_rowCollectionsArray.count == 0) {
        AOZTVPRowCollection *defaultRowCollection = [[AOZTVPRowCollection alloc] initWithDataConfig:_dataConfig];
        [_rowCollectionsArray addObject:defaultRowCollection];
    }
    for (AOZTVPRowCollection *rowCollection in _rowCollectionsArray) {
        AOZTVPDataConfig *rowDataConfig = rowCollection.dataConfig;
        if ([rowDataConfig.source isKindOfClass:[NSArray class]]) {
            //如果row自身的source就是array
            if ([rowDataConfig.source count] > 0) {
                //如果数组里面有内容
                if (rowDataConfig.elementsPerRow <= 0) {
                    rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                } else {
                    rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) rowDataConfig.source).count / rowDataConfig.elementsPerRow));
                }
            } else if (rowDataConfig.emptyCellClass) {
                //如果数组里面没有内容，但是指定了emptyCellClass
                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
            } else {
                //如果数组里面没有内容，而且也没指定emptyCellClass
                rowCollection.rowRange = NSMakeRange(currentLocation, 0);
            }
        } else if ([rowDataConfig.source isEqual:[NSNull null]] && sectionElement) {
            //如果row自身的source没有被指定，但是指定了sectionElement，那么row的数据源直接来自于sectionElement
            if ([sectionElement isKindOfClass:[NSArray class]]) {
                //如果sectionElement本身就是一个array
                if ([sectionElement count] > 0) {
                    //如果数组里面有数据
                    if (rowDataConfig.elementsPerRow <= 0) {
                        //如果所有的数据全在同一行
                        rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                    } else {
                        //如果需要分行
                        rowCollection.dataConfig.source = sectionElement;
                        rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) sectionElement).count / rowDataConfig.elementsPerRow));
                    }
                } else if (rowCollection.dataConfig.emptyCellClass) {
                    //如果数组里面没有数据，但是指定了emptyCellClass
                    rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                } else {
                    //如果数组里面没有数据，而且也没指定emptyCellClass
                    rowCollection.rowRange = NSMakeRange(currentLocation, 0);
                }
            } else if (rowCollection.elementSource.length > 0) {
                //如果指定了row的elementSource，则尝试从sectionElement里面读取之
                @try {
                    id elementSourceObj = [sectionElement valueForKey:rowCollection.elementSource];
                    rowCollection.dataConfig.source = elementSourceObj;
                    if ([elementSourceObj isKindOfClass:[NSArray class]]) {
                        //如果elementSourceObj本身是一个数组
                        if ([elementSourceObj count] > 0) {
                            //如果数组里面有内容
                            if (rowDataConfig.elementsPerRow <= 0) {
                                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                            } else {
                                rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) elementSourceObj).count / rowDataConfig.elementsPerRow));
                            }
                        } else if (rowCollection.dataConfig.emptyCellClass) {
                            //如果数组里面没有内容，但指定了emptyCellClass
                            rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                        } else {
                            //如果数组里面没有内容，而且也没指定emptyCellClass
                            rowCollection.rowRange = NSMakeRange(currentLocation, 0);
                        }
                    } else if (elementSourceObj) {
                        //如果elementSourceObj非空
                        rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                    } else if (rowCollection.dataConfig.emptyCellClass) {
                        //如果elementSourceObj为空，但指定了emptyCellClass
                        rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                        //如果elementSourceObj为空，而且也没指定emptyCellClass
                    } else {
                        rowCollection.rowRange = NSMakeRange(currentLocation, 0);
                    }
                }
                @catch (NSException *exception) {
                    rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                }
            } else {
                //如果sectionElement本身属于其他样式
                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
            }
        } else if (rowDataConfig.source) {
            //如果rowDataConfig.source已经被指定了，而且不为空
            rowCollection.rowRange = NSMakeRange(currentLocation, 1);
        } else if (rowDataConfig.emptyCellClass) {
            //如果rowDataConfig.source为空，而且指定了emptyCellClass
            rowCollection.rowRange = NSMakeRange(currentLocation, 1);
        } else {
            //如果rowDataConfig.source为空，而且也没有指定emptyCellClass
            rowCollection.rowRange = NSMakeRange(currentLocation, 0);
        }
        currentLocation = rowCollection.rowRange.location + rowCollection.rowRange.length;
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AOZTVPSectionCollection class]]) {
        return NO;
    }
    AOZTVPSectionCollection *anotherSectionCollection = (AOZTVPSectionCollection *) object;
    return NSEqualRanges(_sectionRange, anotherSectionCollection.sectionRange)
           && [_dataConfig isEqual:anotherSectionCollection.dataConfig]
           && [_rowCollectionsArray isEqualToArray:anotherSectionCollection.rowCollectionsArray];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AOZTVPSectionCollection: _sectionRange: %zd - %zd, _dataConfig: %@, _rowCollectionsArray: %@>",
            _sectionRange.location, _sectionRange.length, _dataConfig, (_rowCollectionsArray.count > 0? _rowCollectionsArray: @"")];
}
@end


@implementation AOZTVPMode
- (instancetype)init {
    self = [super init];
    if (self) {
        _sectionCollectionsArray = [[NSMutableArray alloc] init];
        _needsReload = YES;
    }
    return self;
}

- (void)reloadSections {
    NSInteger currentLocation = 0;
    for (AOZTVPSectionCollection *sectionCollection in _sectionCollectionsArray) {
        AOZTVPDataConfig *dataConfig = sectionCollection.dataConfig;
        if ([dataConfig.source isKindOfClass:[NSArray class]]) {
            //如果source是数组
            if ([dataConfig.source count] > 0) {
                if (dataConfig.elementsPerRow <= 0) {
                    sectionCollection.sectionRange = NSMakeRange(currentLocation, 1);
                } else {
                    sectionCollection.sectionRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) dataConfig.source).count / dataConfig.elementsPerRow));
                }
            } else if (dataConfig.emptyCellClass) {
                sectionCollection.sectionRange = NSMakeRange(currentLocation, 1);
            } else {
                sectionCollection.sectionRange = NSMakeRange(currentLocation, 0);
            }
        } else if (dataConfig.source) {
            //如果source是其他非空的类型
            sectionCollection.sectionRange = NSMakeRange(currentLocation, 1);
        } else if (dataConfig.emptyCellClass) {
            //如果source为空，但是指定了emptyCellClass
            sectionCollection.sectionRange = NSMakeRange(0, 1);
        } else {
            //如果source为空，而且也没有指定emptyCellClass
            sectionCollection.sectionRange = NSMakeRange(0, 0);
        }
        currentLocation = sectionCollection.sectionRange.location + sectionCollection.sectionRange.length;
        
        [sectionCollection reloadRows];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AOZTVPMode class]]) {
        return NO;
    }
    AOZTVPMode *anotherMode = (AOZTVPMode *)object;
    return [_sectionCollectionsArray isEqualToArray:anotherMode.sectionCollectionsArray];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AOZTVPMode: _sectionCollectionsArray: %@>", (_sectionCollectionsArray.count > 0? _sectionCollectionsArray: @"")];
}
@end
