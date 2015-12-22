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
//    AOZTableViewDefaultSectionParser *_sectionParser;
    NSArray *_array;
    NSArray *_emptyArray;
    NSArray *_nilArray;
    NSDictionary *_dictionary;
    NSDictionary *_emptyDictionary;
}

- (void)setUp {
    [super setUp];
    
//    _sectionParser = [[AOZTableViewDefaultSectionParser alloc] init];
//    _sectionParser.dataProvider = self;
    
    _array = @[@"1", @"2", @"3"];
    _emptyArray = @[];
    _nilArray = nil;
    _dictionary = @{@"1": @1, @"2": @2};
    _emptyDictionary = @{};
}

- (void)tearDown {
    [super tearDown];
}

/** 测试存在性 */
- (void)testExistance {
//    NSAssert(_sectionParser != nil, @"_sectionParser初始化后为空");
}

/** 测试非法输入情形 */
- (void)testIrregularLines {
}

/** 测试合法输入情形 */
- (void)testRegularLines {
    
}

@end
