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
    }
}

@end
