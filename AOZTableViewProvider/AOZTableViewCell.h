//
//  AOZTableViewCell.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>


/** Position indicators for AOZTableViewCell */
typedef NS_ENUM(NSInteger, AOZTableViewCellPosition) {
    AOZTableViewCellPositionNormal = 0,/**< cell is in middle of section or row collection */
    AOZTableViewCellPositionTop = 1,/**< 1, cell is the first one in section */
    AOZTableViewCellPositionBotton = 1 << 1,/**< 2, cell is the last one in section */
    AOZTableViewCellPositionOnly = AOZTableViewCellPositionTop | AOZTableViewCellPositionBotton,/**< 3, cell is the only one in section */
    AOZTableViewCellPositionPartTop = 1 << 2,/**< 4, cell is the first one in row collection */
    AOZTableViewCellPositionPartBotton = 1 << 3,/**< 8, cell is the last one in row collection */
    AOZTableViewCellPositionPartOnly = AOZTableViewCellPositionPartTop | AOZTableViewCellPositionPartBotton,/**< 12, cell is the only one in row collection */
};


#pragma mark -
/** Protocol to cells in config file<br>
   setContents and heightForCell have two versions, implement only one version as you like.*/
@protocol AOZTableViewCell <NSObject>
@optional
- (void)setContents:(id)contents;/**< set contents of cell, contents may be nil, or NSDictionary, or NSArray, or other objects, don't call it directly */
- (void)setContents:(id)contents positions:(NSInteger)cellPositions indexPath:(NSIndexPath *)indexPath tag:(NSString *)tag;/**< set contents of cell, contents may be nil, or NSDictionary, or NSArray, or other objects, don't call it directly */
- (void)willDisplayCell;/**< called within UITableViewDelegate's willDisplayCell method, if you want to change backgroundColor, do it here, don't call it directly */
- (void)willDisplayCell:(id)contents positions:(NSInteger)cellPositions indexPath:(NSIndexPath *)indexPath tag:(NSString *)tag;/**< called within UITableViewDelegate's willDisplayCell method, if you want to change backgroundColor, do it here, don't call it directly */
+ (CGFloat)heightForCell:(id)contents;/**< returns height to this cell, don't call it directly */
+ (CGFloat)heightForCell:(id)contents positions:(NSInteger)cellPositions indexPath:(NSIndexPath *)indexPath tag:(NSString *)tag;/**< returns height to this cell, don't call it directly */
@end


#pragma mark -
/** Base class to cells in config file */
@interface AOZTableViewCell : UITableViewCell <AOZTableViewCell>
@end


#pragma mark -
@interface AOZTableViewDetailCell: AOZTableViewCell
- (void)setLowerSeparatorViewHidden:(BOOL)hidden;
@end


#pragma mark -

/**
 State of UISwitch in AOZTableViewSwitchCell

 - AOZTableViewSwitchCellStateOff: UISwitch off
 - AOZTableViewSwitchCellStateOn: UISwitch on
 - AOZTableViewSwitchCellStatePending: UISwitch hides and shows the animating activityView
 */
typedef NS_ENUM(NSInteger, AOZTableViewSwitchCellState) {
    AOZTableViewSwitchCellStateOff,
    AOZTableViewSwitchCellStateOn,
    AOZTableViewSwitchCellStatePending,
};

@interface AOZTableViewSwitchCell: AOZTableViewCell
@property (nonatomic, assign, setter=setSwitchViewState:) AOZTableViewSwitchCellState state;
@property (nonatomic, weak) id actionTarget;
@property (nonatomic, assign) SEL switchViewValueChangedAction;/**< value changed action for UISwitch in this cell, it has UISwitch as its parameter, and you can get touch point via convertPoint:toView:, and use indexPathForRowAtPoint to get the cell's indexPath */
- (void)setSwitchViewOnTintColor:(UIColor *)color;
- (void)setSwitchViewThumbTintColor:(UIColor *)color;
- (void)setSwitchViewTintColor:(UIColor *)color;
- (void)setLowerSeparatorViewHidden:(BOOL)hidden;
@end


/** Protocol to section headers in config file */
@protocol AOZTableViewHeaderFooterView <NSObject>
- (void)setContents:(id)contents;/**< set contents of section header view, contents may be nil, or NSDictionary, or NSArray, or other objects, don't call it directly */
+ (CGFloat)heightForView:(id)contents;/**< returns height to this section header view, don't call it directly */
@end


/** Base class to section headers in config file */
@interface AOZTableViewHeaderFooterView : UITableViewHeaderFooterView <AOZTableViewHeaderFooterView>
@end
