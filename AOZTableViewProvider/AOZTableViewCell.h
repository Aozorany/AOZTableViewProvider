//
//  AOZTableViewCell.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>


/** cell位置指示符 */
typedef NS_ENUM(NSInteger, AOZTableViewCellPosition) {
    AOZTableViewCellPositionNormal = 0,/**< cell的位置在中间 */
    AOZTableViewCellPositionTop = 1,/**< cell的位置在section中的第一个 */
    AOZTableViewCellPositionBotton = 1 << 1,/**< cell的位置在section中的最后一个 */
    AOZTableViewCellPositionOnly = AOZTableViewCellPositionTop | AOZTableViewCellPositionBotton,/**< cell是section中的唯一一个 */
    AOZTableViewCellPositionPartTop = 1 << 2,/**< cell的位置在本数据结构的第一个 */
    AOZTableViewCellPositionPartBotton = 1 << 3,/**< cell的位置在本数据结构的最后一个 */
    AOZTableViewCellPositionPartOnly = AOZTableViewCellPositionPartTop | AOZTableViewCellPositionPartBotton,/**< cell是本数据结构中的唯一一个 */
};


@protocol AOZTableViewCell <NSObject>
@property (nonatomic, assign) int cellPositions;
- (void)setContents:(id)contents;
- (void)willDisplayCell;
+ (CGFloat)heightForCell:(id)contents;
@end


@interface AOZTableViewCell : UITableViewCell <AOZTableViewCell>
@end


@protocol AOZTableViewHeaderFooterView <NSObject>
- (void)setContents:(id)contents;
+ (CGFloat)heightForView:(id)contents;
@end


@interface AOZTableViewHeaderFooterView : UITableViewHeaderFooterView <AOZTableViewHeaderFooterView>
@end
