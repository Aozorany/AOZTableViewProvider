//
//  TableViewHeaderFooterView.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 1/18/16.
//  Copyright © 2016 Aozorany. All rights reserved.
//

#import "TableViewHeaderFooterView.h"

@implementation TableViewHeaderFooterView {
    UILabel *_label;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.frame = CGRectMake(0, 0, 150, 100);
        
        CGRect rect = CGRectMake(10, 0, 320, 50);
        _label = [[UILabel alloc] initWithFrame:rect];
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)setContents:(id)contents {
    if ([contents isKindOfClass:[NSString class]]) {
        _label.text = (NSString *)contents;
    } else if ([contents isKindOfClass:[NSArray class]]) {
        NSMutableString *str = [NSMutableString string];
        for (NSString *subStr in ((NSArray *) contents)) {
            [str appendFormat:@"%@ ", subStr];
        }
        _label.text = str;
    } else if ([contents isKindOfClass:[NSDictionary class]]) {
        _label.text = ((NSDictionary *) contents)[@"name"];
    }
}

+ (CGFloat)heightForView:(id)contents {
    return 50;
}

@end
