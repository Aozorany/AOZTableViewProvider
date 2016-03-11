//
//  AOZTableViewDefaultConfigDataParserTest.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 12/16/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewCell.h"


/** 测试的cell派生类 */
@interface DerivedAOZTableViewCell2 : AOZTableViewCell
@end


@implementation DerivedAOZTableViewCell2
@end


@interface AOZTableViewDefaultConfigDataParserTest : XCTestCase {
    NSArray *_array;
    NSArray *_emptyArray;
    NSArray *_nilArray;
    NSDictionary *_dictionary;
    NSDictionary *_emptyDictionary;
    AOZTableViewDefaultDataConfigParser *_dataConfigParser;
}
@end


@implementation AOZTableViewDefaultConfigDataParserTest

- (void)setUp {
    [super setUp];
    _dataConfigParser = [[AOZTableViewDefaultDataConfigParser alloc] init];
    _dataConfigParser.dataProvider = self;
    
    _array = @[@"1", @"2", @"3"];
    _emptyArray = @[];
    _nilArray = nil;
    _dictionary = @{@"1": @1, @"2": @2};
    _emptyDictionary = @{};
}

- (void)tearDown {
    [super tearDown];
}

- (void)testIrregularLines {
    NSString *line = @"";
    AOZTVPDataConfig *dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert(dataConfig == nil, line);
}

- (void)testSources {
    AOZTVPDataConfig *dataConfigResult = [[AOZTVPDataConfig alloc] init];
    
    NSString *line = @"row";
    AOZTVPDataConfig *dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"section";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _array";
    dataConfigResult.source = _array;
    dataConfigResult.sourceKey = @"_array";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _emptyArray";
    dataConfigResult.source = _emptyArray;
    dataConfigResult.sourceKey = @"_emptyArray";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _nilArray";
    dataConfigResult.source = _nilArray;
    dataConfigResult.sourceKey = @"_nilArray";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _dictionary";
    dataConfigResult.source = _dictionary;
    dataConfigResult.sourceKey = @"_dictionary";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _emptyDictionary";
    dataConfigResult.source = _emptyDictionary;
    dataConfigResult.sourceKey = @"_emptyDictionary";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -s _array";
    _dataConfigParser.dataProvider = nil;
    dataConfigResult.source = [NSNull null];
    dataConfigResult.sourceKey = nil;
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    _dataConfigParser.dataProvider = self;
    
    line = @"row -s fakeArray";
    dataConfigResult.sourceKey = @"fakeArray";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
}

- (void)testCellClass {
    AOZTVPDataConfig *dataConfigResult = [[AOZTVPDataConfig alloc] init];
    
    NSString *line = @"row -c xxx";
    AOZTVPDataConfig *dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -c";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -c NSObject";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -c DerivedAOZTableViewCell2";
    dataConfigResult.cellClass = [DerivedAOZTableViewCell2 class];
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
}

- (void)testElementsPerRow {
    AOZTVPDataConfig *dataConfigResult = [[AOZTVPDataConfig alloc] init];
    
    NSString *line = @"row -n xxx";
    AOZTVPDataConfig *dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n -3";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n -1";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n 5";
    dataConfigResult.elementsPerRow = 5;
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n 5 -n -1";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -n 3 -n 5";
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
    
    line = @"row -all";
    dataConfigResult.elementsPerRow = -1;
    dataConfig = [_dataConfigParser parseNewConfig:getChunksArray(line) error:NULL];
    NSAssert([dataConfig isEqual:dataConfigResult], line);
}

@end
