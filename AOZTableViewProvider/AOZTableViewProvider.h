//
//  AOZTableViewProvider.h
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>


#ifndef AOZTableViewProviderErrorDomain
    #define AOZTableViewProviderErrorDomain @"AOZTableViewProviderError"
#endif


#pragma mark -
@protocol AOZTableViewProviderDelegate;

/** Provides dataSource and some delegates for UITableView, init - connectToTableView - parseConfigFile - reloadTableView */
@interface AOZTableViewProvider : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *configBundleFileName;/**< File name for config file, must contained in app bundle. If it hasn't extension name, then .tableViewConfig is the default extension. */
@property (nonatomic, copy) NSString *configString;
@property (nonatomic, readonly) UITableView *tableView;/**< The tableView connected with this provider, use connectToTableView to set this value. */
@property (nonatomic, weak) id dataProvider;/**< Tells this provider where to find values */
@property (nonatomic, assign) NSInteger mode;/**< Current mode index for this provider */
@property (nonatomic, weak) id<AOZTableViewProviderDelegate> delegate;/**< Delegate for this provider */
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;/**< ScrollViewDelegate associated with this tableView */

#pragma mark init
- (instancetype)initWithFileName:(NSString *)fileName dataProvider:(id)dataProvider tableView:(UITableView *)tableView;/**< Create a new instance for this provider, with fileName, dataProvider and tableView established. */
- (instancetype)initWithConfigString:(NSString *)config dataProvider:(id)dataProvider tableView:(UITableView *)tableView;

#pragma mark parse config
- (BOOL)parseConfigFile:(NSError **)pError __attribute__((deprecated));/**< Parse config file, must use after connectToTableView, if any error occurs, return it within pError, pError could be nil */
- (BOOL)parseConfigWithError:(NSError **)pError;

#pragma mark reload
- (void)reloadTableView;/**< Reload tableView, if dataSource has changed, use it after setNeedsReloadForCurrentMode or setNeedsReloadForMode */
- (void)setNeedsReloadForMode:(int)mode;/**< Use before reloadTableView, tells this provider to re-compute sections and rows for mode before loading, invoked when dataSource is changed. If mode is not exist, do nothing */
- (void)setNeedsReloadForCurrentMode;/**< Use before reloadTableView, tells this provider to re-compute sections and rows before loading for current mode. invoked when dataSource is changed. */
- (void)setNeedsReloadForAllModes;/**< Use before reloadTableView, tells this provider to re-compute sections and rows for all modes before loading, invoked when dataSource is changed. */

#pragma mark row and section contents
- (id)rowContentsAtIndexPath:(NSIndexPath *)indexPath;/**< Get row contents for indexPath from cache, must use after the first time you reloadTableView and setNeedsReloadForMode or setNeedsReloadForCurrentMode */
- (NSString *)rowTagAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)rowPositionsAtIndexPath:(NSIndexPath *)indexPath;
- (id)sectionContentsAtSection:(NSInteger)section;/**< Get section contents for section from cache, must use after the first time you reloadTableView and setNeedsReloadForMode or setNeedsReloadForCurrentMode */
- (id)sectionTagAtSection:(NSInteger)section;

#pragma mark indexPaths for touches or gesture recognizers
- (NSIndexPath *)indexPathForTouchEvent:(UIEvent *)event;/**< Get indexPath from a touch event */
- (NSIndexPath *)indexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;/**< Get indexPath for gestureRecognizer on subview in cell */

#pragma mark about UITableView
- (void)connectToTableView:(UITableView *)tableView;/**< Connect to tableView, must use before parseConfigFile */
- (void)scrollToLastCell:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;/**< Scrolls to the last cell for this tableView */
- (void)registerCellClass:(Class)cellClass;/**< Register cell to this tableView */

@end


#pragma mark -
/** delegate for AOZTableViewProvider, called when some UITableViewDataSource and UITableViewDelegate methods invoked. */
@protocol AOZTableViewProviderDelegate <NSObject>

@optional
#pragma mark delegates for cells
- (Class)tableViewProvider:(AOZTableViewProvider *)provider cellClassForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents isEmptyCell:(BOOL)isEmptyCell;/**< Returns cell class for cell at indexPath, return NULL if you don't want to the delegate determine the cell class. */
- (BOOL)tableViewProvider:(AOZTableViewProvider *)provider willSetCellForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cell:(UITableViewCell *)cell;/**< Invoked before the delegate cellForRowAtIndexPath and setContents (the AOZTableViewCell method), return YES if you want cellForRowAtIndexPath and setContents to be called, return NO if you don't want */
- (void)tableViewProvider:(AOZTableViewProvider *)provider cellForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cell:(UITableViewCell *)cell;/**< Invoked after cellForRowAtIndexPath, you have the chance to re-config this cell */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cellClass:(Class)cellClass;/**< Returns height for row at indexPath, if height you returned is minus, it will call heightForCell (the AOZTableViewCell method) to get cell height */
- (void)tableViewProvider:(AOZTableViewProvider *)provider willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's willDisplayCell method */
- (void)tableViewProvider:(AOZTableViewProvider *)provider didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's didEndDisplayingCell method */
- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's didSelectRowAtIndexPath method */

#pragma mark delegates for cell edit
- (BOOL)tableViewProvider:(AOZTableViewProvider *)provider canEditRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;
- (UITableViewCellEditingStyle)tableViewProvider:(AOZTableViewProvider *)provider editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;
- (void)tableViewProvider:(AOZTableViewProvider *)provider commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;

#pragma mark delegates for section headers and footers
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForHeaderInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's viewForFooterInSection method, if use this method, -h config will be ignored */
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForFooterInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's viewForFooterInSection method */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForHeaderInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's heightForHeaderInSection method, if use this method, -h config will be ignored */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForFooterInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's heightForFooterInSection method */
- (NSString *)tableViewProvider:(AOZTableViewProvider *)tableViewProvider titleForHeaderInSection:(NSInteger)section;

#pragma mark delegate: UITableViewDelegate: accessory actions
- (void)tableViewProvider:(AOZTableViewProvider *)provider accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

@end
