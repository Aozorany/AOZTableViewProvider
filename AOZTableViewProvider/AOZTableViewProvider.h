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
/** UITableView的数据源与部分代理提供器, init - configFileUrl - parseConfigFile - connectToTableView - reloadTableView */
@interface AOZTableViewProvider : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSString *configBundleFileName;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, assign) id dataProvider;
@property (nonatomic, assign) NSInteger mode;
@property (nonatomic, assign) id<AOZTableViewProviderDelegate> delegate;
- (instancetype)initWithFileName:(NSString *)fileName dataProvider:(id)dataProvider tableView:(UITableView *)tableView;
- (BOOL)parseConfigFile:(NSError **)pError;
- (void)connectToTableView:(UITableView *)tableView;
- (void)reloadTableView;
- (void)reloadData;
- (void)reloadDataAndTableView;
@end


#pragma mark -
@protocol AOZTableViewProviderDelegate <NSObject>
@optional
- (void)tableViewProvider:(AOZTableViewProvider *)provider cellForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cell:(UITableViewCell *)cell;
- (void)tableViewProvider:(AOZTableViewProvider *)provider willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewProvider:(AOZTableViewProvider *)provider didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableViewProvider:(AOZTableViewProvider *)provider viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForFooterInSection:(NSInteger)section;
@end
