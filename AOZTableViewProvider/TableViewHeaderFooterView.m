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
        CGRect rect = CGRectMake(0, 0, 100, 20);
        _label = [[UILabel alloc] initWithFrame:rect];
        [self addSubview:_label];
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
    }
}

+ (CGFloat)heightForView:(id)contents {
    return 100;
}

@end
