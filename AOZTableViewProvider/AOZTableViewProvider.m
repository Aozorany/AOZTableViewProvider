//
//  AOZTableViewProvider.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "AOZTableViewProvider.h"
#import <objc/runtime.h>

#import "AOZTableViewCell.h"
#import "AOZTableViewConfigFileParser.h"
#import "AOZTableViewDefaultConfigFileParserAddons.h"
#import "AOZTableViewProviderUtils.h"


static int _CACHE_TYPE_ROW_CONTENTS = 0;/**< 缓存类型：row里面的内容 */
static int _CACHE_TYPE_SECTION_CONTENTS = 1;/**< 缓存类型：section里面的内容 */
static int _CACHE_TYPE_CELL_CLASS = 2;/**< 缓存类型：row cell，它的值是class对应的string */
static int _CACHE_TYPE_ROW_CONTENTS_EMPTY_FLAG = 3;/**< 缓存类型：row里面的内容是否为空，是一个NSNumber with bool值 */
static int _CACHE_TYPE_CELL_POSITION = 4;/**< 缓存类型：cell position */
static int _CACHE_TYPE_CELL_TAG = 5;/**< 缓存类型：cell tag，如果没有内容则为NSNull，有内容则为NSString */
static int _CACHE_TYPE_SECTION_TAG = 6;/**< 缓存类型：section tag，如果没有内容则为NSNull，有内容则为NSString */


typedef NS_ENUM(NSInteger, _AOZTableViewProviderType) {
  _AOZTableViewProviderTypeString,
  _AOZTableViewProviderTypeData,
};


#pragma mark -
/** Turple with 4 elements */
@interface AOZTurple5 : NSObject
@property (nonatomic, strong) id first;
@property (nonatomic, strong) id second;
@property (nonatomic, strong) id third;
@property (nonatomic, strong) id forth;
@property (nonatomic, strong) id fifth;
@end


#pragma mark -
@implementation AOZTurple5
@end


#pragma mark -
/** 根据parentCollection和index取得对应位置的下属collection<br>
 具体来说，如果parentCollection是mode，则返回sectionCollection<br>
 如果parentCollection是section，则返回rowCollection<br>
 其他情况都返回空 */
id _collectionForIndex(id parentCollection, NSInteger index);
id _collectionForIndex(id parentCollection, NSInteger index) {
  if ((![parentCollection isKindOfClass:[AOZTVPSectionCollection class]] && ![parentCollection isKindOfClass:[AOZTVPMode class]])
      || index < 0) {//如果parentCollection不是sectionCollection，也不是mode，而且index不合法，则返回空
    return nil;
  }
  
  if ([parentCollection isKindOfClass:[AOZTVPSectionCollection class]]) {
    AOZTVPSectionCollection *sectionCollection = (AOZTVPSectionCollection *) parentCollection;
    if (sectionCollection.rowCollectionsArray.count == 0) {
      return nil;
    }
    for (AOZTVPRowCollection *rowCollection in sectionCollection.rowCollectionsArray) {
      if (NSLocationInRange(index, rowCollection.rowRange)) {
        return rowCollection;
      }
    }
  } else if ([parentCollection isKindOfClass:[AOZTVPMode class]]) {
    AOZTVPMode *mode = (AOZTVPMode *) parentCollection;
    if (mode.sectionCollectionsArray.count == 0) {
      return nil;
    }
    for (AOZTVPSectionCollection *sectionCollection in mode.sectionCollectionsArray) {
      if (NSLocationInRange(index, sectionCollection.sectionRange)) {
        return sectionCollection;
      }
    }
  }//end for mode and section
  
  //其他情况：找不到，或者又不是mode也不是section，则直接返回空
  return nil;
}


#pragma mark -
@implementation AOZTableViewProvider {
  NSMutableArray<AOZTVPMode *> *_modesArray;
  NSMutableDictionary *_cacheDictionary;/**< 缓存字典，key是NSIndexPath with row: mode index, section: 0, value是NSMutableDictionary */
}

