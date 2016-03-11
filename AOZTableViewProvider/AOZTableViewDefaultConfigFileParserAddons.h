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
/**
 *  解析配置，并返回解析出来的DataConfig对象
 *  @param chunksArray       一行配置，每一个元素都是一个不带空格的字符串
 *  @param pError            解析中出现的错误
 *  @return 解析出的dataConfig对象
 */
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError;
/**
 *  解析配置，并返回解析出来的DataConfig对象
 *  @param chunksArray       一行配置，每一个元素都是一个不带空格的字符串
 *  @param pError            解析中出现的错误
 *  @param presetDataConfig  需要预先向结果中填入的dataConfig，它里面的cellClass, emptyCellClass, source和elementsPerRow会在初始化的时候写入到结果中的对应成员中
 *  @return 解析出的dataConfig对象
 */
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig;
/**
 *  解析配置，并返回解析出来的DataConfig对象
 *  @param chunksArray       一行配置，每一个元素都是一个不带空格的字符串
 *  @param pError            解析中出现的错误
 *  @param presetDataConfig  需要预先向结果中填入的dataConfig，它里面的cellClass, emptyCellClass, source和elementsPerRow会在初始化的时候写入到结果中的对应成员中
 *  @param rowCollection     被此配置信息影响的rowCollection，如果出现-es配置项，则需要修改对应的rowCollection中的成员
 *  @return 解析出的dataConfig对象
 */
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig rowCollection:(AOZTVPRowCollection *)rowCollection;
/**
 *  解析配置，并返回解析出来的DataConfig对象
 *  @param chunksArray       一行配置，每一个元素都是一个不带空格的字符串
 *  @param pError            解析中出现的错误
 *  @param presetDataConfig  需要预先向结果中填入的dataConfig，它里面的cellClass, emptyCellClass, source和elementsPerRow会在初始化的时候写入到结果中的对应成员中
 *  @param rowCollection     被此配置信息影响的rowCollection，如果出现-es配置项，则需要修改对应的rowCollection中的成员
 *  @param sectionCollection 被此配置信息影响的sectionCollection，如果出现-h配置项，则需要修改对应的sectionCollection中的成员
 *  @return 解析出的dataConfig对象
 */
- (AOZTVPDataConfig *)parseNewConfig:(NSArray<NSString *> *)chunksArray error:(NSError **)pError dataConfig:(AOZTVPDataConfig *)presetDataConfig rowCollection:(AOZTVPRowCollection *)rowCollection sectionCollection:(AOZTVPSectionCollection *)sectionCollection;
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