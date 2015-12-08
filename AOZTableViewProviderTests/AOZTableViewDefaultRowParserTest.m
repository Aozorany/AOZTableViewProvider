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
    _rowParser = nil;
    [super tearDown];
}

#pragma mark testCases
/** 测试存在性 */
- (void)testExistance {
    NSAssert(_rowParser != nil, @"_rowParser初始化后为空");
}

/** 测试非法输入情形 */
- (void)testIrregularLines {
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:@""];
    NSAssert(rowCollection == nil, @"输入参数为空行的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"mode 0"];
    NSAssert(rowCollection == nil, @"输入参数为mode 0的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"section"];
    NSAssert(rowCollection == nil, @"输入参数为section的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s fakeSource"];
    NSAssert(rowCollection == nil, @"输入参数为row -s fakeSource的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s"];
    NSAssert(rowCollection == nil, @"输入参数为row -s的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -c"];
    NSAssert(rowCollection == nil, @"输入参数为row -c的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -c FakeClass"];
    NSAssert(rowCollection == nil, @"输入参数为row -c FakeClass的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -c NSDictionary"];
    NSAssert(rowCollection == nil, @"输入参数为row -c NSDictionary的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s -c"];
    NSAssert(rowCollection == nil, @"输入参数为row -s -c的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -c -s"];
    NSAssert(rowCollection == nil, @"输入参数为row -c -s的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s -all"];
    NSAssert(rowCollection == nil, @"输入参数为row -s -all的时候结果不为空");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s -all -c"];
    NSAssert(rowCollection == nil, @"输入参数为row -s -all -c的时候结果不为空");
}

/** 测试合法输入情形 */
- (void)testRegularLines {
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    rowCollectionResult.rowRange = NSMakeRange(0, 1);
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    rowCollectionResult.dataConfig.elementsPerRow = 1;
    AOZTVPRowCollection *rowCollection = [_rowParser parseNewConfig:@"row"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row与预期结果不相等");
    
    rowCollection = [_rowParser parseNewConfig:@"row 1 2 3 4 5"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row 1 2 3 4 5与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, 0);
    rowCollectionResult.dataConfig.source = _nilArray;
    rowCollection = [_rowParser parseNewConfig:@"row -s _nilArray"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _nilArray与预期结果不相等");
    
    rowCollectionResult.dataConfig.source = _emptyArray;
    rowCollection = [_rowParser parseNewConfig:@"row -s _emptyArray"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _emptyArray与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, _array.count);
    rowCollectionResult.dataConfig.source = _array;
    rowCollection = [_rowParser parseNewConfig:@"row -s _array"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _array与预期结果不相等");
    
    rowCollection = [_rowParser parseNewConfig:@"row -s _array -n -1"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _array -n -1与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, 1);
    rowCollectionResult.dataConfig.source = _emptyDictionary;
    rowCollection = [_rowParser parseNewConfig:@"row -s _emptyDictionary"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _emptyDictionary与预期结果不相等");
    
    rowCollectionResult.dataConfig.source = _dictionary;
    rowCollection = [_rowParser parseNewConfig:@"row -s _dictionary"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _dictionary与预期结果不相等");
    
    rowCollectionResult.dataConfig.cellClass = [DerivedAOZTableViewCell class];
    rowCollectionResult.dataConfig.source = [NSNull null];
    rowCollection = [_rowParser parseNewConfig:@"row -c DerivedAOZTableViewCell"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -c DerivedAOZTableViewCell与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, _array.count);
    rowCollectionResult.dataConfig.source = _array;
    rowCollection = [_rowParser parseNewConfig:@"row -c DerivedAOZTableViewCell -s _array"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -c DerivedAOZTableViewCell -s _array与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, ceilf(_array.count / 2.0f));
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    rowCollection = [_rowParser parseNewConfig:@"row -s _array -n 2"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _array -n 2与预期结果不相等");
    
    rowCollectionResult.rowRange = NSMakeRange(0, 1);
    rowCollectionResult.dataConfig.elementsPerRow = -1;
    rowCollection = [_rowParser parseNewConfig:@"row -s _array -all"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _array -all与预期结果不相等");
    
    rowCollectionResult.dataConfig.source = _nilArray;
    rowCollectionResult.rowRange = NSMakeRange(0, 0);
    rowCollection = [_rowParser parseNewConfig:@"row -s _nilArray -all"];
    NSAssert([rowCollection isEqual:rowCollectionResult], @"row -s _nilArray -all与预期结果不相等");
}

@end
