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
- (void)setContents:(id)contents { }

- (void)willDisplayCell { }

+ (CGFloat)heightForCell:(id)contents { return 44; }

@end


#pragma mark -
@implementation AOZTableViewDetailCell

#pragma mark lifeCircle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    return self;
}

@end


#pragma mark -
@interface AOZTableViewSwitchCell ()
@property (nonatomic, readonly) UISwitch *switchView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityView;
@end


@implementation AOZTableViewSwitchCell

#pragma mark lifeCircle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

#pragma mark private: load and reload
- (void)loadSubviews {
    //_switchView
    _switchView = [[UISwitch alloc] init];
    _switchView.translatesAutoresizingMaskIntoConstraints = NO;
    [_switchView addTarget:self action:@selector(onSwitchViewValueChanged:event:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switchView];
    
    //_activityView
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    _activityView.hidesWhenStopped = YES;
    [self.contentView addSubview:_activityView];
    
    //constraints
    NSLayoutConstraint *switchViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:_switchView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *switchViewRightConstraint = [NSLayoutConstraint constraintWithItem:_switchView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-20];
    NSLayoutConstraint *activityViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *activityViewRightConstraint = [NSLayoutConstraint constraintWithItem:_activityView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-20];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.contentView addConstraints:@[switchViewCenterYConstraint, switchViewRightConstraint, activityViewCenterYConstraint, activityViewRightConstraint]];
    } else {
        [NSLayoutConstraint activateConstraints:@[switchViewCenterYConstraint, switchViewRightConstraint, activityViewCenterYConstraint, activityViewRightConstraint]];
    }
}

#pragma mark private: actions
- (void)onSwitchViewValueChanged:(UISwitch *)sender event:(UIEvent *)event {
    _state = (sender.on? AOZTableViewSwitchCellStateOn: AOZTableViewSwitchCellStateOff);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (_actionTarget && _switchViewValueChangedAction) {
        [_actionTarget performSelector:_switchViewValueChangedAction withObject:sender withObject:event];
    }
#pragma clang diagnostic pop
}

#pragma mark public: others
- (void)setSwitchViewState:(AOZTableViewSwitchCellState)state {
    switch (state) {
        case AOZTableViewSwitchCellStateOn:
            _switchView.on = YES;
            _switchView.hidden = NO;
            [_activityView stopAnimating];
            break;
        case AOZTableViewSwitchCellStateOff:
            _switchView.on = NO;
            _switchView.hidden = NO;
            [_activityView stopAnimating];
            break;
        case AOZTableViewSwitchCellStatePending:
            _switchView.hidden = YES;
            [_activityView startAnimating];
            break;
        default:
            break;
    }
}

- (void)setSwitchViewOnTintColor:(UIColor *)color {
    _switchView.onTintColor = color;
}

- (void)setSwitchViewThumbTintColor:(UIColor *)color {
    _switchView.thumbTintColor = color;
}

- (void)setSwitchViewTintColor:(UIColor *)color {
    _switchView.tintColor = color;
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
