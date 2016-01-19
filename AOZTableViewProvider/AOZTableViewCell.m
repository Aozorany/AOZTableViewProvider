//
//  AOZTableViewCell.m
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import "AOZTableViewCell.h"


#pragma mark -
@implementation AOZTableViewCell

#pragma mark public: general
- (void)setContents:(id)contents {
}

- (void)willDisplayCell {
}

+ (CGFloat)heightForCell:(id)contents {
    return 44;
}

@end


#pragma mark -
@implementation AOZTableViewHeaderFooterView

#pragma mark public: general
- (void)setContents:(id)contents {
}

+ (CGFloat)heightForView:(id)contents {
    return 44;
}
@end