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
}

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableViewProvider = [[AOZTableViewProvider alloc] init];
    _tableViewProvider.configBundleFileName = @"ViewController.tableViewConfig";
    [_tableViewProvider connectToTableView:nil];
    
    NSError *error = nil;
    [_tableViewProvider parseConfigFile:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        [_tableViewProvider reloadTableView];
    }
}

@end
