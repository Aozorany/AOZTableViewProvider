//
//  AOZTableViewDefaultModeParserTest.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 1/7/16.
//  Copyright © 2016 Aozorany. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewProviderUtils.h"


#pragma mark -
@interface AOZTableViewDefaultModeParserTest : XCTestCase
@end


@implementation AOZTableViewDefaultModeParserTest {
    AOZTableViewDefaultModeParser *_modeParser;
    NSArray *_array;
    NSArray *_emptyArray;
    NSArray *_nilArray;
    NSDictionary *_dictionary;
    NSDictionary *_emptyDictionary;
}

- (void)setUp {
    [super setUp];
    
    _modeParser = [[AOZTableViewDefaultModeParser alloc] init];
    _modeParser.dataProvider = self;
    
    _array = @[@"1", @"2", @"3"];
    _emptyArray = @[];
    _nilArray = nil;
    _dictionary = @{@"1": @1, @"2": @2};
    _emptyDictionary = @{};
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    NSString *linesStr = @"mode \n section \n row \n row \n section \n section";
    AOZTVPMode *mode = [_modeParser parseNewConfigs:getLinesAndChunksArray(linesStr) error:nil];
    NSLog(@"mode: %@", mode.sectionCollectionsArray);
}

@end
