//
//  AOZTableViewProvider.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "AOZTableViewProvider.h"


@implementation AOZTableViewProvider {
    NSMutableArray *_modesArray;
    NSMutableDictionary *_currentConfigDictionary;
}

#pragma mark lifeCircle
- (instancetype)init {
    self = [super init];
    if (self) {
        _modesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark public: general
- (BOOL)parseConfigFile:(NSError **)pError {
    if (_configFileUrl == nil) {
        return NO;
    }
    
    return YES;
}

- (void)connectToTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)reloadTableView {
    
}

@end
