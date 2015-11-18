//
//  AXPopoverLabel.h
//  AXPopoverView
//
//  Created by ai on 15/11/18.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPopoverView.h"

@class AXPopoverLabel;
typedef void(^AXPopoverLabelConfiguration)(AXPopoverLabel *popoverLabel);

@interface AXPopoverLabel : AXPopoverView
/// Title of popover label.
@property(copy, nonatomic) NSString *title;
/// Detail of popover label.
@property(copy, nonatomic) NSString *detail;
/// Font of title label. Defaults to system 14.
@property(strong, nonatomic) UIFont *titleFont;
/// Title label text color.
@property(strong, nonatomic) UIColor *titleTextColor;
/// Font of detail label. Defaults to system 12.
@property(strong, nonatomic) UIFont *detailFont;
/// Detail label text color.
@property(strong, nonatomic) UIColor *detailTextColor;
/// Prefered width of detail label. Defaults:
/// (screenWidth - (contentViewInsets.left + contentViewInsets.right))
@property(assign, nonatomic) CGFloat preferedWidth;
/// Content insets. Defaults to {0, 0, 0, 0}
@property(assign, nonatomic) UIEdgeInsets contentInsets;
/// Padding of labels. Defaults to 4.
@property(assign, nonatomic) CGFloat padding;

+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail;
+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverLabelConfiguration)config;
@end