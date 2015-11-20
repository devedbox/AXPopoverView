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
@property(strong, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
/// Title label text color.
@property(strong, nonatomic) UIColor *titleTextColor UI_APPEARANCE_SELECTOR;
/// Font of detail label. Defaults to system 12.
@property(strong, nonatomic) UIFont *detailFont UI_APPEARANCE_SELECTOR;
/// Detail label text color.
@property(strong, nonatomic) UIColor *detailTextColor UI_APPEARANCE_SELECTOR;
/// Prefered width of detail label. Defaults:
/// (screenWidth - (contentViewInsets.left + contentViewInsets.right))
@property(assign, nonatomic) CGFloat preferredWidth UI_APPEARANCE_SELECTOR;
/// Content insets. Defaults to {0, 0, 0, 0}
@property(assign, nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
/// Padding of labels. Defaults to 4.
@property(assign, nonatomic) CGFloat padding UI_APPEARANCE_SELECTOR;
/// Fade the content. Defaults to NO.
@property(assign, nonatomic) BOOL fadeContentEnabled;

+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail;
+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverLabelConfiguration)config;

+ (instancetype)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail;
+ (instancetype)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverLabelConfiguration)config;
@end