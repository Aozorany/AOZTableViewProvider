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
        && [NSStringFromClass(_cellClass) isEqualToString:NSStringFromClass(anotherDataConfig.cellClass)];
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

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AOZTVPRowCollection class]]) {
        return NO;
    }
    AOZTVPRowCollection *anotherRowCollection = (AOZTVPRowCollection *)object;
    return NSEqualRanges(_rowRange, anotherRowCollection.rowRange)
        && [_dataConfig isEqual:anotherRowCollection.dataConfig];
}

- (BOOL)rearrangeAndCheckAvaliable {
    if (_dataConfig == nil || _dataConfig.elementsPerRow == 0) {
        return NO;
    }
    //指定rowRange中的length
    id source = _dataConfig.source;/**< 数据源 */
    if ([source isKindOfClass:[NSArray class]]) {
        if ([source count] == 0) {
            //数组里面没有元素
            _rowRange.length = 0;
        } else if (_dataConfig.elementsPerRow < 0) {
            //数组里面有元素，而且设定所有元素都在同一行
            _rowRange.length = 1;
        } else if (_dataConfig.elementsPerRow == 1) {
            //数组里面有元素，而且每行只有一个元素
            _rowRange.length = [source count];
        } else if (_dataConfig.elementsPerRow > 1) {
            //数组里面有元素，而且每行有多个元素
            _rowRange.length = ceilf(((float) [source count]) / _dataConfig.elementsPerRow);
        }
    } else if ([source isKindOfClass:[NSNull class]]) {
        //source值从来没有被设定过
        _rowRange.length = 1;
        _dataConfig.elementsPerRow = 1;
    } else if (source != nil) {
        //如果是其他情况，例如字典、其他类等
        _rowRange.length = 1;
        _dataConfig.elementsPerRow = 1;
    } else {
        //如果是nil
        _rowRange.length = 0;
    }
    return YES;
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
@end