#pragma mark lifeCircle
- (instancetype)init {
  self = [super init];
  if (self) {
    _modesArray = [[NSMutableArray alloc] init];
    _cacheDictionary = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (instancetype)initWithFileName:(NSString *)fileName dataProvider:(id)dataProvider tableView:(UITableView *)tableView {
  self = [super init];
  if (self) {
    _modesArray = [[NSMutableArray alloc] init];
    _cacheDictionary = [[NSMutableDictionary alloc] init];
    self.dataProvider = dataProvider;
    self.configBundleFileName = fileName;
    [self connectToTableView:tableView];
  }
  return self;
}

- (instancetype)initWithConfigString:(NSString *)config dataProvider:(id)dataProvider tableView:(UITableView *)tableView {
  self = [super init];
  if (self) {
    _modesArray = [[NSMutableArray alloc] init];
    _cacheDictionary = [[NSMutableDictionary alloc] init];
    self.dataProvider = dataProvider;
    self.configString = config;
    [self connectToTableView:tableView];
  }
  return self;
}

#pragma mark delegate: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSInteger sectionCount = 0;
  AOZTVPMode *currentMode = [self _currentMode];
  AOZTVPSectionCollection *lastSectionCollection = currentMode.sectionCollectionsArray.lastObject;
  sectionCount = lastSectionCollection.sectionRange.location + lastSectionCollection.sectionRange.length;
  return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger rowCount = 0;
  AOZTVPMode *currentMode = [self _currentMode];
  AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, section);
  AOZTVPSectionCollection *newSectionCollection = nil;
  if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]] && sectionCollection.dataConfig.elementsPerRow == 1) {
    //如果section的source是array，极有可能出现其下属的某一个row的行数不等的情况，所以需要根据当前的section对应的那个元素重新计算row的布局
    newSectionCollection = [sectionCollection copy];
    if ([newSectionCollection.dataConfig.source count] > 0) {
      [newSectionCollection reloadRowsWithSectionElement:((NSArray *) newSectionCollection.dataConfig.source)[section - newSectionCollection.sectionRange.location]];
    } else {
      [newSectionCollection reloadRowsWithSectionElement:nil];
    }
  } else {
    newSectionCollection = sectionCollection;
  }
  //取出newSectionCollection最后一个row，并计算其尾标，这就是这个section对应的row的数量
  AOZTVPRowCollection *lastRowCollection = newSectionCollection.rowCollectionsArray.lastObject;
  rowCount = lastRowCollection.rowRange.location + lastRowCollection.rowRange.length;
  return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AOZTurple5 *contentsTurple = [self _rowContentsAtIndexPath:indexPath];
  id contents = contentsTurple.first;
  NSString *cellClassStr = contentsTurple.second;
  NSInteger cellPositions = [contentsTurple.forth integerValue];
  NSString *cellTag = contentsTurple.fifth;
  
  AOZTableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:cellClassStr];
  
  if ([_delegate respondsToSelector:@selector(tableViewProvider:willSetCellForRowAtIndexPath:contents:cell:)]) {
    BOOL shouldContinue = [_delegate tableViewProvider:self willSetCellForRowAtIndexPath:indexPath contents:contents cell:cell];
    if (!shouldContinue) { return cell;}
  }
  
  if ([cell respondsToSelector:@selector(setContents:positions:indexPath:tag:)]) {
    [cell setContents:contents positions:cellPositions indexPath:indexPath tag:cellTag];
  } else if ([cell respondsToSelector:@selector(setContents:)]) {
    [cell setContents:contents];
  }
  
  if ([_delegate respondsToSelector:@selector(tableViewProvider:cellForRowAtIndexPath:contents:cell:)]) {
    [_delegate tableViewProvider:self cellForRowAtIndexPath:indexPath contents:contents cell:cell];
  }
  
  return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:titleForHeaderInSection:)]) {
    return [_delegate tableViewProvider:self titleForHeaderInSection:section];
  }
  return nil;
}

#pragma mark delegate: UITableViewDataSource for cell editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:canEditRowAtIndexPath:contents:)]) {
    id contents = [self rowContentsAtIndexPath:indexPath];
    return [_delegate tableViewProvider:self canEditRowAtIndexPath:indexPath contents:contents];
  }
  return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:commitEditingStyle:forRowAtIndexPath:contents:)]) {
    id contents = [self rowContentsAtIndexPath:indexPath];
    [_delegate tableViewProvider:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath contents:contents];
  }
}

