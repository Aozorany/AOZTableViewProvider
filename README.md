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

Means the row with _array as it's data source, and TableViewCell as it's cell class, and only one element per row.

``` 
row -s _array -n 2
```

Means the row with _array as it's data source and have two elements per row.

``` 
row -s _array -all
```

Means the row with _array as it's data source and all elements are in the same row.

## Section

Means a single section, can proceed with same arguments as rows.

For example:

