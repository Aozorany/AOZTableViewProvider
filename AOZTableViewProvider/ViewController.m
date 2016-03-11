//
//  ViewController.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "ViewController.h"
#import "AOZTableViewProvider.h"


#pragma mark -
@interface ViewController () <AOZTableViewProviderDelegate>
@end


#pragma mark -
@implementation ViewController {
    AOZTableViewProvider *_tableViewProvider;
    NSArray *_multipleArray;
    NSArray *_array;
    NSArray *_emptyArray;
    NSDictionary *_dictionary;
    NSString *_placeHolder;
}

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _placeHolder = @"";
    _array = @[@"1", @"2", @"3", @"4", @"5"];
    _emptyArray = nil;
    _multipleArray = @[@{@"subArray": @[@"1"], @"name": @"section name 1"}, @{@"subArray": @[@"3", @"4", @"5"], @"name": @"section name 2"}];
    _dictionary = @{@"first": @"first dictionary value", @"second": @"second dictionary value"};
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //mainTableView
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect mainTableViewRect = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:mainTableViewRect style:UITableViewStyleGrouped];
    [self.view addSubview:mainTableView];
    
    //_tableViewProvider
    _tableViewProvider = [[AOZTableViewProvider alloc] initWithFileName:@"ViewController.tableViewConfig" dataProvider:self tableView:mainTableView];
    _tableViewProvider.delegate = self;
    [_tableViewProvider parseConfigFile:NULL];
    _tableViewProvider.mode = 2;
    [_tableViewProvider reloadTableView];
    
    //changeSourceBtn
    UIBarButtonItem *changeSourceBtn = [[UIBarButtonItem alloc] initWithTitle:@"Change Source" style:UIBarButtonItemStyleDone target:self action:@selector(onChangeSourceBtnTouchUpInside)];
    self.navigationItem.rightBarButtonItem = changeSourceBtn;
}

#pragma mark delegate: AOZTableViewProviderDelegate
- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    [_tableViewProvider.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark private: actions
- (void)onChangeSourceBtnTouchUpInside {
    _placeHolder = @"";
    _array = @[@"5", @"6", @"7", @"8", @"9"];
    _emptyArray = nil;
    _multipleArray = @[@{@"subArray": @[@"4"], @"name": @"section name 4"}, @{@"subArray": @[@"5", @"6", @"7", @"8", @"9"], @"name": @"section name 5"}];
    _dictionary = @{@"first": @"first dictionary value changed", @"second": @"second dictionary value changed"};
    
    [_tableViewProvider setNeedsReloadForCurrentMode];
    [_tableViewProvider reloadTableView];
}

@end