#pragma mark delegate: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  AOZTurple5 *contentsTurple = [self _rowContentsAtIndexPath:indexPath];
  id contents = contentsTurple.first;
  NSString *cellClassStr = contentsTurple.second;
  Class cellClass = (cellClassStr.length > 0? NSClassFromString(cellClassStr): NULL);
  NSInteger cellPositions = [contentsTurple.forth integerValue];
  CGFloat height = 0;
  NSString *tag = contentsTurple.fifth;
  
  //如果有代理，则先从代理查询
  if ([_delegate respondsToSelector:@selector(tableViewProvider:heightForRowAtIndexPath:contents:cellClass:)]) {
    height = [_delegate tableViewProvider:self heightForRowAtIndexPath:indexPath contents:contents cellClass:cellClass];
    if (height >= 0) { return height; }
  }
  
  //向cellClass本身查询单元格高度
  if ([((id) cellClass) respondsToSelector:@selector(heightForCell:positions:indexPath:tag:)]) {
    NSMethodSignature *signiture = [cellClass methodSignatureForSelector:@selector(heightForCell:positions:indexPath:tag:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signiture];
    [invocation setTarget:cellClass];
    [invocation setSelector:@selector(heightForCell:positions:indexPath:tag:)];
    if (contents) {
      [invocation setArgument:&contents atIndex:2];
    }
    [invocation setArgument:&cellPositions atIndex:3];
    [invocation setArgument:&indexPath atIndex:4];
    if (tag) {
      [invocation setArgument:&tag atIndex:5];
    }
    [invocation retainArguments];
    [invocation invoke];
    [invocation getReturnValue:&height];
  } else if ([((id) cellClass) respondsToSelector:@selector(heightForCell:)]) {
    NSMethodSignature *signiture = [cellClass methodSignatureForSelector:@selector(heightForCell:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signiture];
    [invocation setTarget:cellClass];
    [invocation setSelector:@selector(heightForCell:)];
    if (contents) {
      [invocation setArgument:&contents atIndex:2];
    }
    [invocation retainArguments];
    [invocation invoke];
    [invocation getReturnValue:&height];
  }
  
  return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell respondsToSelector:@selector(willDisplayCell:positions:indexPath:tag:)]) {
    AOZTurple5 *contentsTurple = [self _rowContentsAtIndexPath:indexPath];
    id contents = contentsTurple.first;
    NSInteger cellPositions = [contentsTurple.forth integerValue];
    NSString *tag = contentsTurple.fifth;
    [((AOZTableViewCell *) cell) willDisplayCell:contents positions:cellPositions indexPath:indexPath tag:tag];
  } else if ([cell respondsToSelector:@selector(willDisplayCell)]) {
    [((AOZTableViewCell *) cell) willDisplayCell];
  }
  if ([_delegate respondsToSelector:@selector(tableViewProvider:willDisplayCell:forRowAtIndexPath:contents:)]) {
    [_delegate tableViewProvider:self willDisplayCell:cell forRowAtIndexPath:indexPath contents:[self _contentAtIndexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS]];
  }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:didEndDisplayingCell:forRowAtIndexPath:contents:)]) {
    [_delegate tableViewProvider:self didEndDisplayingCell:cell forRowAtIndexPath:indexPath contents:[self _contentAtIndexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS]];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:didSelectRowAtIndexPath:contents:)]) {
    [_delegate tableViewProvider:self didSelectRowAtIndexPath:indexPath contents:[self _contentAtIndexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS]];
  }
}

#pragma mark delegate: UITableViewDelegate cell editing
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:editingStyleForRowAtIndexPath:contents:)]) {
    id contents = [self rowContentsAtIndexPath:indexPath];
    return [_delegate tableViewProvider:self editingStyleForRowAtIndexPath:indexPath contents:contents];
  }
  return UITableViewCellEditingStyleNone;
}

