//
//  AOZTableViewDefaultRowParserTest.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewCell.h"


/** 测试的cell派生类 */
@interface DerivedAOZTableViewCell : AOZTableViewCell
@end


@implementation DerivedAOZTableViewCell
@end


@interface AOZTableViewDefaultRowParserTest : XCTestCase
@end


@implementation AOZTableViewDefaultRowParserTest {
    AOZTableViewDefaultRowParser *_rowParser;
    NSArray *_array;
    NSArray *_emptyArray;
    NSArray *_nilArray;
    NSDictionary *_dictionary;
    NSDictionary *_emptyDictionary;
}

#pragma mark setup and teardown
- (void)setUp {
    [super setUp];
    _rowParser = [[AOZTableViewDefaultRowParser alloc] init];
    _rowParser.dataProvider = self;
    
    _array = @[@"1", @"2", @"3"];
    _emptyArray = @[];
    _nilArray = nil;
    _dictionary = @{@"1": @1, @"2": @2};
    _emptyDictionary = @{};
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark testCases
/** 测试存在性 */
- (void)testExistance {
    NSAssert(_rowParser != nil, @"_rowParser初始化后为空");
}

/** 测试非法输入情形 */
- (void)testIrregularLines {
    NSString *lineStr = @"";
    NSArray<NSString *> *chunksArray = getChunksArray(lineStr);
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:chunksArray error:nil];
    NSAssert(rowCollection == nil, lineStr);
    
    lineStr = @"mode 0";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert(rowCollection == nil, lineStr);
    
    lineStr = @"section";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert(rowCollection == nil, lineStr);
    
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    lineStr = @"row -s fakeSource";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -s";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -c";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -c FakeClass";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -c NSDictionary";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -s -c";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);

    lineStr = @"row -c -s";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);

    lineStr = @"row -s -all";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -s -all -c";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
}

/** 测试合法输入情形 */
- (void)testRegularLines {
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    rowCollectionResult.dataConfig.elementsPerRow = 1;
    NSString *lineStr = @"row";
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row 1 2 3 4 5";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _nilArray;
    lineStr = @"row -s _nilArray";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _emptyArray;
    lineStr = @"row -s _emptyArray";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _array;
    lineStr = @"row -s _array";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    lineStr = @"row -s _array -n -1";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _emptyDictionary;
    lineStr = @"row -s _emptyDictionary";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _dictionary;
    lineStr = @"row -s _dictionary";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.cellClass = [DerivedAOZTableViewCell class];
    rowCollectionResult.dataConfig.source = [NSNull null];
    lineStr = @"row -c DerivedAOZTableViewCell";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _array;
    lineStr = @"row -c DerivedAOZTableViewCell -s _array";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    lineStr = @"row -s _array -n 2";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.elementsPerRow = -1;
    lineStr = @"row -s _array -all";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
    
    rowCollectionResult.dataConfig.source = _nilArray;
    lineStr = @"row -s _nilArray -all";
    rowCollection = [_rowParser parseNewConfig:getChunksArray(lineStr) error:nil];
    NSAssert([rowCollection isEqual:rowCollectionResult], lineStr);
}

@end
