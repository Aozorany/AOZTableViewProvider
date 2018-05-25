//
//  ViewController.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "ViewController.h"

#import "AOZTableViewProvider.h"
#import "TableViewCell.h"
#import "TableViewCell2.h"


NSString *configString = @"\
section -s _multipleArray -c TableViewCell -t sectionTag\n\
    row -es subArray -ec TableViewCell\n\
section\n\
    row -c AOZTableViewSwitchCell\n\
    row -c AOZTableViewDetailCell";


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
//    _emptyArray = @[@[@"1", @"2", @"3", @"4", @"5"], @[@"1", @"2", @"3"]];
    _emptyArray = @[@[@{@"tag": @"id", @"title": @"ID"},
                      @{@"tag": @"name", @"title": @"昵称"}],
                    @[@{@"tag": @"sex", @"title": @"性别"},
                      @{@"tag": @"art", @"title": @"才艺"},
                      @{@"tag": @"city", @"title": @"城市"}],
                    @[@{@"tag": @"time", @"title": @"档期"},
                      @{@"tag": @"price", @"title": @"薪酬"},
                      @{@"tag": @"intro", @"title": @"简介"},
                      @{@"tag": @"award", @"title": @"获奖"}]];
    _multipleArray = @[@{@"name": @"section name 1"}, @{@"subArray": @[@"3", @"4", @"5"], @"name": @"section name 2"}];
    _dictionary = @{@"first": @"first dictionary value", @"second": @"second dictionary value", @"title": @"This is a dictionary"};
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //mainTableView
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect mainTableViewRect = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:mainTableViewRect style:UITableViewStyleGrouped];
    [self.view addSubview:mainTableView];
    
    //_tableViewProvider
//    _tableViewProvider = [[AOZTableViewProvider alloc] initWithFileName:@"ViewController.tableViewConfig" dataProvider:self tableView:mainTableView];
//    [_tableViewProvider parseConfigWithError:NULL];
//    _tableViewProvider.mode = 0;
//    [_tableViewProvider reloadTableView];
    
    _tableViewProvider = [[AOZTableViewProvider alloc] initWithConfigString:configString dataProvider:self tableView:mainTableView];
    [_tableViewProvider parseConfigWithError:nil];
    _tableViewProvider.delegate = self;
    _tableViewProvider.mode = 0;
    [_tableViewProvider reloadTableView];
    
    //changeSourceBtn
    UIBarButtonItem *changeSourceBtn = [[UIBarButtonItem alloc] initWithTitle:@"Change Source" style:UIBarButtonItemStyleDone target:self action:@selector(onChangeSourceBtnTouchUpInside)];
    self.navigationItem.rightBarButtonItem = changeSourceBtn;
}

#pragma mark delegate: AOZTableViewProviderDelegate
- (BOOL)tableViewProvider:(AOZTableViewProvider *)provider willSetCellForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cell:(UITableViewCell *)cell {
    if ([cell isKindOfClass:[AOZTableViewSwitchCell class]]) {
        ((AOZTableViewSwitchCell *) cell).textLabel.text = @"textLabel";
        [((AOZTableViewSwitchCell *) cell) setSwitchViewState:AOZTableViewSwitchCellStateOn];
        [((AOZTableViewSwitchCell *) cell) setSwitchViewOnTintColor:[UIColor purpleColor]];
        ((AOZTableViewSwitchCell *) cell).actionTarget = self;
        ((AOZTableViewSwitchCell *) cell).switchViewValueChangedAction = @selector(onCellSwitchValueChanged:event:);
    } else if ([cell isKindOfClass:[AOZTableViewDetailCell class]]) {
        ((AOZTableViewDetailCell *) cell).textLabel.text = @"textLabel";
        ((AOZTableViewDetailCell *) cell).detailTextLabel.text = @"detailTextLabel";
    }
    return YES;
}

- (CGFloat)tableViewProvider:(AOZTableViewProvider *)provider heightForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents cellClass:(Class)cellClass {
    if (cellClass == TableViewCell2.class) {
        return 88;
    }
    return -1;
}

- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    [_tableViewProvider.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark private: actions
- (void)onChangeSourceBtnTouchUpInside {
    _placeHolder = @"";
    _array = @[@"5", @"6", @"7", @"8", @"9"];
    _emptyArray = @[@[@{@"tag": @"id", @"title": @"ID"},
                      @{@"tag": @"name", @"title": @"昵称"}],
                    @[@{@"tag": @"sex", @"title": @"性别"},
                      @{@"tag": @"art", @"title": @"才艺"},
                      @{@"tag": @"city", @"title": @"城市"}],
                    @[@{@"tag": @"time", @"title": @"档期"},
                      @{@"tag": @"price", @"title": @"薪酬"},
                      @{@"tag": @"intro", @"title": @"简介"},
                      @{@"tag": @"award", @"title": @"获奖"}]];
    _multipleArray = @[@{@"subArray": @[@"4"], @"name": @"section name 4"}, @{@"subArray": @[@"5", @"6", @"7", @"8", @"9"], @"name": @"section name 5"}];
    _dictionary = @{@"first": @"first dictionary value changed", @"second": @"second dictionary value changed", @"title": @"This is a dictionary changed."};
    
    [_tableViewProvider setNeedsReloadForCurrentMode];
    [_tableViewProvider reloadTableView];
}

- (void)onCellSwitchValueChanged:(UISwitch *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [_tableViewProvider indexPathForTouchEvent:event];
    NSLog(@"%@, %d", indexPath, sender.on);
}

@end
