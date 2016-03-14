# AOZTableViewProvider

AOZTableViewProvider的主要目的是把UITableView的所有信息集成到一个配置文件中，从而省掉写dataSource和delegate的麻烦

英文文档请参考README.md

## 要求

* Xcode 7.0以上
* iOS 5.0以上
* ARC，如果你的项目使用MRC，请为相关文件加上`-fobjc-arc`标签

## 安装

* 下载本项目
* 将以下文件添加到你自己的工程中：
  * AOZTableViewCell
  * AOZTableViewConfigFileParser
  * AOZTableViewDefaultConfigFileParser
  * AOZTableViewDefaultConfigFileParserAddons
  * AOZTableViewProvider
  * AOZTableViewProviderUtils

安装完成

##通过CocoaPods安装

AOZTableViewProvider现已加入CocoaPods豪华套餐，直接在pod文件里面加上：

```
pod 'AOZTableViewProvider', '~> 0.3'
```

## 快速指引

* 在自己的工程中新建一个空白文件，加入以下内容：

  ``` 
  row
  ```


* 在你自己的viewController.m中，导入AOZTableViewProvider.h并编写以下代码

  ``` 
  //_tableView: 你自己的UITableView
  _tableViewProvider = [[AOZTableViewProvider alloc] init];
  _tableViewProvider.configBundleFileName = /*你刚才建的表格配置文件*/;
  _tableViewProvider.dataProvider = self;
  [_tableViewProvider connectToTableView:mainTableView];
  [_tableViewProvider parseConfigFile:NULL];
  //[_tableViewProvider setNeedsReloadForMode:0];//如果模式0的数据源有更新，在更新表格之前需要调用这个方法
  [_tableViewProvider reloadTableView];
  ```


* 运行工程，你将可以看到带有一个row的_tableView

## 关于表格配置文件

配置文件是以.tableViewConfig作为扩展名的多行文本文件，每一行都以section, row或mode开头。

### Row

指代一行（或者多行）row，后面可加-s, -c, -n和-all参数。

-s: row的数据源；

-c: row的cell类型；

-n: 当-s代表的数据源是一个数组时，这个参数代表了每一行的元素个数，只能为正值；

-all: 当-s代表的数据源是一个数组时，这个参数代表了全部数组元素都在同一行里面。

例如：

``` 
//_array = @[@1, @2, @3, @4, @5]:写这一行只是为了方便理解_array里面包含的内容，你应该在代码里面写上这一行，而不是在配置文件里面
row -s _array -c TableViewCell
```

代表一系列row，它们的数据源是_array，它们的cell的类型是TableViewCell，每一行只有一个元素。

``` 
row -s _array -n 2
```

代表一系列row，它们的数据源是_array，默认cell类型，每一行有两个元素。

``` 
row -s _array -all
```

代表一行row，它的数据源是_array，且所有数据都在同一行里面。

###TableViewCell相关

上述配置文件中出现的TableViewCell需要单独定义，它是AOZTableViewCell的派生，或者是AOZTableViewCell协议的实现以及UITableViewCell的派生。

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

通常情况下，你需要重写**setContents**和**heightForCell**方法，来返回这个cell的高度，或者告诉这个派生类如何处理属于它自己的内容。

在**setContents:(id)contents**方法中，根据你使用的配置参数，不同的contents参数将传到这个方法里面，如下表所示：

| 配置文件                                | contents参数                         |
| ----------------------------------- | ---------------------------------- |
| row -s _array -c TableViewCell      | contents参数代表_array中的每一个元素          |
| row -s _array -n 2 -c TableViewCell | contents参数是一个数组，含有最多两个元素           |
| row -s _array -all -c TableViewCell | contents参数包含了_array数组中的全部元素        |
| row -s _dictionary -c TableViewCell | contents是一个字典，包含了_dictionary中的全部内容 |

### Section

指代一行（或多行）section，与row带有相同的参数。

例如：

``` 
section -s _array -c TableViewCell
```

代表一系列section，每个section下面有一个row，数据源是_array，cell类型是TableViewCell。

``` 
section -c TableViewCell -h SectionHeaderView
```

代表一个section，下面有一个row，它的cell类型是TableViewCell，section的header view类型是SectionHeaderView。

### Mode

可以把多个设置放在同一个文件里面：

``` 
mode
row -c TableViewCell
mode
row -c TableViewCell2
```

这样的写法会让tableView有两个不同的模式（mode），你可以像下面这样在两个模式之间切换：

``` 
_tableViewProvider.mode = 0;//or 1
[_tableViewProvider reloadDataAndTableView];
```

### 更加复杂的row和section

在一个section下面，可以加更多的row：

``` 
section
row
row
```

代表了一个section，它的下面有两个row。

``` 
//_dictionary = @{@"first": @"1st value", @"second": @"2nd value"};
section -s _dictionary
row -s first
row -s second
```

如果数据源（-s）同时在section和下面的row子句里面出现，那row子句里面的-s表示“从section的数据源开始查找row的数据源”，上述配置代表了一个section下面带有两个row，一个的数据是“1st value”，另一个的数据是“2nd value”。

cell类型（-c）和元素个数（-n）参数可以同时在section和row子句里面出现：

``` 
section -c TableViewCell
row
row -c TableViewCell2
```

代表了一个section下面有两个row，其中一个的cell类型未被指定，则继承自section的TableViewCell，另外一个row的cell被重新指定成了TableViewCell2。

如果section的数据源类型是一个数组，可以在row子句里面用-es参数：

``` 
//_multipleArray = @[@{@"subs": @[@1, @2, @3]}, @{@"subs": @[@4, @5]}];
section -s _multipleArray
row -es subs
```

它代表了这个表格有两个section（因为_multipleArray有两个字典值），第一个section下面有两个row，第二个section下面有三个row。

### 注释

任何不以mode, section和row开头的行都被当成注释，所以不管写在哪一行都是OK的。你可以用一个固定的符号开头，让这一行看起来比较像注释。

## 快速参考

-s：数据源，可以用在section或row里面，必须是_tableViewProvider.dataProvider的一个成员变量或者属性，如果这个参数出现在row里面，而且section里面也指定了数据源，那row的数据源是从section的数据源开始找的。

-c：row或section的cell类型名称，必须实现AOZTableViewCell接口，而且是UITableViewCell的子类。

-h：section子句中的section头，必须实现AOZTableViewHeaderFooterView协议，并且是UITableViewHeaderFooterView的子类。

-n：每一行的元素个数，只对-s是array有效。

-all：可用在section或row子句中，如果数据源是array，这个参数的意义是array中的所有元素都在同一行。

-es：用在row子句中，如果section的数据源是array，这个参数表示“从section数据源的每个元素里面开始找对应的row数据源”。

-ec：用在section或row子句中，表示它的数据源为空时所使用的cell类型。如果数据源是一个数组，当它是nil，或者它里面没有元素的时候，我们说它为空。如果数据源不是一个数组，当它为nil的时候，我们说它为空。