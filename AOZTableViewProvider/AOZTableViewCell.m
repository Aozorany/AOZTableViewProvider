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
@interface AOZTableViewDetailCell ()
@property (nonatomic, readonly) UIView *lowerSeparatorView;
@end


@implementation AOZTableViewDetailCell

#pragma mark lifeCircle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

#pragma mark private: load and reload
- (void)loadSubviews {
    //_lowerSeparatorView
    _lowerSeparatorView = [[UIView alloc] init];
    _lowerSeparatorView.backgroundColor = [UIColor colorWithRed:0xdd/256.0f green:0xdd/256.0f blue:0xdd/256.0f alpha:1];
    _lowerSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_lowerSeparatorView];
    
    //constraints
    NSLayoutConstraint *lowerSeparatorViewLeft = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:15];
    NSLayoutConstraint *lowerSeparatorViewRight = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *lowerSeparatorViewBottom = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *lowerSeparatorViewHeight = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:1];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.contentView addConstraints:@[lowerSeparatorViewLeft, lowerSeparatorViewRight, lowerSeparatorViewBottom, lowerSeparatorViewHeight]];
    } else {
        [NSLayoutConstraint activateConstraints:@[lowerSeparatorViewLeft, lowerSeparatorViewRight, lowerSeparatorViewBottom, lowerSeparatorViewHeight]];
    }
}

#pragma mark override: AOZTableViewCell
- (void)willDisplayCell {
    self.contentView.hidden = (CGRectGetHeight(self.bounds) <= 0);
}

#pragma mark public: others
- (void)setLowerSeparatorViewHidden:(BOOL)hidden {
    _lowerSeparatorView.hidden = hidden;
}

@end


#pragma mark -
@interface AOZTableViewSwitchCell ()
@property (nonatomic, readonly) UISwitch *switchView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityView;
@property (nonatomic, readonly) UIView *lowerSeparatorView;
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
    
    //_lowerSeparatorView
    _lowerSeparatorView = [[UIView alloc] init];
    _lowerSeparatorView.backgroundColor = [UIColor colorWithRed:0xdd/256.0f green:0xdd/256.0f blue:0xdd/256.0f alpha:1];
    _lowerSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_lowerSeparatorView];
    
    //constraints
    NSLayoutConstraint *lowerSeparatorViewLeft = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:15];
    NSLayoutConstraint *lowerSeparatorViewRight = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *lowerSeparatorViewBottom = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *lowerSeparatorViewHeight = [NSLayoutConstraint constraintWithItem:_lowerSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:1];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self.contentView addConstraints:@[switchViewCenterYConstraint, switchViewRightConstraint, activityViewCenterYConstraint, activityViewRightConstraint, lowerSeparatorViewLeft, lowerSeparatorViewRight, lowerSeparatorViewBottom, lowerSeparatorViewHeight]];
    } else {
        [NSLayoutConstraint activateConstraints:@[switchViewCenterYConstraint, switchViewRightConstraint, activityViewCenterYConstraint, activityViewRightConstraint, lowerSeparatorViewLeft, lowerSeparatorViewRight, lowerSeparatorViewBottom, lowerSeparatorViewHeight]];
    }
}

#pragma mark AOZTableViewCell
- (void)willDisplayCell {
    self.contentView.hidden = (CGRectGetHeight(self.bounds) <= 0);
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

- (void)setLowerSeparatorViewHidden:(BOOL)hidden {
    _lowerSeparatorView.hidden = hidden;
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
