//
//  TableViewCell.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 1/9/16.
//  Copyright © 2016 Aozorany. All rights reserved.
//

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
    }
}

@end