#pragma mark delegate: UITableViewDelegate section headers and footers
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  AOZTVPMode *currentMode = [self _currentMode];
  AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, section);
  if (sectionCollection.headerClass) {
    id contents = [self sectionContentsAtSection:section];
    AOZTableViewHeaderFooterView *headerView = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(sectionCollection.headerClass)];
    [headerView setContents:contents];
    return headerView;
  } else if ([_delegate respondsToSelector:@selector(tableViewProvider:viewForHeaderInSection:)]) {
    return [_delegate tableViewProvider:self viewForHeaderInSection:section];
  }
  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:viewForFooterInSection:)]) {
    return [_delegate tableViewProvider:self viewForFooterInSection:section];
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  AOZTVPMode *currentMode = [self _currentMode];
  AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, section);
  if (sectionCollection.headerClass) {
    id contents = [self sectionContentsAtSection:section];
    
    NSMethodSignature *signiture = [sectionCollection.headerClass methodSignatureForSelector:@selector(heightForView:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signiture];
    [invocation setTarget:sectionCollection.headerClass];
    [invocation setSelector:@selector(heightForView:)];
    if (contents) {
      [invocation setArgument:&contents atIndex:2];
    }
    CGFloat height = 0;
    [invocation retainArguments];
    [invocation invoke];
    [invocation getReturnValue:&height];
    
    return height;
  } else if ([_delegate respondsToSelector:@selector(tableViewProvider:heightForHeaderInSection:)]) {
    return [_delegate tableViewProvider:self heightForHeaderInSection:section];
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:heightForFooterInSection:)]) {
    return [_delegate tableViewProvider:self heightForFooterInSection:section];
  }
  return 0;
}

#pragma mark delegate: UITableViewDelegate: accessory actions
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if ([_delegate respondsToSelector:@selector(tableViewProvider:accessoryButtonTappedForRowWithIndexPath:)]) {
    [_delegate tableViewProvider:self accessoryButtonTappedForRowWithIndexPath:indexPath];
  }
}

