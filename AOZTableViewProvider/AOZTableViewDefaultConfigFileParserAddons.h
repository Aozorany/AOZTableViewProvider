//
//  AOZTableViewDefaultConfigFileParserAddons.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/29.
//  Copyright © 2015年 Aozorany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AOZTableViewProviderUtils.h"


@interface AOZTableViewDefaultRowParser : NSObject
@property (nonatomic, assign) id dataProvider;
- (AOZTVPRowCollection *)parseNewConfig:(NSString *)lineStr;
@end


#pragma mark -
@interface AOZTableViewDefaultSectionParser : NSObject
@property (nonatomic, assign) id dataProvider;
- (AOZTVPSectionCollection *)parseNewConfigs:(NSArray<NSString *> *)linesArray;
@end


#pragma mark -
@interface AOZTableViewDefaultModeParser : NSObject
- (void)addNewConfig:(NSString *)lineStr;
- (AOZTVPMode *)flushAndParse;
@end