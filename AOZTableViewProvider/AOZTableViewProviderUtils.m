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
        && ((_source == nil && anotherDataConfig.source == nil) || [_source isEqual:anotherDataConfig.source]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<AOZTVPDataConfig: _elementsPerRow: %d, _cellClass: %@, _source: %@>",
            _elementsPerRow, NSStringFromClass(_cellClass), _source];
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
        newSectionCollection.sectionRange = _sectionRange;
        newSectionCollection.headerClass = _headerClass;
        for (AOZTVPRowCollection *rowCollection in _rowCollectionsArray) {
            AOZTVPRowCollection *newRowCollection = [[AOZTVPRowCollection alloc] init];
            newRowCollection.dataConfig.elementsPerRow = rowCollection.dataConfig.elementsPerRow;
            newRowCollection.dataConfig.source = rowCollection.dataConfig.source;
            newRowCollection.dataConfig.cellClass = rowCollection.dataConfig.cellClass;
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
        AOZTVPDataConfig *dataConfig = rowCollection.dataConfig;
        if ([dataConfig.source isKindOfClass:[NSArray class]]) {//如果row自身的source就是array
            if (dataConfig.elementsPerRow <= 0) {
                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
            } else {
                rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) dataConfig.source).count / dataConfig.elementsPerRow));
            }
        } else if ([dataConfig.source isEqual:[NSNull null]] && sectionElement) {//如果row自身的source没有被指定，但是指定了sectionElement
            if ([sectionElement isKindOfClass:[NSArray class]]) {//如果sectionElement本身就是一个array
                if (dataConfig.elementsPerRow <= 0) {
                    rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                } else {
                    rowCollection.dataConfig.source = sectionElement;
                    rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) sectionElement).count / dataConfig.elementsPerRow));
                }
            } else if (rowCollection.elementSource.length > 0) {//如果指定了row的elementSource
                @try {
                    id elementSourceObj = [sectionElement valueForKey:rowCollection.elementSource];
                    rowCollection.dataConfig.source = elementSourceObj;
                    if ([elementSourceObj isKindOfClass:[NSArray class]]) {
                        if (dataConfig.elementsPerRow <= 0) {
                            rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                        } else {
                            rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) elementSourceObj).count / dataConfig.elementsPerRow));
                        }
                    } else {
                        rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                    }
                }
                @catch (NSException *exception) {
                    rowCollection.rowRange = NSMakeRange(currentLocation, 1);
                }
            } else {//如果sectionElement本身属于其他样式
                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
            }
        } else {//如果row自身的source没有被指定，也没有指定sectionElement
            rowCollection.rowRange = NSMakeRange(currentLocation, 1);
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
            if (dataConfig.elementsPerRow <= 0) {
                sectionCollection.sectionRange = NSMakeRange(currentLocation, 1);
            } else {
                sectionCollection.sectionRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) dataConfig.source).count / dataConfig.elementsPerRow));
            }
        } else {
            sectionCollection.sectionRange = NSMakeRange(currentLocation, 1);
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
