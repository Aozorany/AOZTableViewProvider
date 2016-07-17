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
@property (nonatomic, copy) NSString *sourceKey;/**< 数据源对应的key值 */
@property (nonatomic, copy) NSString *tag;
@property (nonatomic, assign) NSInteger elementsPerRow;/**< 每个单元格的元素个数，如果是-1则表示所有元素都在同一行内，默认是1 */
- (void)rebindSourceWithDataProvider:(id)dataProvider;
@end


@interface AOZTVPRowCollection : NSObject
@property (nonatomic, retain) AOZTVPDataConfig *dataConfig;
@property (nonatomic, assign) NSRange rowRange;
@property (nonatomic, copy) NSString *elementSourceKey;
- (instancetype)initWithDataConfig:(AOZTVPDataConfig *)dataConfig;
@end


@interface AOZTVPSectionCollection : NSObject <NSCopying>
@property (nonatomic, retain) NSMutableArray <AOZTVPRowCollection *> *rowCollectionsArray;
@property (nonatomic, retain) AOZTVPDataConfig *dataConfig;
@property (nonatomic, assign) Class headerClass;
@property (nonatomic, assign) NSRange sectionRange;
- (void)reloadRows;/**< 重新载入rows，计算其rowRange */
- (void)reloadRowsWithSectionElement:(id)sectionElement;/**< 根据sectionElement重新确认row的range，sectionElement为分配给每个section的数据源元素，一般sectionCollection的source是array的时候才会用到这个方法 */
@end


@interface AOZTVPMode : NSObject
@property (nonatomic, retain) NSMutableArray <AOZTVPSectionCollection *> *sectionCollectionsArray;
@property (nonatomic, assign) BOOL needsReload;
- (void)rebindSourceWithDataProvider:(id)dataProvider;
- (void)reloadSections;
@end
