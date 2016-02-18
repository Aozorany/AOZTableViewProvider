//
//  AOZTableViewProviderUtils.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface AOZTVPDataConfig : NSObject
@property (nonatomic, assign) Class cellClass;/**< 单元格所属类名，必须是AOZTableViewCell的派生类 */
@property (nonatomic, assign) Class emptyCellClass;/**< source为nil，或者source元素个数为0时，单元格所属类名，必须是AOZTableViewCell的派生类 */
@property (nonatomic, assign) id source;/**< 数据源 */
@property (nonatomic, assign) NSInteger elementsPerRow;/**< 每个单元格的元素个数，如果是-1则表示所有元素都在同一行内，默认是1 */
@end


@interface AOZTVPRowCollection : NSObject
@property (nonatomic, retain) AOZTVPDataConfig *dataConfig;
@property (nonatomic, assign) NSRange rowRange;
@property (nonatomic, copy) NSString *elementSource;
- (instancetype)initWithDataConfig:(AOZTVPDataConfig *)dataConfig;
@end


@interface AOZTVPSectionCollection : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray <AOZTVPRowCollection *> *rowCollectionsArray;
@property (nonatomic, retain) AOZTVPDataConfig *dataConfig;
@property (nonatomic, assign) Class headerClass;
@property (nonatomic, assign) NSRange sectionRange;
- (void)reloadRows;
- (void)reloadRowsWithSectionElement:(id)sectionElement;
@end


@interface AOZTVPMode : NSObject
@property (nonatomic, retain) NSMutableArray <AOZTVPSectionCollection *> *sectionCollectionsArray;
@property (nonatomic, assign) BOOL needsReload;
- (void)reloadSections;
@end
