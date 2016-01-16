//
//  AOZTableViewCell.h
//  AOZTableViewProvider
//
//  Created by Aozorany on 15/11/28.
//  Copyright © 2015年 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol AOZTableViewCell <NSObject>
- (void)setContents:(id)contents;
- (void)willDisplayCell;
+ (CGFloat)heightForCell:(id)contents;
@end


@interface AOZTableViewCell : UITableViewCell <AOZTableViewCell>
@end
