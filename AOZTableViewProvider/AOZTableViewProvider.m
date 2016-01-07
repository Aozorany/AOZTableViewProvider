//
//  AOZTableViewProvider.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "AOZTableViewProvider.h"
#import "AOZTableViewProviderUtils.h"
#import "AOZTableViewConfigFileParser.h"


#pragma mark -
id collectionForIndex(NSArray *collectionsArray, NSInteger index);
id collectionForIndex(NSArray *collectionsArray, NSInteger index) {
    if (collectionsArray.count == 0 || index < 0) {
        return nil;
    }
    
    return nil;
}


#pragma mark -
@implementation AOZTableViewProvider {
    NSMutableArray<AOZTVPMode *> *_modesArray;
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

#pragma mark delegate: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    AOZTVPMode *currentMode = [self currentMode];
    if (currentMode == nil || currentMode.sectionCollectionsArray.count == 0) {
        return 0;
    }
    AOZTVPSectionCollection *lastSectionCollection = currentMode.sectionCollectionsArray.lastObject;
    return lastSectionCollection.sectionRange.location + lastSectionCollection.sectionRange.length;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark private: general
- (AOZTVPMode *)currentMode {
    if (_mode < 0 || _mode >= _modesArray.count) {
        return nil;
    }
    return _modesArray[_mode];
}

#pragma mark public: general
- (BOOL)parseConfigFile:(NSError **)pError {
    if (_configBundleFileName.length == 0) {
        return NO;
    }
    
    //检查配置文件存在性
    NSString *configFileName = [_configBundleFileName stringByDeletingPathExtension];
    NSString *configFileExtention = [_configBundleFileName pathExtension];
    if (configFileExtention.length == 0) {
        configFileExtention = @"tableViewConfig";
    }
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:configFileName ofType:configFileExtention];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]) {
        if (pError) {
            *pError = [NSError errorWithDomain:AOZTableViewProviderErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"配置文件不存在"}];
        }
        return NO;
    }
    
    //解析配置文件
    AOZTableViewConfigFileParser *parser = [[AOZTableViewConfigFileParser alloc] initWithFilePath:configFilePath];
    parser.dataProvider = _dataProvider;
    NSArray *newModesArray = [parser parseFile:pError];
    
    if (*pError) {
        return NO;
    }
    
    [_modesArray removeAllObjects];
    [_modesArray addObjectsFromArray:newModesArray];
    
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