#pragma mark delegate: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [_scrollViewDelegate scrollViewDidScroll:scrollView];
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
    [_scrollViewDelegate scrollViewWillBeginDragging:scrollView];
  }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
    [_scrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
    [_scrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
    return [_scrollViewDelegate scrollViewShouldScrollToTop:scrollView];
  }
  return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
    [_scrollViewDelegate scrollViewDidScrollToTop:scrollView];
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
    [_scrollViewDelegate scrollViewWillBeginDecelerating:scrollView];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
    [_scrollViewDelegate scrollViewDidEndDecelerating:scrollView];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if ([_scrollViewDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
    [_scrollViewDelegate scrollViewDidEndScrollingAnimation:scrollView];
  }
}

#pragma mark private: general
- (AOZTVPMode *)_currentMode {
  if (_mode < 0 || _mode >= _modesArray.count) {
    return nil;
  }
  AOZTVPMode *currentMode = _modesArray[_mode];
  if (currentMode.needsReload) {
    [self _removeAllCachesForMode:_mode];
    [currentMode rebindSourceWithDataProvider:_dataProvider];//重新绑定数据
    [currentMode reloadSections];//重新计算sectionRange和rowRange
    currentMode.needsReload = NO;
  }
  return currentMode;
}

- (AOZTurple5 *)_rowContentsAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellClassStr = [self _contentAtIndexPath:indexPath type:_CACHE_TYPE_CELL_CLASS];
  Class cellClass = (cellClassStr.length > 0? NSClassFromString(cellClassStr): NULL);
  id contents = [self _contentAtIndexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS];
  BOOL contentsEmptyFlag = [[self _contentAtIndexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS_EMPTY_FLAG] boolValue];
  NSInteger cellPositions = [[self _contentAtIndexPath:indexPath type:_CACHE_TYPE_CELL_POSITION] integerValue];
  NSString *cellTag = [self _contentAtIndexPath:indexPath type:_CACHE_TYPE_CELL_TAG];
  
  if ((!contentsEmptyFlag && contents == nil) || cellClass == NULL) {
    //如果从缓存里面读不到结果，则重新生成
    contents = [NSNull null];
    
    NSInteger cellPosition_section = AOZTableViewCellPositionNormal;
    NSInteger numberOfRows = [self tableView:_tableView numberOfRowsInSection:indexPath.section];
    if (numberOfRows == 1) {
      cellPosition_section = AOZTableViewCellPositionOnly;
    } else if (indexPath.row == 0) {
      cellPosition_section = AOZTableViewCellPositionTop;
    } else if (indexPath.row == numberOfRows - 1) {
      cellPosition_section = AOZTableViewCellPositionBotton;
    }
    
    NSInteger cellPosition_part = AOZTableViewCellPositionNormal;
    
    AOZTVPMode *currentMode = [self _currentMode];
    AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, indexPath.section);
    AOZTVPSectionCollection *newSectionCollection = nil;
    if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]] && sectionCollection.dataConfig.elementsPerRow == 1) {
      newSectionCollection = [sectionCollection copy];
      if ([sectionCollection.dataConfig.source count] > 0) {
        [newSectionCollection reloadRowsWithSectionElement:((NSArray *) newSectionCollection.dataConfig.source)[indexPath.section - newSectionCollection.sectionRange.location]];
      } else {
        [newSectionCollection reloadRowsWithSectionElement:nil];
      }
    } else {
      newSectionCollection = sectionCollection;
    }
    AOZTVPRowCollection *rowCollection = _collectionForIndex(newSectionCollection, indexPath.row);
    
    if (![rowCollection.dataConfig.source isEqual:[NSNull null]]) {
      //如果在row里面设置了数据源，则使用row的设置
      if ([rowCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
        //如果数据源是array
        if ([rowCollection.dataConfig.source count] > 0) {
          //如果array里面有数据
          if (rowCollection.dataConfig.elementsPerRow < 0) {
            //全部数据都在一个单元格的情况
            contents = rowCollection.dataConfig.source;
            cellPosition_part = AOZTableViewCellPositionPartOnly;
          } else if (rowCollection.dataConfig.elementsPerRow == 0 || rowCollection.dataConfig.elementsPerRow == 1) {
            //每个单元格只有一个元素的情况
            contents = ((NSArray *) rowCollection.dataConfig.source)[indexPath.row - rowCollection.rowRange.location];
            if (rowCollection.rowRange.length == 1) {
              cellPosition_part = AOZTableViewCellPositionPartOnly;;
            } else if (indexPath.row == rowCollection.rowRange.location) {
              cellPosition_part = AOZTableViewCellPositionPartTop;
            } else if (indexPath.row == rowCollection.rowRange.location + rowCollection.rowRange.length - 1) {
              cellPosition_part = AOZTableViewCellPositionPartBotton;
            } else {
              cellPosition_part = AOZTableViewCellPositionNormal;
            }
          } else {
            //每个单元格有多个元素的情况
            NSRange subRange = NSMakeRange((indexPath.row - rowCollection.rowRange.location) * rowCollection.dataConfig.elementsPerRow, rowCollection.dataConfig.elementsPerRow);
            if (subRange.location + subRange.length >= ((NSArray *) rowCollection.dataConfig.source).count) {
              subRange.length = ((NSArray *) rowCollection.dataConfig.source).count - subRange.location;
            }
            contents = [((NSArray *) rowCollection.dataConfig.source) subarrayWithRange:subRange];
            
            if (rowCollection.rowRange.length == 1) {
              cellPosition_part = AOZTableViewCellPositionPartOnly;;
            } else if (indexPath.row == rowCollection.rowRange.location) {
              cellPosition_part = AOZTableViewCellPositionPartTop;
            } else if (indexPath.row == rowCollection.rowRange.location + rowCollection.rowRange.length - 1) {
              cellPosition_part = AOZTableViewCellPositionPartBotton;
            } else {
              cellPosition_part = AOZTableViewCellPositionNormal;
            }
          }
          contentsEmptyFlag = NO;
        } else {
          //如果array里面没有数据
          contentsEmptyFlag = YES;
          cellPosition_part = AOZTableViewCellPositionPartOnly;
        }
      } else {
        //如果数据源不是array
        contents = rowCollection.dataConfig.source;
        contentsEmptyFlag = (contents == nil);
        cellPosition_part = AOZTableViewCellPositionPartOnly;
      }
    } else if (![sectionCollection.dataConfig.source isEqual:[NSNull null]]) {
      //如果在section里面设置了数据源，则使用section的设置
      if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
        //如果数据源是array
        if ([sectionCollection.dataConfig.source count] > 0) {
          //如果array里面有数据
          if (sectionCollection.dataConfig.elementsPerRow < 0) {
            //全部数据都在一个单元格的情况
            contents = sectionCollection.dataConfig.source;
            cellPosition_part = AOZTableViewCellPositionPartOnly;
          } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {
            //每个单元格只有一个元素的情况
            contents = ((NSArray *) sectionCollection.dataConfig.source)[indexPath.section - sectionCollection.sectionRange.location];
            if (sectionCollection.sectionRange.length == 1) {
              cellPosition_part = AOZTableViewCellPositionPartOnly;
            } else if (indexPath.row == sectionCollection.sectionRange.location) {
              cellPosition_part = AOZTableViewCellPositionPartTop;
            } else if (indexPath.row == sectionCollection.sectionRange.location + sectionCollection.sectionRange.length - 1) {
              cellPosition_part = AOZTableViewCellPositionPartBotton;
            } else {
              cellPosition_part = AOZTableViewCellPositionNormal;
            }
          } else {
            //每个单元格有多个元素的情况
            NSRange subRange = NSMakeRange((indexPath.section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
            if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
              subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
            }
            contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
            
            if (sectionCollection.sectionRange.length == 1) {
              cellPosition_part = AOZTableViewCellPositionPartOnly;
            } else if (indexPath.row == sectionCollection.sectionRange.location) {
              cellPosition_part = AOZTableViewCellPositionPartTop;
            } else if (indexPath.row == sectionCollection.sectionRange.location + sectionCollection.sectionRange.length - 1) {
              cellPosition_part = AOZTableViewCellPositionPartBotton;
            } else {
              cellPosition_part = AOZTableViewCellPositionNormal;
            }
          }
          contentsEmptyFlag = NO;
        } else {
          //如果array里面没有数据
          contentsEmptyFlag = YES;
          cellPosition_part = AOZTableViewCellPositionPartOnly;
        }
      } else {
        //如果数据源不是array
        contents = sectionCollection.dataConfig.source;
        contentsEmptyFlag = (contents == nil);
        cellPosition_part = AOZTableViewCellPositionPartOnly;
      }
    }
    if ([rowCollection.dataConfig.tag isKindOfClass:[NSString class]] && rowCollection.dataConfig.tag.length > 0) {
      cellTag = rowCollection.dataConfig.tag;
    } else if ([sectionCollection.dataConfig.tag isKindOfClass:[NSString class]] && sectionCollection.dataConfig.tag.length > 0) {
      cellTag = sectionCollection.dataConfig.tag;
    } else if ([rowCollection.elementSourceKey isKindOfClass:[NSString class]] && rowCollection.elementSourceKey.length > 0) {
      cellTag = rowCollection.elementSourceKey;
    } else if ([rowCollection.dataConfig.sourceKey isKindOfClass:[NSString class]] && rowCollection.dataConfig.sourceKey.length > 0) {
      cellTag = rowCollection.dataConfig.sourceKey;
    } else if ([sectionCollection.dataConfig.sourceKey isKindOfClass:[NSString class]] && sectionCollection.dataConfig.sourceKey.length > 0) {
      cellTag = sectionCollection.dataConfig.sourceKey;
    }
    
    //将取到的结果放入缓存，并记录cellClass和cellClassStr
    [self _setContent:contents indexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS];
    [self _setContent:@(contentsEmptyFlag) indexPath:indexPath type:_CACHE_TYPE_ROW_CONTENTS_EMPTY_FLAG];
    [self _setContent:cellTag indexPath:indexPath type:_CACHE_TYPE_CELL_TAG];
    [self _setContent:NSStringFromClass(contentsEmptyFlag? rowCollection.dataConfig.emptyCellClass: rowCollection.dataConfig.cellClass) indexPath:indexPath type:_CACHE_TYPE_CELL_CLASS];
    if ([_delegate respondsToSelector:@selector(tableViewProvider:cellClassForRowAtIndexPath:contents:isEmptyCell:)]) {
      cellClass = [_delegate tableViewProvider:self cellClassForRowAtIndexPath:indexPath contents:contents isEmptyCell:contentsEmptyFlag];
      if (![cellClass conformsToProtocol:@protocol(AOZTableViewCell)] && !checkClassRelation(cellClass, [UITableViewCell class])) { cellClass = NULL; }
    }
    if (cellClass == NULL) {
      cellClass = (contentsEmptyFlag? rowCollection.dataConfig.emptyCellClass: rowCollection.dataConfig.cellClass);
    } else {
      [self registerCellClass:cellClass];
    }
    cellClassStr = NSStringFromClass(cellClass);
    [self _setContent:cellClassStr indexPath:indexPath type:_CACHE_TYPE_CELL_CLASS];
    
    cellPositions = (cellPosition_section | cellPosition_part);
    [self _setContent:@(cellPositions) indexPath:indexPath type:_CACHE_TYPE_CELL_POSITION];
  }
  
  AOZTurple5 *result = [[AOZTurple5 alloc] init];
  result.first = contents;
  result.second = cellClassStr;
  result.third = @(contentsEmptyFlag);
  result.forth = @(cellPositions);
  result.fifth = cellTag;
  return result;
}

