//
//  AOZTableViewDefaultConfigFileParserAddons.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "AOZTableViewProviderUtils.h"


#pragma mark -
/** 把一行字符串按空格分开 */
NSArray<NSString *> *getChunksArray(NSString *lineStr);
/** 把一个带有换行的字符串先按换行符，再按空格分开 */
NSArray<NSArray<NSString *> *> *getLinesAndChunksArray(NSString *linesStr);


#pragma mark -
extern NSString * const AOZTableViewDefaultDataConfigParserDomain;
@interface AOZTableViewDefaultDataConfigParser : NSObject
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) UITableView *tableView;
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError;
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig;
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig rowCollection:(AOZTVPRowCollection *)rowCollection;
@end


#pragma mark -
@interface AOZTableViewDefaultRowParser : NSObject
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) UITableView *tableView;
- (AOZTVPRowCollection *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError;
- (AOZTVPRowCollection *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)dataConfig;
@end


#pragma mark -
@interface AOZTableViewDefaultSectionParser : NSObject
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) UITableView *tableView;
- (AOZTVPSectionCollection *)parseNewConfigs:(NSArray<NSArray<NSString *> *> *)linesArray error:(NSError **)pError;
@end


#pragma mark -
@interface AOZTableViewDefaultModeParser : NSObject
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) UITableView *tableView;
- (AOZTVPMode *)parseNewConfigs:(NSArray<NSArray<NSString *> *> *)linesArray error:(NSError **)pError;
@end