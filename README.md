# AOZTableViewProvider

AOZTableViewProvider allows you build UITableView from your own config files, without writing any dataSource and delegate.

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
  [_tableViewProvider reloadData];
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
//_array = @[@1, @2, @3, @4, @5]
row -s _array -c TableViewCell
```

Means rows with _array as their data source, and TableViewCell as their cell class, and only one element per row.

``` 
row -s _array -n 2
```

Means the row with _array as it's data source and have two elements per row.

``` 
row -s _array -all
```

Means the row with _array as it's data source and all elements are in the same row.

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