#pragma mark private: cache
/** 取出当前mode下，某个indexPath对应的内容 */
- (id)_contentAtIndexPath:(NSIndexPath *)indexPath type:(int)cacheType {
  if (indexPath == nil) { return nil; }
  NSMutableDictionary *detailsDictionary = _cacheDictionary[[NSString stringWithFormat:@"%d-%zd", cacheType, _mode]];
  return detailsDictionary[[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
}

/** 在当前mode下，将某个indexPath对应的内容存入缓存 */
- (void)_setContent:(id<NSCopying>)content indexPath:(NSIndexPath *)indexPath type:(int)cacheType {
  if (content == nil || indexPath == nil) { return; }
  
  NSString *cacheKey = [NSString stringWithFormat:@"%d-%zd", cacheType, _mode];
  NSMutableDictionary *detailsDictionary = _cacheDictionary[cacheKey];
  if (detailsDictionary == nil) {
    detailsDictionary = [[NSMutableDictionary alloc] init];
    _cacheDictionary[cacheKey] = detailsDictionary;
  }
  detailsDictionary[[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]] = content;
}

/** 为某个mode移除全部缓存 */
- (void)_removeAllCachesForMode:(NSInteger)mode {
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_ROW_CONTENTS, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_SECTION_CONTENTS, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_CELL_CLASS, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_ROW_CONTENTS_EMPTY_FLAG, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_CELL_POSITION, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_CELL_TAG, mode]];
  [_cacheDictionary removeObjectForKey:[NSString stringWithFormat:@"%d-%zd", _CACHE_TYPE_SECTION_TAG, mode]];
}

