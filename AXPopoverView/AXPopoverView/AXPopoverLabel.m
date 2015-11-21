//
//  AXPopoverLabel.m
//  AXPopoverView
//
//  Created by ai on 15/11/18.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPopoverLabel.h"

@interface AXPopoverLabel()
/// Title label
@property(strong, nonatomic) UILabel *titleLabel;
/// Detail label
@property(strong, nonatomic) UILabel *detailLabel;
@end

@implementation AXPopoverLabel
#pragma mark - Life Cycle
- (instancetype)init {
    if (self = [super init]) {
        [self initializerLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializerLabel];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializerLabel];
}

- (void)initializerLabel {
    _titleFont = [UIFont systemFontOfSize:14];
    _detailFont = [UIFont systemFontOfSize:12];
    _titleTextColor = [UIColor colorWithWhite:0 alpha:0.7];
    _detailTextColor = [UIColor colorWithWhite:0 alpha:0.5];
    _preferredWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - (self.contentViewInsets.left + self.contentViewInsets.right + self.offsets.x*2);
    _contentInsets = UIEdgeInsetsZero;
    _padding = 4;
    _fadeContentEnabled = NO;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
}

#pragma mark - Override
- (CGSize)sizeThatFits:(CGSize)size {
    [self layoutSubviews];
    return self.bounds.size;
}

- (void)layoutSubviews {
    CGRect rect_title = _titleLabel.frame;
    CGRect rect_detail = _detailLabel.frame;
    
    CGSize size = CGSizeZero;
    if (_detailLabel.text.length > 0) {
        size = [_detailLabel.text boundingRectWithSize:CGSizeMake(_preferredWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_detailLabel.font} context:nil].size;
    }
    rect_detail.size = CGSizeMake(ceil(size.width), ceil(size.height));
    rect_detail.origin.x = _contentInsets.left;
    if (_titleLabel.text.length > 0) {
        rect_title.size.width = MIN(CGRectGetWidth(rect_title), _preferredWidth);
        rect_title.size.width = MAX(CGRectGetWidth(rect_title), CGRectGetWidth(rect_detail));
        rect_title.origin.y = _contentInsets.top;
        rect_title.origin.x = rect_detail.origin.x;
        if (_detailLabel.text.length > 0) {
            rect_detail.origin.y = CGRectGetMaxY(rect_title) + _padding;
        } else {
            rect_detail.origin.y = CGRectGetMaxY(rect_title);
        }
    } else {
        rect_detail.origin.y = _contentInsets.top;
    }
    _titleLabel.frame = rect_title;
    _detailLabel.frame = rect_detail;
    CGRect rect_content = self.contentView.frame;
    CGRect rect_self = self.frame;
    rect_content.size.height = CGRectGetMaxY(rect_detail) + _contentInsets.bottom;
    rect_content.size.width = MAX(CGRectGetWidth(rect_title), CGRectGetWidth(rect_detail)) + _contentInsets.left+_contentInsets.right;
    rect_self.size = CGSizeMake(rect_content.size.width + self.contentViewInsets.left + self.contentViewInsets.right, rect_content.size.height + self.contentViewInsets.top + self.contentViewInsets.bottom);
    self.contentView.frame = rect_content;
    self.frame = rect_self;
    [super layoutSubviews];
}

- (void)viewWillShow:(BOOL)animated {
    [super viewWillShow:animated];
    if (animated && _fadeContentEnabled) {
        _titleLabel.alpha = 0.0;
        _detailLabel.alpha = 0.0;
    }
}

- (void)viewDidShow:(BOOL)animated {
    [super viewDidShow:animated];
    if (animated && _fadeContentEnabled) {
        [UIView animateWithDuration:0.25 delay:0.0 options:7 animations:^{
            _titleLabel.alpha = 1.0;
            _detailLabel.alpha = 1.0;
        } completion:nil];
    }
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
}

- (void)setDetail:(NSString *)detail {
    _detail = [detail copy];
    _detailLabel.text = detail;
    [_detailLabel sizeToFit];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
    [self setNeedsLayout];
}

- (void)setDetailFont:(UIFont *)detailFont {
    _detailFont = detailFont;
    _detailLabel.font = detailFont;
    [self setNeedsLayout];
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    _titleLabel.textColor = titleTextColor;
}

- (void)setDetailTextColor:(UIColor *)detailTextColor {
    _detailTextColor = detailTextColor;
    _detailLabel.textColor = detailTextColor;
}

- (void)setPreferredWidth:(CGFloat)preferredWidth {
    _preferredWidth = preferredWidth;
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setPadding:(CGFloat)padding {
    _padding = padding;
    [self setNeedsLayout];
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = _titleTextColor;
    _titleLabel.font = _titleFont;
    _titleLabel.text = _title;
    _titleLabel.numberOfLines = 1;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (_detailLabel) return _detailLabel;
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _detailLabel.textColor = _detailTextColor;
    _detailLabel.font = _detailFont;
    _detailLabel.text = _detail;
    _detailLabel.numberOfLines = 0;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    return _detailLabel;
}
#pragma mark - Public
+ (instancetype)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail
{
    return [self showInRect:rect animated:animated duration:duration title:title detail:detail configuration:nil];
}

+ (instancetype)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverLabelConfiguration)config
{
    AXPopoverLabel *label = [[AXPopoverLabel alloc] initWithFrame:CGRectZero];
    label.title = title;
    label.detail = detail;
    if (config) {
        config(label);
    }
    [label showInRect:rect animated:animated duration:duration];
    return label;
}

+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail
{
    return [self showFromView:view animated:animated duration:duration title:title detail:detail configuration:nil];
}

+ (instancetype)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverLabelConfiguration)config
{
    AXPopoverLabel *label = [[AXPopoverLabel alloc] initWithFrame:CGRectZero];
    label.title = title;
    label.detail = detail;
    if (config) {
        config(label);
    }
    [label showFromView:view animated:animated duration:duration];
    return label;
}
@end