//
//  AOZTableViewDefaultConfigFileParserAddons.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AOZTableViewProviderUtils.h"


#pragma mark -
/** 把一行字符串按空格分开 */
NSArray<NSString *> *getChunksArray(NSString *lineStr);


#pragma mark -
extern NSString * const AOZTableViewDefaultDataConfigParserDomain;
@interface AOZTableViewDefaultDataConfigParser : NSObject
@property (nonatomic, assign) id dataProvider;
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError;
@end


#pragma mark -
@interface AOZTableViewDefaultRowParser : NSObject
@property (nonatomic, assign) id dataProvider;
- (AOZTVPRowCollection *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError;
@end


//#pragma mark -
//@interface AOZTableViewDefaultSectionParser : NSObject
//@property (nonatomic, assign) id dataProvider;
//- (AOZTVPSectionCollection *)parseNewConfigs:(NSArray<NSString *> *)linesArray;
//@end
//
//
//#pragma mark -
//@interface AOZTableViewDefaultModeParser : NSObject
//- (void)addNewConfig:(NSString *)lineStr;
//- (AOZTVPMode *)flushAndParse;
//@end