#pragma mark public: parse config
- (BOOL)parseConfigFile:(NSError **)pError {
  return [self parseConfigWithError:pError];
}

- (BOOL)parseConfigWithError:(NSError **)pError {
  if (_configBundleFileName.length == 0 && _configString.length == 0) {
    return NO;
  }
  
  //检查配置文件存在性
  AOZTableViewConfigFileParser *parser = nil;
  if (_configBundleFileName.length > 0) {
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
    
    //解析配置文件，如果发生解析错误则返回
    parser = [[AOZTableViewConfigFileParser alloc] initWithFilePath:configFilePath];
  } else if (_configString.length > 0) {
    parser = [[AOZTableViewConfigFileParser alloc] initWithString:_configString];
  }
  
  __autoreleasing NSError *configParserError = nil;
  parser.dataProvider = _dataProvider;
  parser.tableView = _tableView;
  NSArray *newModesArray = [parser parseConfigWithError:&configParserError];
  if (configParserError) {
    if (pError) {
      *pError = configParserError;
    }
    return NO;
  }
  
  //将结果装入_modesArray中
  [_modesArray removeAllObjects];
  [_modesArray addObjectsFromArray:newModesArray];
  
  //注册默认cellClass
  [_tableView registerClass:[AOZTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AOZTableViewCell class])];
  
  return YES;
}

#pragma mark public: reload
- (void)reloadTableView {
  [_tableView reloadData];
}

