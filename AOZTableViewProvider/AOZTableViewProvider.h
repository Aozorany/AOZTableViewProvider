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
@property (nonatomic, readonly) UITableView *tableView;/**< The tableView connected with this provider, use connectToTableView to set this value. */
@property (nonatomic, assign) id dataProvider;/**< Tells this provider where to find values */
@property (nonatomic, assign) NSInteger mode;/**< Current mode index for this provider */
@property (nonatomic, assign) id<AOZTableViewProviderDelegate> delegate;/**< Delegate for this provider */
@property (nonatomic, assign) id<UIScrollViewDelegate> scrollViewDelegate;/**< ScrollViewDelegate associated with this tableView */
- (instancetype)initWithFileName:(NSString *)fileName dataProvider:(id)dataProvider tableView:(UITableView *)tableView;/**< Create a new instance for this provider, with fileName, dataProvider and tableView established. */
- (BOOL)parseConfigFile:(NSError **)pError;/**< Parse config file, must use after connectToTableView, if any error occurs, return it within pError, pError could be nil */
- (void)connectToTableView:(UITableView *)tableView;/**< Connect to tableView, must use before parseConfigFile */
- (void)reloadTableView;/**< Reload tableView, if dataSource has changed, use it after setNeedsReloadForCurrentMode or setNeedsReloadForMode */
- (void)setNeedsReloadForMode:(int)mode;/**< Use before reloadTableView, tells this provider to re-compute sections and rows for mode before loading, invoked when dataSource is changed. If mode is not exist, do nothing */
- (void)setNeedsReloadForCurrentMode;/**< Use before reloadTableView, tells this provider to re-compute sections and rows before loading for current mode. invoked when dataSource is changed. */
- (void)setNeedsReloadForAllModes;/**< Use before reloadTableView, tells this provider to re-compute sections and rows for all modes before loading, invoked when dataSource is changed. */
- (id)rowContentsAtIndexPath:(NSIndexPath *)indexPath;/**< Get row contents for indexPath from cache, must use after the first time you reloadTableView and setNeedsReloadForMode or setNeedsReloadForCurrentMode */
- (id)sectionContentsAtSection:(NSInteger)section;/**< Get section contents for section from cache, must use after the first time you reloadTableView and setNeedsReloadForMode or setNeedsReloadForCurrentMode */
- (NSIndexPath *)indexPathForTouchEvent:(UIEvent *)event;
- (NSIndexPath *)indexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
@end


#pragma mark -
/** delegate for AOZTableViewProvider, called when some UITableViewDataSource and UITableViewDelegate methods invoked. */
@protocol AOZTableViewProviderDelegate <NSObject>
@optional
- (void)tableViewProvider:(AOZTableViewProvider *)provider cellForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cell:(UITableViewCell *)cell;/**< Invoked after cellForRowAtIndexPath, you have the chance to re-config this cell */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cellClass:(Class)cellClass;
- (void)tableViewProvider:(AOZTableViewProvider *)provider willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's willDisplayCell method */
- (void)tableViewProvider:(AOZTableViewProvider *)provider didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's didEndDisplayingCell method */
- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents;/**< Invoked in tableViewDelegate's didSelectRowAtIndexPath method */
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForHeaderInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's viewForFooterInSection method, if use this method, -h config will be ignored */
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForFooterInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's viewForFooterInSection method */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForHeaderInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's heightForHeaderInSection method, if use this method, -h config will be ignored */
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForFooterInSection:(NSInteger)section;/**< Invoked in tableViewDelegate's heightForFooterInSection method */
@end
