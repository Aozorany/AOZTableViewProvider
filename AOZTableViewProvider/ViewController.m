//
//  ViewController.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "ViewController.h"
#import "AOZTableViewProvider.h"


@implementation ViewController {
    AOZTableViewProvider *_tableViewProvider;
    NSArray *_array;
    NSArray *_array2;
    NSDictionary *_dictionary;
}

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _array = @[@"1", @"2", @"3", @"4", @"5"];
    _array2 = @[@"1", @"2", @"3", @"4", @"5"];
    _dictionary = @{@"first": @"first dictionary value", @"second": @"second dictionary value"};
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //mainTableView
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect mainTableViewRect = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:mainTableViewRect style:UITableViewStyleGrouped];
    [self.view addSubview:mainTableView];
    
    //_tableViewProvider
    _tableViewProvider = [[AOZTableViewProvider alloc] init];
    _tableViewProvider.configBundleFileName = @"ViewController.tableViewConfig";
    _tableViewProvider.dataProvider = self;
    [_tableViewProvider connectToTableView:mainTableView];
    
    NSError *error = nil;
    [_tableViewProvider parseConfigFile:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        [_tableViewProvider reloadDataAndTableView];
    }
}

@end
