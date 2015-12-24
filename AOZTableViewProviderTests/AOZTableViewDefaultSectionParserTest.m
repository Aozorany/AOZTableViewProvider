//
//  AOZTableViewDefaultSectionParserTest.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/12/8.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"


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
    NSString *linesStr = @"mode 0";
    AOZTVPSectionCollection *sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert(sectionCollection == nil, linesStr);
    
    linesStr = @"section";
    AOZTVPSectionCollection *sectionCollectionResult = [[AOZTVPSectionCollection alloc] init];
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s fakeSource";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -s";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
    
    linesStr = @"section -c FakeClass";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);

    linesStr = @"row -c NSDictionary";
    sectionCollection = [_sectionParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSAssert([sectionCollection isEqual:sectionCollectionResult], linesStr);
}

- (void)testSingleRegularLines {
    
}

@end
