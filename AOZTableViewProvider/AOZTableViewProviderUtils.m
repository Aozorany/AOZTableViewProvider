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
            _dataConfig.source = [dataConfig.source isKindOfClass:[NSArray class]]? nil: dataConfig.source;
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
    return [NSString stringWithFormat:@"<AOZTVPRowCollection: _rowRange: %d - %d, _dataConfig: %@>",
            _rowRange.location, _rowRange.length, _dataConfig];
}
@end


@implementation AOZTVPSectionCollection
- (instancetype)init {
    self = [super init];
    if (self) {
        _rowCollectionsArray = [[NSMutableArray alloc] init];
        _dataConfig = [[AOZTVPDataConfig alloc] init];
        _numberOfRows = 1;
        _sectionRange = NSMakeRange(0, 0);
    }
    return self;
}

- (void)reloadRows {
    NSInteger currentLocation = 0;
    if (_rowCollectionsArray.count == 0) {
        AOZTVPRowCollection *defaultRowCollection = [[AOZTVPRowCollection alloc] initWithDataConfig:_dataConfig];
        [_rowCollectionsArray addObject:defaultRowCollection];
    }
    for (AOZTVPRowCollection *rowCollection in _rowCollectionsArray) {
        AOZTVPDataConfig *dataConfig = rowCollection.dataConfig;
        if ([dataConfig.source isKindOfClass:[NSArray class]]) {
            if (dataConfig.elementsPerRow <= 0) {
                rowCollection.rowRange = NSMakeRange(currentLocation, 1);
            } else {
                rowCollection.rowRange = NSMakeRange(currentLocation, ceil((CGFloat) ((NSArray *) dataConfig.source).count / dataConfig.elementsPerRow));
            }
        } else {
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
    return [NSString stringWithFormat:@"<AOZTVPSectionCollection: _sectionRange: %d - %d, _dataConfig: %@, _rowCollectionsArray: %@>",
            _sectionRange.location, _sectionRange.length, _dataConfig, (_rowCollectionsArray.count > 0? _rowCollectionsArray: @"")];
}
@end


@implementation AOZTVPMode
- (instancetype)init {
    self = [super init];
    if (self) {
        _sectionCollectionsArray = [[NSMutableArray alloc] init];
        _numberOfSections = 0;
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
