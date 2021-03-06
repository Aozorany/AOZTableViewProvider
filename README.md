# AOZTableViewProvider

AOZTableViewProvider allows you build UITableView from your own config files, without writing any dataSource and delegate.

Chinese document please visit README_CN.md.

## Requirements

* Xcode 7.0 or later
* iOS 5.0 or later
* ARC, if your project use MRC, please add `-fobjc-arc` target

## Install

* Download this project
* Add the falling files into your own project:
  * AOZTableViewCell
  * AOZTableViewConfigFileParser
  * AOZTableViewDefaultConfigFileParser
  * AOZTableViewDefaultConfigFileParserAddons
  * AOZTableViewProvider
  * AOZTableViewProviderUtils

That finishes the installation.

##Install via CocoaPods

AOZTableViewProvider now avaliable on CocoaPods, just add the following line into your pod file:

```
pod 'AOZTableViewProvider', '~> 0.3'
```

## Quick start

* Write your own config file, for example, as follow:

  ``` 
  row
  ```


* In your viewController.m, import AOZTableViewProvider.h and write the following code:

  ``` 
  //_tableView: your own UITableView
  _tableViewProvider = [[AOZTableViewProvider alloc] init];
  _tableViewProvider.configBundleFileName = /*Your config file*/;
  _tableViewProvider.dataProvider = self;
  [_tableViewProvider connectToTableView:mainTableView];
  [_tableViewProvider parseConfigFile:NULL];
  //[_tableViewProvider setNeedsReloadForMode:0];//called when data source for mode 0 is updated.
  [_tableViewProvider reloadTableView];
  ```


* Run your project and you will see _tableView with single row.

## About config file

Config files are text files with .tableViewConfig as their extension, and have multiple lines. Each line can begin with section, row or mode.

### Row

Means a single row, can proceed with -s, -c, -n and -all.

-s: data source to rows;

-c: cell class for rows;

-n: elements per row, only available when -s is array;

-all: all array elements are in same row, only available when -s is array.

For example:

``` 
//_array = @[@1, @2, @3, @4, @5]: I just write it here for convenience, this line doesn't belongs to the comfig file, you should write it in your code
row -s _array -c TableViewCell
```

Means rows with _array as their data source, and TableViewCell as their cell class, and only one element per row.

``` 
row -s _array -n 2 -c TableViewCell
```

Means the row with _array as it's data source and have two elements per row.

``` 
row -s _array -all -c TableViewCell
```

Means the row with _array as it's data source and all elements are in the same row.

###About TableViewCell

The TableViewCell in our config files is a sub class of AOZTableViewCell, or an implementation to AOZTableViewCell.

```objective-c
//TableViewCell.h
#import "AOZTableViewCell.h"

@interface TableViewCell : UITableViewCell <AOZTableViewCell>
@end
```

```objective-c
//TableViewCell.m
#import "TableViewCell.h"

@implementation TableViewCell

- (void)setContents:(id)contents {
    if ([contents isKindOfClass:[NSString class]]) {
        self.textLabel.text = (NSString *)contents;
    } else if ([contents isKindOfClass:[NSArray class]]) {
        NSMutableString *str = [NSMutableString string];
        for (NSString *subStr in ((NSArray *) contents)) {
            [str appendFormat:@"%@ ", subStr];
        }
        self.textLabel.text = str;
    } else if ([contents isKindOfClass:[NSDictionary class]]) {
        self.textLabel.text = contents[@"title"];
    }
}

+ (CGFloat)heightForCell:(id)contents {
    return 40;
}

@end
```

Generally you should override **setContents** and **heightForCell** method to tell the tableViewProvider how height is it, or how to deal with different contents.

In your **setContents:(id)contents** method, different contents will send to you according to different -all or -n parameters in your config files:

| Configs                             | contents                                 |
| ----------------------------------- | ---------------------------------------- |
| row -s _array -c TableViewCell      | contents is the element in your array    |
| row -s _array -n 2 -c TableViewCell | contents is a NSArray, with at most 2 elements |
| row -s _array -all -c TableViewCell | contents is a NSArray, with all elements in _array |
| row -s _dictionary -c TableViewCell | contents is a NSDictionary, with the same keys and values in _dictionary |

### Section

Means a single section, can proceed with same arguments as rows.

For example:

``` 
section -s _array -c TableViewCell
```

Means sections with _array as their data source and each section has a row with TableViewCell as it's cell.

``` 
section -c TableViewCell -h SectionHeaderView
```

Means a section with SectionHeaderView as it's header view, and it also contains a row with TableViewCell as the row's cell class.

### Mode

You can write several different configs in one config file:

``` 
mode
row -c TableViewCell
mode
row -c TableViewCell2
```

Means the tableView has two mode, you can change them by:

``` 
_tableViewProvider.mode = 0;//or 1
[_tableViewProvider reloadDataAndTableView];
```

### More complecated rows and sections

You can write more than one rows in a section, for example:

``` 
section
row
row
```

It means one section and two rows within it.

``` 
//_dictionary = @{@"first": @"1st value", @"second": @"2nd value"};
section -s _dictionary
row -s first
row -s second
```

If dataSource (-s) argument appears in both section and row, the -s in row means "data source in section data source". This config means one section with two rows, one row's data is "1st value", and another row's data is "2nd value".

CellClass (-c) and elementsPerRow (-n) arguments are avaliable both in section and row:

``` 
section -c TableViewCell
row
row -c TableViewCell2
```

This means one section with two rows, one row's cell class is TableViewCell, another row's cell class is TableViewCell2.

When section data source is an array, you can use -es (element source) argument in your row:

``` 
//_multipleArray = @[@{@"subs": @[@1, @2, @3]}, @{@"subs": @[@4, @5]}];
section -s _multipleArray
row -es subs
```

It means the tableView has two sections (you see _multipleArray has two element), and the first section has two rows, second section has three rows.

### Comments

All lines with prefix other than mode, section and row are treated as comments, so you can write them anywhere you want.

## Arguments quick look

-s: data source of a row or section, it should be a member variable of _tableViewProvider.dataProvider.

-c: cell class of a row or section, it should be an implementation of AOZTableViewCell.

-h: header view class of a section, it should be an implementation of AOZTableViewHeaderFooterView.

-n: number of elements in each section or row.

-all: if data source is array, it means all elements are in the same line.

-es: element source of a row, if section data source is an array, it means "search value from each element of that array".

-ec: if data source is empty (that means, if source is nil if it's not an array, or it is nil or has no elements if it's an array), it means the cell class to use in this situation.

-t: another tag string.