//
//  AOZTableViewDefaultSectionParserTest.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/12/8.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewCell.h"


#pragma mark -
@interface DerivedAOZTableViewCell3 : AOZTableViewCell
@end


@implementation DerivedAOZTableViewCell3
@end


@interface DerivedAOZTableViewCell4 : AOZTableViewCell
@end


@implementation DerivedAOZTableViewCell4
@end


#pragma mark -
@interface AOZTableViewDefaultSectionParserTest : XCTestCase
@end


#pragma mark -
@implementation AOZTableViewDefaultSectionParserTest {
    AOZTableViewDefaultSectionParser *_sectionParser;
    NSArray *_array;
    NSArray *_emptyArray;
    NSArray *_nilArray;
    NSDictionary *_dictionary;
    NSDictionary *_emptyDictionary;
}

- (void)setUp {
    [super setUp];
    
    _sectionParser = [[AOZTableViewDefaultSectionParser alloc] init];
    _sectionParser.dataProvider = self;
    
    _array = @[@"1", @"2", @"3"];
    _emptyArray = @[];
    _nilArray = nil;
    _dictionary = @{@"1": @1, @"2": @2};
    _emptyDictionary = @{};
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSingleIrregularLines {
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    
    NSString *linesStr = @"mode 0";
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert(sectionCollection == nil, linesStr);
    
    linesStr = @"section";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s fakeSource";
    sectionCollectionResult.dataConfig.sourceKey = @"fakeSource";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s";
    sectionCollectionResult.dataConfig.sourceKey = nil;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c FakeClass";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);

    linesStr = @"section -c NSDictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c -s";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s -all";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s -all -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
}

- (void)testSingleIrregularLinesStartWithRow {
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    [sectionCollectionResult.rowCollectionsArray addObject:rowCollectionResult];
    
    NSString *linesStr = @"row";
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s fakeSource";
    rowCollectionResult.dataConfig.sourceKey = @"fakeSource";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s";
    rowCollectionResult.dataConfig.sourceKey = nil;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c FakeClass";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c NSDictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c -s";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s -all";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s -all -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
}

- (void)testSingleRegularLinesStartWithSection {
    NSString *linesStr = @"section -s _array";
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    sectionCollectionResult.dataConfig.source = _array;
    sectionCollectionResult.dataConfig.sourceKey = @"_array";
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _emptyArray";
    sectionCollectionResult.dataConfig.source = _emptyArray;
    sectionCollectionResult.dataConfig.sourceKey = @"_emptyArray";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _nilArray";
    sectionCollectionResult.dataConfig.source = _nilArray;
    sectionCollectionResult.dataConfig.sourceKey = @"_nilArray";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _array -n -1";
    sectionCollectionResult.dataConfig.source = _array;
    sectionCollectionResult.dataConfig.sourceKey = @"_array";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _emptyDictionary";
    sectionCollectionResult.dataConfig.source = _emptyDictionary;
    sectionCollectionResult.dataConfig.sourceKey = @"_emptyDictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _dictionary";
    sectionCollectionResult.dataConfig.source = _dictionary;
    sectionCollectionResult.dataConfig.sourceKey = @"_dictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c DerivedAOZTableViewCell3";
    sectionCollectionResult.dataConfig.source = [NSNull null];
    sectionCollectionResult.dataConfig.sourceKey = nil;
    sectionCollectionResult.dataConfig.cellClass = [DerivedAOZTableViewCell3 class];
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c DerivedAOZTableViewCell3 -s _array";
    sectionCollectionResult.dataConfig.source = _array;
    sectionCollectionResult.dataConfig.sourceKey = @"_array";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _array -n 2";
    sectionCollectionResult.dataConfig.elementsPerRow = 2;
    sectionCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _array -all";
    sectionCollectionResult.dataConfig.elementsPerRow = -1;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _array -all -n 2";
    sectionCollectionResult.dataConfig.elementsPerRow = 2;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s _nilArray -all";
    sectionCollectionResult.dataConfig.source = _nilArray;
    sectionCollectionResult.dataConfig.sourceKey = @"_nilArray";
    sectionCollectionResult.dataConfig.elementsPerRow = -1;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
}

- (void)testSingleRegularLinesStartWithRow {
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    AOZTVPRowCollection *rowCollectionResult = [[AOZTVPRowCollection alloc] init];
    [sectionCollectionResult.rowCollectionsArray addObject:rowCollectionResult];
    
    NSString *linesStr = @"row -s _nilArray";
    rowCollectionResult.dataConfig.source = _nilArray;
    rowCollectionResult.dataConfig.sourceKey = @"_nilArray";
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _emptyArray";
    rowCollectionResult.dataConfig.source = _emptyArray;
    rowCollectionResult.dataConfig.sourceKey = @"_emptyArray";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _array";
    rowCollectionResult.dataConfig.source = _array;
    rowCollectionResult.dataConfig.sourceKey = @"_array";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _array -n -1";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _emptyDictionary";
    rowCollectionResult.dataConfig.source = _emptyDictionary;
    rowCollectionResult.dataConfig.sourceKey = @"_emptyDictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _dictionary";
    rowCollectionResult.dataConfig.source = _dictionary;
    rowCollectionResult.dataConfig.sourceKey = @"_dictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c DerivedAOZTableViewCell3";
    rowCollectionResult.dataConfig.cellClass = [DerivedAOZTableViewCell3 class];
    rowCollectionResult.dataConfig.source = [NSNull null];
    rowCollectionResult.dataConfig.sourceKey = nil;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -c DerivedAOZTableViewCell3 -s _array";
    rowCollectionResult.dataConfig.source = _array;
    rowCollectionResult.dataConfig.sourceKey = @"_array";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _array -n 2";
    rowCollectionResult.dataConfig.cellClass = [AOZTableViewCell class];
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _array -all";
    rowCollectionResult.dataConfig.elementsPerRow = -1;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _array -all -n 2";
    rowCollectionResult.dataConfig.elementsPerRow = 2;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"row -s _nilArray -all";
    rowCollectionResult.dataConfig.source = _nilArray;
    rowCollectionResult.dataConfig.sourceKey = @"_nilArray";
    rowCollectionResult.dataConfig.elementsPerRow = -1;
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
}

- (void)testMultipleLinesStartWithSection {
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    AOZTVPRowCollection *rowCollectionResult1 = [[AOZTVPRowCollection alloc] init];
    [sectionCollectionResult.rowCollectionsArray addObject:rowCollectionResult1];
    AOZTVPRowCollection *rowCollectionResult2 = [[AOZTVPRowCollection alloc] init];
    [sectionCollectionResult.rowCollectionsArray addObject:rowCollectionResult2];
    
    NSString *linesStr = @"section \n row -c DerivedAOZTableViewCell3 \n row -c DerivedAOZTableViewCell4";
    rowCollectionResult1.dataConfig.cellClass = [DerivedAOZTableViewCell3 class];
    rowCollectionResult2.dataConfig.cellClass = [DerivedAOZTableViewCell4 class];
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
//    linesStr = @"section -s _array \n row -c DerivedAOZTableViewCell3 \n row -c DerivedAOZTableViewCell4";
//    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
//    NSLog(@"%@", sectionCollection);
}

@end
