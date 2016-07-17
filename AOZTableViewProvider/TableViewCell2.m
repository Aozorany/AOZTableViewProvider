//
//  TableViewCell2.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 1/9/16.
//  Copyright © 2016 Aozorany. All rights reserved.
//

#import "TableViewCell2.h"

@implementation TableViewCell2

- (void)setContents:(id)contents {
    if ([contents isKindOfClass:[NSString class]]) {
        self.textLabel.text = [NSString stringWithFormat:@"Second row %@", contents];
    } else if ([contents isKindOfClass:[NSArray class]]) {
        NSMutableString *str = [NSMutableString stringWithString:@"Second row "];
        for (NSString *subStr in ((NSArray *) contents)) {
            [str appendFormat:@"%@ ", subStr];
        }
        self.textLabel.text = str;
    }
}

- (void)setContents:(id)contents positions:(NSInteger)cellPositions indexPath:(NSIndexPath *)indexPath tag:(NSString *)tag {
    self.textLabel.text = tag;
}

- (void)willDisplayCell {
    self.contentView.backgroundColor = [UIColor lightGrayColor];
}

@end