- (void)setNeedsReloadForMode:(int)mode {
  if (mode < 0 || mode >= _modesArray.count) {
    return;
  }
  AOZTVPMode *theMode = _modesArray[mode];
  theMode.needsReload = YES;
}

- (void)setNeedsReloadForCurrentMode {
  AOZTVPMode *theMode = [self _currentMode];
  theMode.needsReload = YES;
}

- (void)setNeedsReloadForAllModes {
  for (AOZTVPMode *aMode in _modesArray) {
    aMode.needsReload = YES;
  }
}

#pragma mark public: row and section contents
- (id)rowContentsAtIndexPath:(NSIndexPath *)indexPath {
  return [self _rowContentsAtIndexPath:indexPath].first;
}

- (NSString *)rowTagAtIndexPath:(NSIndexPath *)indexPath {
  return [self _rowContentsAtIndexPath:indexPath].fifth;
}

- (NSInteger)rowPositionsAtIndexPath:(NSIndexPath *)indexPath {
  return [[self _rowContentsAtIndexPath:indexPath].forth integerValue];
}

- (id)sectionContentsAtSection:(NSInteger)section {
  id contents = [self _contentAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] type:_CACHE_TYPE_SECTION_CONTENTS];
  if (contents == nil) {
    AOZTVPMode *currentMode = [self _currentMode];
    AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, section);
    if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
      if (sectionCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
        contents = sectionCollection.dataConfig.source;
      } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {
        //每个单元格只有一个元素的情况
        contents = ((NSArray *) sectionCollection.dataConfig.source)[section - sectionCollection.sectionRange.location];
      } else {
        //每个单元格有多个元素的情况
        NSRange subRange = NSMakeRange((section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
        if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
          subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
        }
        contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
      }
    } else {
      contents = sectionCollection.dataConfig.source;
    }
    [self _setContent:contents indexPath:[NSIndexPath indexPathForRow:0 inSection:section] type:_CACHE_TYPE_SECTION_CONTENTS];
  }
  return contents;
}

- (id)sectionTagAtSection:(NSInteger)section {
  id sectionTag = [self _contentAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] type:_CACHE_TYPE_SECTION_TAG];
  if (sectionTag == nil) {
    AOZTVPMode *currentMode = [self _currentMode];
    AOZTVPSectionCollection *sectionCollection = _collectionForIndex(currentMode, section);
    sectionTag = sectionCollection.dataConfig.tag;
    [self _setContent:([sectionTag isKindOfClass:[NSString class]]? sectionTag: [NSNull null]) indexPath:[NSIndexPath indexPathForRow:0 inSection:section] type:_CACHE_TYPE_SECTION_TAG];//here if sectionTag is not a NSString, we put a NSNull into cache for a placeholder, so next time we won't search for it again
  }
  return ([sectionTag isKindOfClass:[NSString class]]? sectionTag: nil);
}

#pragma mark public: indexPaths for touches or gesture recognizers
- (NSIndexPath *)indexPathForTouchEvent:(UIEvent *)event {
  if (event == nil) {
    return nil;
  }
  UITouch *touch = event.allTouches.anyObject;
  CGPoint touchPoint = [touch locationInView:_tableView];
  return [_tableView indexPathForRowAtPoint:touchPoint];
}

- (NSIndexPath *)indexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer == nil) {
    return nil;
  }
  CGPoint touchPoint = [gestureRecognizer locationInView:_tableView];
  return [_tableView indexPathForRowAtPoint:touchPoint];
}

#pragma mark public: about UITableView
- (void)connectToTableView:(UITableView *)tableView {
  _tableView = tableView;
  _tableView.dataSource = self;
  _tableView.delegate = self;
}

- (void)scrollToLastCell:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
  NSInteger lastSectionIndex = [_tableView numberOfSections] - 1;
  NSInteger lastRowIndex = [_tableView numberOfRowsInSection:lastSectionIndex] - 1;
  if (lastRowIndex >= 0 && lastSectionIndex >= 0) {
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex] atScrollPosition:scrollPosition animated:animated];
  }
}

- (void)registerCellClass:(Class)cellClass {
  if (cellClass == NULL) { return; }
  [_tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
}

@end
