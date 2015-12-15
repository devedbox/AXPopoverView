//
//  AXPopoverView.m
//  AXPopoverView
//
//  Created by AiXing on 15/11/16.
//  Copyright © 2015年 AiXing. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXPopoverView.h"
#import <objc/runtime.h>
#ifndef AX_POPOVER_MAIN_THREAD
#define AX_POPOVER_MAIN_THREAD(block) \
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif
@interface AXPopoverView()
{
    @protected
    UIView   *_contentView;
    UIView   *_backgroundView;
    CGPoint   _arrowPosition;
    CGRect    _targetRect;
    UIColor  *_backgroundDrawingColor;
    dispatch_block_t _showsCompletion;
    dispatch_block_t _hidesCompletion;
    BOOL _isShowing;
    BOOL _isHiding;
    SEL  _method;
    id   _target;
    id   _object;
}
/// Previous app key window.
@property(weak, nonatomic) UIWindow *previousKeyWindow __deprecated;
/// Tap gesture.
@property(weak, nonatomic) UITapGestureRecognizer *tap __deprecated;
/// Pan gesture.
@property(weak, nonatomic) UIPanGestureRecognizer *pan __deprecated;
/// Scroll view.
@property(weak, nonatomic) UIScrollView *scrollView;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
/// Blur effect view.
@property(strong, nonatomic) UIVisualEffectView *effectView;
#else
/// Blur effect bar.
@property(strong, nonatomic) UIToolbar          *effectBar;
#endif
#pragma mark - Label
/// Title label
@property(strong, nonatomic) UILabel *titleLabel;
/// Detail label
@property(strong, nonatomic) UILabel *detailLabel;
@end

NSString *const AXPopoverPriorityHorizontal = @"AXPopoverPriorityHorizontal";
NSString *const AXPopoverPriorityVertical = @"AXPopoverPriorityVertical";

UIWindow static *_popoverWindow;

static NSString *const kAXPopoverHidesOptionAnimatedKey = @"ax_hide_option_animated";
static NSString *const kAXPopoverHidesOptionDelayKey = @"ax_hide_option_delay";

@implementation AXPopoverView
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)initializer {
    _cornerRadius = 10;
    _arrowCornerRadius = 10;
    _arrowAngle = 90;
    _arrowConstant = 10;
    _offsets = CGPointMake(8, 8);
    _arrowDirection = AXPopoverArrowDirectionBottom;
    _preferredArrowDirection = AXPopoverArrowDirectionAny;
    _priority = AXPopoverPriorityVertical;
    _dimBackground = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    _backgroundDrawingColor = [UIColor colorWithRed:0.996f green:0.867f blue:0.522f alpha:1.00f];
    _removeFromSuperViewOnHide = YES;
    _animator = [[AXPopoverViewAnimator alloc] init];
    _showsOnPopoverWindow = NO;
    _lockBackground = NO;
    _hideOnTouch = YES;
    self.translucent = YES;
    [self addSubview:self.contentView];
    [self setUpWindow];
    
    _titleFont = [UIFont systemFontOfSize:14];
    _detailFont = [UIFont systemFontOfSize:12];
    _titleTextColor = [UIColor colorWithWhite:0 alpha:0.7];
    _detailTextColor = [UIColor colorWithWhite:0 alpha:0.5];
    _preferredWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - (self.contentViewInsets.left + self.contentViewInsets.right + self.offsets.x*2);
    _contentInsets = UIEdgeInsetsZero;
    _padding = 4;
    _fadeContentEnabled = NO;
    
    _indicatorColor = [UIColor blackColor];
    _heightOfButtons = 30;
    _minWidthOfButtons = 44;
    _itemTintColor = [UIColor blackColor];
    _itemFont = _detailFont;
    _itemCornerRadius = 3.0;
    _itemStyle = AXPopoverAdditionalButtonHorizontal;
    _preferedWidthForSingleItem = 240.f;
    _shouldUsePopoverPreferedWidthOnSingleItem = YES;
    
    [_contentView addSubview:self.titleLabel];
    [_contentView addSubview:self.detailLabel];
}

- (void)dealloc {
    [self.popoverWindow unregisterPopoverView:self];
    [self unregisterScrollView];
}

+ (UIWindow *)sharedPopoverWindow {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _popoverWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _popoverWindow.userInteractionEnabled = YES;
        [_popoverWindow addGestureRecognizer:_popoverWindow.tap];
        [_popoverWindow addGestureRecognizer:_popoverWindow.pan];
    });
    return _popoverWindow;
}
#pragma mark - Override

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (!self.showsOnPopoverWindow) {
        if (_hideOnTouch) {
            if (point.x < 0 || point.y < 0 || point.x > CGRectGetWidth(self.frame) || point.y > CGRectGetHeight(self.frame)) {
                [self hideAnimated:YES afterDelay:0.05 completion:nil];
            }
        }
        if (_lockBackground) {
            if (hitView) {
                return hitView;
            } else {
                return self;
            }
        }
    }
    return hitView;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    // bubble Drawing
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(cxt, _backgroundDrawingColor.CGColor);
    CGContextSetLineWidth(cxt, 3.0);
    // top line drawing
    
    CGFloat topOffsets = 0.;
    CGFloat leftOffsets = 0.;
    CGFloat bottomOffsets = 0.;
    CGFloat rightOffsets = 0.;
    switch (_arrowDirection) {
        case AXPopoverArrowDirectionTop:
            topOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionLeft:
            leftOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionBottom:
            bottomOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionRight:
            rightOffsets = _arrowConstant;
            break;
        default:
            break;
    }
    // the origin point
    CGContextMoveToPoint(cxt, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMinY(rect) + topOffsets);
    if (_arrowDirection == AXPopoverArrowDirectionTop) [self addTopArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowHeight:_arrowConstant arrowPositionX:CGRectGetWidth(rect)*_arrowPosition.x];
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(rect) - _cornerRadius - rightOffsets, CGRectGetMinY(rect) + topOffsets);
    // top right arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMinY(rect) + topOffsets, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMinY(rect) + _cornerRadius + topOffsets, _cornerRadius);
    if (_arrowDirection == AXPopoverArrowDirectionRight) [self addRightArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowWidth:_arrowConstant arrowPositionY:CGRectGetHeight(rect)*_arrowPosition.y];
    // right line drawing
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMaxY(rect) - _cornerRadius - bottomOffsets);
    // bottom right arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMaxX(rect) - rightOffsets, CGRectGetMaxY(rect) - bottomOffsets, CGRectGetMaxX(rect) - _cornerRadius - rightOffsets, CGRectGetMaxY(rect) - bottomOffsets, _cornerRadius);
    // bottom line drawing
    if (_arrowDirection == AXPopoverArrowDirectionBottom) [self addBottomArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowHeight:_arrowConstant arrowPositionX:CGRectGetWidth(rect)*_arrowPosition.x];
    CGContextAddLineToPoint(cxt, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMaxY(rect) - bottomOffsets);
    // bottom left arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMaxY(rect) - bottomOffsets, CGRectGetMinX(rect) + leftOffsets, CGRectGetMaxY(rect) - _cornerRadius - bottomOffsets, _cornerRadius);
    if (_arrowDirection == AXPopoverArrowDirectionLeft) [self addLeftArrowPointWithContext:cxt arrowAngle:_arrowAngle arrowWidth:_arrowConstant arrowPositionY:CGRectGetHeight(rect)*_arrowPosition.y];
    // left line drawing
    CGContextAddLineToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMinY(rect) + _cornerRadius + topOffsets);
    // top left arc drawing
    CGContextAddArcToPoint(cxt, CGRectGetMinX(rect) + leftOffsets, CGRectGetMinY(rect) + topOffsets, CGRectGetMinX(rect) + _cornerRadius + leftOffsets, CGRectGetMinY(rect) + topOffsets, _cornerRadius);
    if (_translucent) {
        CGPathRef bubblePath = CGContextCopyPath(cxt);
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = bubblePath;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        _effectView.layer.mask = maskLayer;
#else
        _effectBar.layer.mask = maskLayer;
#endif
    } else {
        CGContextFillPath(cxt);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize susize = [super sizeThatFits:size];
    CGSize minSize = [self minSize];
    susize.width = MAX(susize.width, minSize.width);
    susize.height = MAX(susize.height, minSize.height);
    if (_title.length > 0 || _detail.length > 0) {
        [self layoutSubviews];
        susize.width = MAX(susize.width, self.bounds.size.width);
        susize.height = MAX(susize.width, self.bounds.size.height);
    }
    return susize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat totalHeight = .0;
    CGFloat totalWidth = .0;
    CGRect rect_header = _headerView.frame;
    rect_header.origin.y = _contentInsets.top;
    totalWidth = MAX(totalWidth, CGRectGetWidth(rect_header));
    totalHeight += CGRectGetMaxY(rect_header);
    CGRect rect_detail = _detailLabel.frame;
    CGSize detailSize = CGSizeZero;
    if (_detailLabel.text.length > 0) {
        detailSize = [_detailLabel.text boundingRectWithSize:CGSizeMake(self.preferredWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_detailLabel.font} context:nil].size;
    }
    rect_detail.size = CGSizeMake(ceil(detailSize.width), ceil(detailSize.height));
    totalWidth = MAX(totalWidth, CGRectGetWidth(rect_detail));
    CGRect rect_title = _titleLabel.frame;
    if (_titleLabel.text.length > 0) {
        rect_title.size.width = MIN(CGRectGetWidth(rect_title), _preferredWidth);
        rect_title.size.width = MAX(CGRectGetWidth(rect_title), CGRectGetWidth(rect_detail));
        totalWidth = MAX(totalWidth, CGRectGetWidth(rect_title));
        totalHeight+=_padding;
        rect_title.origin.y = totalHeight;
        totalHeight+=CGRectGetHeight(rect_title);
    }
    if (_detailLabel.text.length > 0) {
        totalHeight+=_padding;
        rect_detail.origin.y = totalHeight;
        totalHeight+=CGRectGetHeight(rect_detail);
    }
    CGRect rect_footer = _footerView.frame;
    totalWidth=MAX(totalWidth, CGRectGetWidth(rect_footer));
    if (_footerView!= nil) {
        totalHeight+=_padding;
    }
    rect_footer.origin.y = totalHeight;
    totalHeight+=CGRectGetHeight(rect_footer);
    
    if (totalWidth>_preferredWidth) {
        totalWidth = _preferredWidth;
    }
    rect_header.origin.x = totalWidth*.5-CGRectGetWidth(rect_header)*.5;
    rect_title.origin.x = totalWidth*.5-CGRectGetWidth(rect_title)*.5;
    rect_detail.origin.x = totalWidth*.5-CGRectGetWidth(rect_detail)*.5;
    rect_footer.origin.x = totalWidth*.5-CGRectGetWidth(rect_footer)*.5;
    
    _titleLabel.frame = rect_title;
    _detailLabel.frame = rect_detail;
    _headerView.frame = rect_header;
    _footerView.frame = rect_footer;
    CGRect rect_content = self.contentView.frame;
    CGRect rect_self = self.frame;
    rect_content.size.height = totalHeight + self.contentInsets.bottom;
    rect_content.size.width = totalWidth + self.contentInsets.left+self.contentInsets.right;
    rect_self.size = CGSizeMake(rect_content.size.width + self.contentViewInsets.left + self.contentViewInsets.right, rect_content.size.height + self.contentViewInsets.top + self.contentViewInsets.bottom);
    CGSize minSize = self.minSize;
    rect_self.size.width = MAX(CGRectGetWidth(rect_self), minSize.width);
    rect_self.size.height = MAX(CGRectGetHeight(rect_self), minSize.height);
    self.frame = rect_self;
    UIEdgeInsets contentInsets = self.contentViewInsets;
    rect_content.origin.x = contentInsets.left;
    rect_content.origin.y = contentInsets.top;
    _contentView.frame = rect_content;
    [self updateFrameWithRect:_targetRect];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        [self updatePositionWithScrollViewOffSets:point];
    }
}

#pragma mark - Getters

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
- (UIVisualEffectView *)effectView {
    if (_effectView) return _effectView;
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _effectView.frame = self.bounds;
    _effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _effectView;
}
#else
- (UIToolbar *)effectBar {
    if (_effectBar) return _effectBar;
    _effectBar = [[UIToolbar alloc] initWithFrame:self.bounds];
    for (UIView *view in [_effectBar subviews]) {
        if ([view isKindOfClass:[UIImageView class]] && [[view subviews] count] == 0) {
            [view setHidden:YES];
        }
    }
    _effectBar.barStyle = UIBarStyleBlack;
    _effectBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _effectBar;
}
#endif

- (UIView *)contentView {
    if (_contentView) return _contentView;
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _contentView;
}

- (CGSize)minSize {
    CGSize size = CGSizeMake(_cornerRadius + 20, _cornerRadius + 20);
    if (_arrowDirection == AXPopoverArrowDirectionBottom || _arrowDirection == AXPopoverArrowDirectionTop) {
        size.height += _arrowConstant;
    } else if (_arrowDirection == AXPopoverArrowDirectionLeft || _arrowDirection == AXPopoverArrowDirectionRight) {
        size.width += _arrowConstant;
    }
    return size;
}

- (UIEdgeInsets)contentViewInsets {
    UIEdgeInsets insets = UIEdgeInsetsMake(_cornerRadius, _cornerRadius, _cornerRadius, _cornerRadius);
    CGFloat topOffsets = 0.;
    CGFloat leftOffsets = 0.;
    CGFloat bottomOffsets = 0.;
    CGFloat rightOffsets = 0.;
    switch (_arrowDirection) {
        case AXPopoverArrowDirectionTop:
            topOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionLeft:
            leftOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionBottom:
            bottomOffsets = _arrowConstant;
            break;
        case AXPopoverArrowDirectionRight:
            rightOffsets = _arrowConstant;
            break;
        default:
            break;
    }
    insets.top += topOffsets;
    insets.left += leftOffsets;
    insets.bottom += bottomOffsets;
    insets.right += rightOffsets;
    return insets;
}

- (CGPoint)animatedFromPoint {
    CGRect originalFrame = CGRectMake(0, 0, 0, 0);
    AXPopoverArrowDirection direction = [self directionWithRect:_targetRect];
    switch (direction) {
        case AXPopoverArrowDirectionBottom:
            originalFrame.origin.x = CGRectGetMidX(_targetRect);
            originalFrame.origin.y = CGRectGetMinY(_targetRect);
            break;
        case AXPopoverArrowDirectionLeft:
            originalFrame.origin.x = CGRectGetMaxX(_targetRect);
            originalFrame.origin.y = CGRectGetMidY(_targetRect);
            break;
        case AXPopoverArrowDirectionRight:
            originalFrame.origin.x = CGRectGetMinX(_targetRect);
            originalFrame.origin.y = CGRectGetMidY(_targetRect);
            break;
        case AXPopoverArrowDirectionTop:
            originalFrame.origin.x = CGRectGetMidX(_targetRect);
            originalFrame.origin.y = CGRectGetMaxY(_targetRect);
            break;
        default:
            break;
    }
    return originalFrame.origin;
}

- (UIWindow *)popoverWindow {
    return [[self class] sharedPopoverWindow];
}

#pragma mark - Labels getters
- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = self.titleTextColor;
    _titleLabel.font = self.titleFont;
    _titleLabel.text = self.title;
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
    _detailLabel.textColor = self.detailTextColor;
    _detailLabel.font = self.detailFont;
    _detailLabel.text = self.detail;
    _detailLabel.numberOfLines = 0;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    return _detailLabel;
}

#pragma mark - Setters
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setArrowAngle:(CGFloat)arrowAngle {
    _arrowAngle = arrowAngle;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setArrowConstant:(CGFloat)arrowConstant {
    _arrowConstant = arrowConstant;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setArrowCornerRadius:(CGFloat)arrowCornerRadius {
    _arrowCornerRadius = arrowCornerRadius;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setArrowDirection:(AXPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setPriority:(NSString *)priority {
    _priority = [priority copy];
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (UIColor *)backgroundColor {
    return _backgroundDrawingColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    _backgroundDrawingColor = backgroundColor;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsDisplay];
    });
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    AX_POPOVER_MAIN_THREAD(^(){
        if (translucent) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            [self insertSubview:self.effectView atIndex:0];
            [_effectView.contentView addSubview:_contentView];
#else
            [self insertSubview:self.effectBar atIndex:0];
#endif
        } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            [self.effectView removeFromSuperview];
            [self addSubview:self.contentView];
#else
            [self.effectBar removeFromSuperview];
#endif
        }
        [self setNeedsDisplay];
    });
}

- (void)setTranslucentStyle:(AXPopoverTranslucentStyle)translucentStyle {
    _translucentStyle = translucentStyle;
    
    AX_POPOVER_MAIN_THREAD(^(){
        switch (_translucentStyle) {
            case AXPopoverTranslucentLight:
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                _effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
#else
                _effectBar.barStyle = UIBarStyleDefault;
#endif
                break;
            default:
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                _effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
#else
                _effectBar.barStyle = UIBarStyleBlack;
#endif
                break;
        }
    });
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView) [_headerView removeFromSuperview];
    _headerView = headerView;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [_contentView addSubview:_headerView];
        [self setNeedsLayout];
    });
}

- (void)setFooterView:(UIView *)footerView {
    if (_footerView) [_footerView removeFromSuperview];
    _footerView = footerView;
    
    AX_POPOVER_MAIN_THREAD(^(){
        [_contentView addSubview:_footerView];
        [self setNeedsLayout];
    });
}

#pragma mark - Labels setters

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    AX_POPOVER_MAIN_THREAD(^(){
        _titleLabel.text = title;
        [_titleLabel sizeToFit];
        [self setNeedsLayout];
    });
}

- (void)setDetail:(NSString *)detail {
    _detail = [detail copy];
    AX_POPOVER_MAIN_THREAD(^(){
        _detailLabel.text = detail;
        [_detailLabel sizeToFit];
        [self setNeedsLayout];
    });
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    
    AX_POPOVER_MAIN_THREAD(^(){
        _titleLabel.font = titleFont;
        [self setNeedsLayout];
    });
}

- (void)setDetailFont:(UIFont *)detailFont {
    _detailFont = detailFont;
    
    AX_POPOVER_MAIN_THREAD(^(){
        _detailLabel.font = detailFont;
        [self setNeedsLayout];
    });
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    AX_POPOVER_MAIN_THREAD(^(){
        _titleLabel.textColor = titleTextColor;
    });
}

- (void)setDetailTextColor:(UIColor *)detailTextColor {
    _detailTextColor = detailTextColor;
    AX_POPOVER_MAIN_THREAD(^(){
        _detailLabel.textColor = detailTextColor;
    });
}

- (void)setPreferredWidth:(CGFloat)preferredWidth {
    _preferredWidth = preferredWidth;
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsLayout];
    });
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsLayout];
    });
}

- (void)setPadding:(CGFloat)padding {
    _padding = padding;
    AX_POPOVER_MAIN_THREAD(^(){
        [self setNeedsLayout];
    });
}

#pragma mark - Custom view setters
- (void)setHeaderMode:(AXPopoverCustomViewMode)headerMode {
    _headerMode = headerMode;
    self.headerView = [self modedViewWithMode:_headerMode];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    AX_POPOVER_MAIN_THREAD(^(){
        if ([_headerView isKindOfClass:[UIActivityIndicatorView class]]) {
            [_headerView setValue:_indicatorColor forKeyPath:@"color"];
        } else if([_headerView isKindOfClass:[AXPopoverBarProgressView class]]) {
            [_headerView setValue:[_indicatorColor colorWithAlphaComponent:0.7] forKeyPath:@"lineColor"];
            [_headerView setValue:_indicatorColor forKeyPath:@"progressColor"];
        } else if ([_headerView isKindOfClass:[AXPopoverCircleProgressView class]]) {
            [_headerView setValue:[_indicatorColor colorWithAlphaComponent:0.7] forKeyPath:@"progressColor"];
            [_headerView setValue:_indicatorColor forKeyPath:@"progressBgnColor"];
        }
        if ([_footerView isKindOfClass:[UIActivityIndicatorView class]]) {
            [_footerView setValue:_indicatorColor forKeyPath:@"color"];
        } else if([_footerView isKindOfClass:[AXPopoverBarProgressView class]]) {
            [_footerView setValue:[_indicatorColor colorWithAlphaComponent:0.7] forKeyPath:@"lineColor"];
            [_footerView setValue:[_indicatorColor colorWithAlphaComponent:0.1] forKeyPath:@"progressColor"];
        } else if ([_footerView isKindOfClass:[AXPopoverCircleProgressView class]]) {
            [_footerView setValue:[_indicatorColor colorWithAlphaComponent:0.7] forKeyPath:@"progressColor"];
            [_footerView setValue:[_indicatorColor colorWithAlphaComponent:0.1] forKeyPath:@"progressBgnColor"];
        }
    });
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    AX_POPOVER_MAIN_THREAD(^(){
        if ([_headerView isKindOfClass:[AXPopoverCircleProgressView class]] || [_headerView isKindOfClass:[AXPopoverBarProgressView class]]) {
            if ([_headerView respondsToSelector:@selector(setProgress:)]) {
                [_headerView setValue:@(_progress) forKeyPath:@"progress"];
            }
        }
        if ([_footerView isKindOfClass:[AXPopoverCircleProgressView class]] || [_footerView isKindOfClass:[AXPopoverBarProgressView class]]) {
            if ([_footerView respondsToSelector:@selector(setProgress:)]) {
                [_footerView setValue:@(_progress) forKeyPath:@"progress"];
            }
        }
    });
}
#pragma mark - Additional buttons

- (void)setItems:(NSArray *)items {
    _items = [items copy];
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setHeightOfButtons:(CGFloat)heightOfButtons {
    _heightOfButtons = heightOfButtons;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setMinWidthOfButtons:(CGFloat)minWidthOfButtons {
    _minWidthOfButtons = minWidthOfButtons;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setItemTintColor:(UIColor *)itemTintColor {
    _itemTintColor = itemTintColor;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setItemCornerRadius:(CGFloat)itemCornerRadius {
    _itemCornerRadius = itemCornerRadius;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setPreferedWidthForSingleItem:(CGFloat)preferedWidthForSingleItem {
    _preferedWidthForSingleItem = preferedWidthForSingleItem;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

- (void)setItemStyle:(AXPopoverAdditionalButtonStyle)itemStyle {
    _itemStyle = itemStyle;
    self.footerView = [self additionalButtonsViewWithItems:_items];
}

#pragma mark - Shows&Hides
- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (_isShowing) return;
    _targetRect = rect;
    [self.popoverWindow registerPopoverView:self];
    [self layoutSubviews];
    if (completion) _showsCompletion = [completion copy];
    if (!_animator.showing) {
        self.layer.anchorPoint = self.arrowPosition;
        self.transform = CGAffineTransformMakeScale(0.f, 0.f);
        _backgroundView.alpha = 0.0;
        NSTimeInterval animationDutation = animated?0.5:0.0;
        [self viewWillShow:animated];
        [UIView animateWithDuration:animationDutation delay:0.05 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:7 animations:^{
            self.hidden = NO;
            self.transform = CGAffineTransformIdentity;
            [self viewShowing:animated];
        } completion:^(BOOL finished) {
            if (finished) {
                [self viewDidShow:animated];
            }
        }];
    } else {
        [self viewWillShow:animated];
        _animator.showing(self, animated, _targetRect);
        [self viewShowing:animated];
    }
    // animated to dim background
    if (_dimBackground) {
        [UIView animateWithDuration:0.05 animations:^{
            _backgroundView.hidden = NO;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateKeyframesWithDuration:0.25 delay:0.0 options:7 animations:^{
                    _backgroundView.alpha = 1.0;
                } completion:nil];
            }
        }];
    }
}

- (void)hideAnimated:(BOOL)animated completion:(dispatch_block_t)completion
{
    if (_isHiding) return;
    UIView *view;
    if (_translucent) {// using snapshot
        if (_showsOnPopoverWindow) {
            view = [self.popoverWindow resizableSnapshotViewFromRect:self.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        } else {
            view = [self.popoverWindow.appKeyWindow resizableSnapshotViewFromRect:self.frame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        view.layer.mask = self.effectView.layer.mask;
#else
        view.layer.mask = self.effectBar.layer.mask;
#endif
        view.frame = self.frame;
        if (_showsOnPopoverWindow) {
            [self.popoverWindow addSubview:view];
        } else {
            [self.popoverWindow.appKeyWindow addSubview:view];
        }
        self.hidden = YES;
    } else {
        view = self;
    }
    NSTimeInterval animationDuration = animated?0.25:0.0;
    if (completion) _hidesCompletion = [completion copy];
    [self viewWillHide:animated];
    if (!_animator.hiding) {
        [UIView animateWithDuration:animationDuration animations:^{
            view.alpha = 0.0;
            [self viewHiding:animated];
        } completion:^(BOOL finished) {
            if (finished) {
                [self viewDidHide:animated];
            }
        }];
    } else {
        [self viewWillHide:animated];
        _animator.hiding(self, animated, _targetRect);
        [self viewHiding:YES];
    }
    if (self.popoverWindow.referenceCount == 1) {
        [UIView animateWithDuration:animationDuration animations:^{
            _backgroundView.alpha = 0.0;
        } completion:nil];
    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion
{
    if (completion) {
        _hidesCompletion = [completion copy];
    }
    [self performSelector:@selector(delayHideWithOptions:) withObject:@{kAXPopoverHidesOptionAnimatedKey:@(animated)} afterDelay:delay];
}

- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [self showInRect:rect animated:animated completion:^{
        [self hideAnimated:animated afterDelay:duration completion:nil];
    }];
}

- (void)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [self showFromView:view animated:animated completion:^{
        [self hideAnimated:animated afterDelay:duration completion:nil];
    }];
}

- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion {
    CGRect rect = [view.superview convertRect:view.frame toView:view.window];
    [self showInRect:rect animated:animated completion:completion];
}

- (void)delayHideWithOptions:(NSDictionary *)option {
    [self hideAnimated:[[option objectForKey:kAXPopoverHidesOptionAnimatedKey] boolValue] completion:nil];
}

- (void)viewWillShow:(BOOL)animated {
    _isShowing = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewWillShow:animated:)]) {
        [_delegate popoverViewWillShow:self animated:animated];
    }
}
- (void)viewShowing:(BOOL)animated {
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewShowing:animated:)]) {
        [_delegate popoverViewShowing:self animated:animated];
    }
}
- (void)viewDidShow:(BOOL)animated {
    _isShowing = NO;
    if (_showsCompletion) _showsCompletion();
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewDidShow:animated:)]) {
        [_delegate popoverViewDidShow:self animated:animated];
    }
}
- (void)viewWillHide:(BOOL)animated {
    _isHiding = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewWillHide:animated:)]) {
        [_delegate popoverViewWillHide:self animated:animated];
    }
}
- (void)viewHiding:(BOOL)animated {
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewHiding:animated:)]) {
        [_delegate popoverViewHiding:self animated:animated];
    }
}
- (void)viewDidHide:(BOOL)animated {
    _isHiding = NO;
    self.alpha = 1.0;
    self.hidden = NO;
    _backgroundView.alpha = 1.0;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self setNeedsLayout];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.popoverWindow unregisterPopoverView:self];
    if (_hidesCompletion) _hidesCompletion();
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewDidHide:animated:)]) {
        [_delegate popoverViewDidHide:self animated:animated];
    }
}

+ (void)hideVisiblePopoverViewsAnimated:(BOOL)animated
{
    NSMutableArray *popoverViews = [NSMutableArray array];
    if (_popoverWindow.appKeyWindow != nil) {
        for (UIView *view in _popoverWindow.appKeyWindow.subviews) {
            if ([view isKindOfClass:[AXPopoverView class]]) {
                [popoverViews addObject:view];
            }
        }
    }
    for (UIView *view in _popoverWindow.subviews) {
        if ([view isKindOfClass:[AXPopoverView class]]) {
            [popoverViews addObject:view];
        }
    }
    for (AXPopoverView *popoverView in popoverViews) {
        [popoverView hideAnimated:animated afterDelay:0.0 completion:nil];
    }
}

#pragma mark - Threading

- (void)addExecuting:(SEL)method onTarget:(id)target withObject:(id)object {
    _method = method;
    _target = target;
    _object = object;
    // Launch execution in new thread
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
}

#if NS_BLOCKS_AVAILABLE

- (void)addExecutingBlock:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self addExecutingBlock:block onQueue:queue completionBlock:NULL];
}

- (void)addExecutingBlock:(dispatch_block_t)block completionBlock:(dispatch_block_t)completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self addExecutingBlock:block onQueue:queue completionBlock:completion];
}

- (void)addExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue {
    [self addExecutingBlock:block onQueue:queue completionBlock:NULL];
}

- (void)addExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
     completionBlock:(dispatch_block_t)completion {
    dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self cleanUp];
        });
    });
}

#endif

- (void)launchExecution {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [_target performSelector:_method withObject:_object];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread)
        [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)cleanUp {
    _method = NULL;
    _target = nil;
    _object = nil;
    [self hideAnimated:YES afterDelay:0.f completion:NULL];
}

#pragma mark - Scroll view support
- (void)registerScrollView:(UIScrollView *)scrollView {
    if (_scrollView == scrollView) return;
    [self unregisterScrollView];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)unregisterScrollView {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    self.transform = CGAffineTransformIdentity;
    _scrollView = nil;
}

#pragma mark - Actions
- (void)handleGestures:(id)sender __deprecated {
    [self hideAnimated:YES afterDelay:0.1f completion:nil];
}

#pragma mark - Helper

- (void)setUpWindow {
    _backgroundView = [[UIView alloc] initWithFrame:self.popoverWindow.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.popoverWindow addSubview:_backgroundView];
    _backgroundView.hidden = YES;
    _backgroundView.alpha = 0.0;
}

- (AXPopoverArrowDirection)directionWithRect:(CGRect)rect {
    UIEdgeInsets margins = UIEdgeInsetsMake(rect.origin.y, rect.origin.x, self.popoverWindow.bounds.size.height - CGRectGetMaxY(rect), self.popoverWindow.bounds.size.width - CGRectGetMaxX(rect));
    NSMutableArray *availableDirections = [NSMutableArray array];
    if ([_priority isEqualToString:AXPopoverPriorityHorizontal]) {
        CGFloat margin=.0;
        if (margins.left >= CGRectGetWidth(self.bounds)) {// Show on left.
            [availableDirections addObject:@(AXPopoverArrowDirectionRight)];
            margin = margins.left;
        } if (margins.right >= CGRectGetWidth(self.bounds)) {// Show on right.
            if (margins.right >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionLeft) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionLeft)];
            }
            margin = margins.right;
        } if (margins.top >= CGRectGetHeight(self.bounds)) {// Show on top.
            if (margins.top >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionBottom) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionBottom)];
            }
            margin = margins.top;
        } if (margins.bottom >= CGRectGetHeight(self.bounds)) {// Show on bottom.
            if (margins.bottom >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionTop) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionTop)];
            }
        }
    } else {
        CGFloat margin=.0;
        if (margins.top >= CGRectGetHeight(self.bounds)) {// Show on top.
            if (margins.top >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionBottom) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionBottom)];
            }
            margin = margins.top;
        } if (margins.bottom >= CGRectGetHeight(self.bounds)) {// Show on bottom.
            if (margins.bottom >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionTop) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionTop)];
            }
            margin = margins.bottom;
        } if (margins.left >= CGRectGetWidth(self.bounds)) {// Show on left.
            if (margins.left >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionRight) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionRight)];
            }
            margin = margins.left;
        } if (margins.right >= CGRectGetWidth(self.bounds)) {// Show on right.
            if (margins.right >= margin) {
                [availableDirections insertObject:@(AXPopoverArrowDirectionLeft) atIndex:0];
            } else {
                [availableDirections addObject:@(AXPopoverArrowDirectionLeft)];
            }
        }
    }
    if (availableDirections.count > 0) {
        if (_preferredArrowDirection != AXPopoverArrowDirectionAny) {
            if ([availableDirections containsObject:@(_preferredArrowDirection)]) {
                return _preferredArrowDirection;
            } else
                return [[availableDirections firstObject] integerValue];
        } else
            return [[availableDirections firstObject] integerValue];
    }
    return AXPopoverArrowDirectionAny;
}

- (void)updateFrameWithRect:(CGRect)rct {
    CGRect rect = self.frame;
    AXPopoverArrowDirection direction = [self directionWithRect:rct];
    _arrowDirection = direction;
    if (direction == AXPopoverArrowDirectionBottom || direction == AXPopoverArrowDirectionTop) {
        if (direction == AXPopoverArrowDirectionBottom) {
            rect.origin.y = CGRectGetMinY(rct) - CGRectGetHeight(rect);
            _arrowPosition.y = 1;
        } else {
            rect.origin.y = CGRectGetMaxY(rct);
            _arrowPosition.y = 0;
        }
        if (CGRectGetMidX(rct) >= CGRectGetWidth(rect)/2 + _offsets.x && CGRectGetWidth(self.popoverWindow.bounds) - CGRectGetMidX(rct) >= CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle
            _arrowPosition.x = .5;
            rect.origin.x = (CGRectGetWidth(rct) - CGRectGetWidth(rect))/2 + rct.origin.x;
        } else if (CGRectGetMidX(rct) < CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle left
            rect.origin.x = _offsets.x;
            _arrowPosition.x = (CGRectGetMidX(rct) - _offsets.x)/CGRectGetWidth(rect);
        } else if (CGRectGetWidth(self.popoverWindow.bounds) - CGRectGetMidX(rct) < CGRectGetWidth(rect)/2 + _offsets.x) {
            // arrow in the middle right
            rect.origin.x = CGRectGetWidth(self.popoverWindow.bounds) - (CGRectGetWidth(rect) + _offsets.x);
            _arrowPosition.x = (CGRectGetWidth(rect) - (CGRectGetWidth(self.popoverWindow.bounds) - CGRectGetMidX(rct) - _offsets.x))/CGRectGetWidth(rect);
        }
    } else if (direction == AXPopoverArrowDirectionLeft | direction == AXPopoverArrowDirectionRight) {
        if (direction == AXPopoverArrowDirectionRight) {
            rect.origin.x = CGRectGetMinX(rct) - CGRectGetWidth(rect);
            _arrowPosition.x = 1;
        } else {
            rect.origin.x = CGRectGetMaxX(rct);
            _arrowPosition.x = 0;
        }
        if (CGRectGetMidY(rct) >= CGRectGetHeight(rect)/2 + _offsets.y && CGRectGetHeight(self.popoverWindow.bounds) - CGRectGetMidY(rct) >= CGRectGetHeight(rect)/2 + _offsets.y) {
            // arrow in the middle
            _arrowPosition.y = .5;
            rect.origin.y = (CGRectGetHeight(rct) - CGRectGetHeight(rect))/2 + rct.origin.y;
        } else if (CGRectGetMidY(rct) < CGRectGetWidth(rect)/2 + _offsets.y) {
            // arrow in the middle top
            rect.origin.y = _offsets.y;
            _arrowPosition.y = (CGRectGetMidY(rct) - _offsets.y)/CGRectGetHeight(rect);
        } else if (CGRectGetHeight(self.popoverWindow.bounds) - CGRectGetMidY(rct) < CGRectGetHeight(rect)/2 + _offsets.y) {
            // arrow in the middle bottom
            rect.origin.y = CGRectGetHeight(self.popoverWindow.bounds) - (CGRectGetHeight(rect) + _offsets.y);
            _arrowPosition.y = (CGRectGetHeight(rect) - (CGRectGetHeight(self.popoverWindow.bounds) - CGRectGetMidY(rct) - _offsets.y))/CGRectGetHeight(rect);
        }
    }
    [self setNeedsDisplay];
    self.frame = rect;
}

- (BOOL)validOfArrowFrame:(CGRect)arrowFrame __deprecated {
    if (arrowFrame.origin.x == 0 || arrowFrame.origin.y == 0 || CGRectGetMaxX(arrowFrame) == self.bounds.size.width || CGRectGetMaxY(arrowFrame) == self.bounds.size.height) {
        return YES;
    }
    return NO;
}

- (void)addTopArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowHeight:(CGFloat)height arrowPositionX:(CGFloat)x
{
    CGFloat arrowWidth_2 = height * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantX = constant*sin(angle*M_PI/360);
    CGFloat constantY = constant*cos(angle*M_PI/360);
    CGFloat xConstant = x - arrowWidth_2;
    if (xConstant < 0) return;
    if (xConstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, MAX(xConstant, _cornerRadius), CGRectGetMinY(self.bounds) + height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant - constant, CGRectGetMinY(self.bounds) + height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMinY(self.bounds) + height, xConstant + constantX, CGRectGetMinY(self.bounds) + height - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMinY(self.bounds));
    xConstant = x + arrowWidth_2;
    if (xConstant > CGRectGetMaxX(self.bounds)) return;
    if (xConstant + constant > CGRectGetWidth(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, MIN(xConstant, CGRectGetWidth(self.bounds) - _cornerRadius), CGRectGetMinY(self.bounds) + height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant - constantX, CGRectGetMinY(self.bounds) + height - constantY);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMinY(self.bounds) + height, xConstant + constant, CGRectGetMinY(self.bounds) + height, _arrowCornerRadius);
    }
}

- (void)addBottomArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowHeight:(CGFloat)height arrowPositionX:(CGFloat)x
{
    CGFloat arrowWidth_2 = height * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantX = constant*sin(angle*M_PI/360);
    CGFloat constantY = constant*cos(angle*M_PI/360);
    CGFloat xConstant = x + arrowWidth_2;
    if (xConstant > CGRectGetMaxX(self.bounds)) return;
    if (xConstant + constant > CGRectGetWidth(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, MIN(xConstant, CGRectGetWidth(self.bounds) - _cornerRadius), CGRectGetMaxY(self.bounds) - height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant + constant, CGRectGetMaxY(self.bounds) - height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMaxY(self.bounds) - height, xConstant - constantX, CGRectGetMaxY(self.bounds) - height + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMaxY(self.bounds));
    xConstant = x - arrowWidth_2;
    if (xConstant < 0) return;
    if (xConstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, MAX(xConstant, _cornerRadius), CGRectGetMaxY(self.bounds) - height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant + constantX, CGRectGetMaxY(self.bounds) - height + constantY);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMaxY(self.bounds) - height, xConstant - constant, CGRectGetMaxY(self.bounds) - height, _arrowCornerRadius);
    }
}

- (void)addLeftArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowWidth:(CGFloat)width arrowPositionY:(CGFloat)y
{
    CGFloat arrowHtight_2 = width * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantY = constant*sin(angle*M_PI/360);
    CGFloat constantX = constant*cos(angle*M_PI/360);
    CGFloat Yconstant = y + arrowHtight_2;
    if (Yconstant > CGRectGetMaxY(self.bounds)) return;
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant + constant);
        CGContextAddArcToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant, CGRectGetMinX(self.bounds) + width - constantX, Yconstant - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds), y);
    Yconstant = y - arrowHtight_2;
    if (Yconstant < 0) return;
    if (Yconstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, MAX(Yconstant, _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width - constantX, y - arrowHtight_2 + constantY);
        CGContextAddArcToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant, CGRectGetMinX(self.bounds) + width, Yconstant - constant, _arrowCornerRadius);
    }
}

- (void)addRightArrowPointWithContext:(CGContextRef)cxt arrowAngle:(CGFloat)angle arrowWidth:(CGFloat)width arrowPositionY:(CGFloat)y
{
    CGFloat arrowHtight_2 = width * tan(angle*M_PI/360);
    CGFloat constant = _arrowCornerRadius * tan((45-(angle/4))*M_PI/180);
    CGFloat constantY = constant*sin(angle*M_PI/360);
    CGFloat constantX = constant*cos(angle*M_PI/360);
    CGFloat Yconstant = y - arrowHtight_2;
    if (Yconstant < 0) return;
    if (Yconstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MAX(Yconstant, _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant - constant);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds), y);
    Yconstant = y + arrowHtight_2;
    if (Yconstant > CGRectGetMaxY(self.bounds)) return;
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant - constantY);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width, Yconstant + constant, _arrowCornerRadius);
    }
}

- (void)updatePositionWithScrollViewOffSets:(CGPoint) offset {
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-(offset.x + _scrollView.contentInset.left), -(offset.y + _scrollView.contentInset.top));
    self.transform = transform;
}

- (UIView *)modedViewWithMode:(AXPopoverCustomViewMode)mode {
    switch (mode) {
        case AXPopoverIndeterminate:
        {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [indicator startAnimating];
            indicator.color = _indicatorColor;
            return indicator;
        } case AXPopoverDeterminate:
        {
            AXPopoverCircleProgressView *progressView = [[AXPopoverCircleProgressView alloc] init];
            progressView.annularEnabled = NO;
            progressView.progressColor = [_indicatorColor colorWithAlphaComponent:0.7];
            progressView.progressBgnColor = [_indicatorColor colorWithAlphaComponent:0.1];
            return progressView;
        } case AXPopoverDeterminateAnnularEnabled:
        {
            AXPopoverCircleProgressView *progressView = [[AXPopoverCircleProgressView alloc] init];
            progressView.annularEnabled = YES;
            progressView.progressColor = [_indicatorColor colorWithAlphaComponent:0.7];
            progressView.progressBgnColor = [_indicatorColor colorWithAlphaComponent:0.1];
            return progressView;
        } case AXPopoverDeterminateHorizontalBar:
        {
            AXPopoverBarProgressView *progressView = [[AXPopoverBarProgressView alloc] init];
            progressView.lineColor = [_indicatorColor colorWithAlphaComponent:0.5];
            progressView.progressColor = [_indicatorColor colorWithAlphaComponent:0.7];
            return progressView;
        } case AXPopoverSuccess:
        {
            UIImage *image = [self tintImage:[UIImage imageNamed:@"AXPopoverView.bundle/ax_success"] WithColor:[_indicatorColor colorWithAlphaComponent:0.7]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView sizeToFit];
            CGRect rect = imageView.frame;
            rect.size.width = rect.size.width * (37/rect.size.height);
            rect.size.height = 37;
            imageView.frame = rect;
            return imageView;
        } case AXPopoverError:
        {
            UIImage *image = [self tintImage:[UIImage imageNamed:@"AXPopoverView.bundle/ax_error"] WithColor:[_indicatorColor colorWithAlphaComponent:0.7]];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView sizeToFit];
            CGRect rect = imageView.frame;
            rect.size.width = rect.size.width * (37/rect.size.height);
            rect.size.height = 37;
            imageView.frame = rect;
            return imageView;
        }
        default:
            return nil;
    }
}

#ifndef kAXPopoverItemTag
#define kAXPopoverItemTag 1000
#endif

- (UIView *)additionalButtonsViewWithItems:(NSArray *)items {
    if (!items || items.count == 0) return nil;
    switch (_itemStyle) {
        case AXPopoverAdditionalButtonHorizontal:
        {
            CGFloat prefredButtonWidth = 0.f;
            if (items.count == 1) {
                if (_shouldUsePopoverPreferedWidthOnSingleItem) {
                    prefredButtonWidth = _preferredWidth;
                } else {
                    prefredButtonWidth = _preferedWidthForSingleItem;
                }
            } else {
                prefredButtonWidth = (_preferredWidth-_padding*(items.count -1))/items.count;
            }
            if (prefredButtonWidth<_minWidthOfButtons) {
                prefredButtonWidth = _minWidthOfButtons;
            }
            CGFloat totalWidth = items.count*prefredButtonWidth + (items.count - 1)*_padding;
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, _heightOfButtons)];
            footerView.backgroundColor = [UIColor clearColor];
            for (NSInteger i = 0; i < items.count; i++) {
                NSString *item = items[i];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setTitle:item forState:UIControlStateNormal];
                button.backgroundColor = [UIColor clearColor];
                [button setBackgroundImage:[self tintImage:[UIImage imageNamed:@"AXPopoverView.bundle/ax_button"] WithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
                button.tintColor = _itemTintColor;
                button.titleLabel.font = _itemFont;
                button.layer.cornerRadius = _itemCornerRadius;
                button.layer.masksToBounds = YES;
                button.clipsToBounds = YES;
                button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
                [button setFrame:CGRectMake(_padding*i+prefredButtonWidth*i, 0, prefredButtonWidth, _heightOfButtons)];
                [footerView addSubview:button];
                button.tag = kAXPopoverItemTag + i + 1;
                [button addTarget:self action:@selector(handleItemAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            return footerView;
        }
        case AXPopoverAdditionalButtonVertical:
        {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _shouldUsePopoverPreferedWidthOnSingleItem?_preferredWidth:_preferedWidthForSingleItem, _heightOfButtons * items.count + (items.count - 1)*_padding)];
            footerView.backgroundColor = [UIColor clearColor];
            for (NSUInteger i = 0; i < items.count; i ++) {
                NSString *item = items[i];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
                [button setTitle:item forState:UIControlStateNormal];
                button.backgroundColor = [UIColor clearColor];
                [button setBackgroundImage:[self tintImage:[UIImage imageNamed:@"AXPopoverView.bundle/ax_button"] WithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]] forState:UIControlStateNormal];
                button.tintColor = _itemTintColor;
                button.titleLabel.font = _itemFont;
                button.layer.cornerRadius = _itemCornerRadius;
                button.layer.masksToBounds = YES;
                button.clipsToBounds = YES;
                button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
                [button setFrame:CGRectMake(0, _padding*i+_heightOfButtons*i, _shouldUsePopoverPreferedWidthOnSingleItem?_preferredWidth:_preferedWidthForSingleItem, _heightOfButtons)];
                [footerView addSubview:button];
                button.tag = kAXPopoverItemTag + i + 1;
                [button addTarget:self action:@selector(handleItemAction:) forControlEvents:UIControlEventTouchUpInside];
            }
            return footerView;
        }
        default:
            return nil;
    }
}

- (void)handleItemAction:(UIButton *)sender {
    if (_itemHandler) {
        _itemHandler(sender, sender.tag - kAXPopoverItemTag);
    }
}

- (UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)removeGestures __deprecated {
    [self.popoverWindow removeGestureRecognizer:self.tap];
    [self.popoverWindow removeGestureRecognizer:self.pan];
    self.tap = nil;
    self.pan = nil;
}
@end
@implementation AXPopoverView (Label)
+ (instancetype)showLabelInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail
{
    return [self showLabelInRect:rect animated:animated duration:duration title:title detail:detail configuration:nil];
}

+ (instancetype)showLabelInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(nullable AXPopoverViewConfiguration)config
{
    AXPopoverView *popoverView = [[AXPopoverView alloc] initWithFrame:CGRectZero];
    popoverView.title = title;
    popoverView.detail = detail;
    if (config) {
        config(popoverView);
    }
    [popoverView showInRect:rect animated:animated duration:duration];
    return popoverView;
}

+ (instancetype)showLabelFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail
{
    return [self showLabelFromView:view animated:animated duration:duration title:title detail:detail configuration:nil];
}

+ (instancetype)showLabelFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(nullable AXPopoverViewConfiguration)config
{
    AXPopoverView *popoverView = [[AXPopoverView alloc] initWithFrame:CGRectZero];
    popoverView.title = title;
    popoverView.detail = detail;
    if (config) {
        config(popoverView);
    }
    [popoverView showFromView:view animated:animated duration:duration];
    return popoverView;
}
@end
@implementation AXPopoverViewAnimator
- (instancetype)initWithShowing:(AXPopoverViewAnimation)showing hiding:(AXPopoverViewAnimation)hiding
{
    if (self = [super init]) {
        _showing = [showing copy];
        _hiding = [hiding copy];
    }
    return self;
}
+ (instancetype)animatorWithShowing:(AXPopoverViewAnimation)showing hiding:(AXPopoverViewAnimation)hiding
{
    return [[self alloc] initWithShowing:showing hiding:hiding];
}
@end
@implementation UIWindow(AXPopover)
#pragma mark - Getters
- (NSUInteger)referenceCount {
    return [self.registeredPopoverViews count];
}

- (UITapGestureRecognizer *)tap {
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, _cmd);
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        objc_setAssociatedObject(self, _cmd, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tap;
}

- (UIPanGestureRecognizer *)pan {
    UIPanGestureRecognizer *pan = objc_getAssociatedObject(self, _cmd);
    if (!pan) {
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        objc_setAssociatedObject(self, _cmd, pan, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return pan;
}

- (NSMutableArray *)registeredPopoverViews {
    NSMutableArray *views = objc_getAssociatedObject(self, _cmd);
    if (!views) {
        views = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, views, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return views;
}

- (UIWindow *)appKeyWindow {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Setters
- (void)setAppKeyWindow:(UIWindow *)window {
    objc_setAssociatedObject(self, @selector(appKeyWindow), window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Actions
- (void)handleGesture:(id)sender {
    NSArray *registeredViews = [[self registeredPopoverViews] copy];
    if ([registeredViews count] > 0) {
        if ([registeredViews.lastObject isKindOfClass:[AXPopoverView class]]) {
            AXPopoverView *popoverView = [registeredViews lastObject];
            if (popoverView.superview == self) {
                [popoverView hideAnimated:YES afterDelay:0 completion:nil];
            }
        }
    }
}

- (void)registerPopoverView:(AXPopoverView *)popoverView {
    if (!self.isKeyWindow) self.appKeyWindow = [UIApplication sharedApplication].keyWindow;
    
    if (popoverView.showsOnPopoverWindow) {
        if (popoverView.superview == self) {
            @synchronized(self) {
                [self bringSubviewToFront:popoverView.backgroundView];
                [self bringSubviewToFront:popoverView];
                [self.registeredPopoverViews removeObject:popoverView];
                [self.registeredPopoverViews addObject:popoverView];
            }
        } else {
            @synchronized(self) {
                [self addSubview:popoverView.backgroundView];
                [self addSubview:popoverView];
                [self.registeredPopoverViews addObject:popoverView];
            }
        }
        if (!self.isKeyWindow) [self makeKeyAndVisible];
    } else {
        if (popoverView.superview == self.appKeyWindow) {
            @synchronized(self) {
                [self.appKeyWindow bringSubviewToFront:popoverView.backgroundView];
                [self.appKeyWindow bringSubviewToFront:popoverView];
                [self.registeredPopoverViews removeObject:popoverView];
                [self.registeredPopoverViews addObject:popoverView];
            }
        } else {
            @synchronized(self) {
                [self.appKeyWindow addSubview:popoverView.backgroundView];
                [self.appKeyWindow addSubview:popoverView];
                [self.registeredPopoverViews addObject:popoverView];
            }
        }
        if (!self.appKeyWindow.isKeyWindow) [self.appKeyWindow makeKeyAndVisible];
    }
}

- (void)unregisterPopoverView:(AXPopoverView *)popoverView {
    [popoverView removeFromSuperview];
    [popoverView.backgroundView removeFromSuperview];
    @synchronized(self) {
        [self.registeredPopoverViews removeObject:popoverView];
    }
    if (popoverView.showsOnPopoverWindow && self.isKeyWindow && self.referenceCount == 0) [self.appKeyWindow makeKeyAndVisible];
    [self setAppKeyWindow:nil];
}
@end
#pragma mark -
#pragma mark - Private classes
#pragma mark -
@implementation AXPopoverBarProgressView
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 240, 12)]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _progress = 0.0;
    _progressColor = [UIColor whiteColor];
    _lineColor = [UIColor whiteColor];
    _trackColor = [UIColor clearColor];
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context,_lineColor.CGColor);
    CGContextSetFillColorWithColor(context, _trackColor.CGColor);
    
    // Draw background
    CGFloat radius = (rect.size.height / 2) - 2;
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextFillPath(context);
    
    // Draw border
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, _progressColor.CGColor);
    radius = radius - 2;
    CGFloat amount = _progress * rect.size.width;
    
    // Progress in the middle area
    if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, amount, 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, amount, rect.size.height - 4);
        CGContextAddLineToPoint(context, amount, radius + 4);
        
        CGContextFillPath(context);
    }
    
    // Progress in the right arc
    else if (amount > radius + 4) {
        CGFloat x = amount - (rect.size.width - radius - 4);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
        CGFloat angle = -acos(x/radius);
        if isnan(angle) {
            angle = 0.0;
        }
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height / 2, radius, M_PI, angle, 0);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, rect.size.width - radius - 4, rect.size.height - 4);
        angle = acos(x/radius);
        if isnan(angle) {
            angle = 0.0;
        }
        CGContextAddArc(context, rect.size.width - radius - 4, rect.size.height / 2, radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(context, amount, rect.size.height/2);
        
        CGContextFillPath(context);
    } else if (amount < radius + 4 && amount > 0) {// Progress is in the left arc
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextMoveToPoint(context, 4, rect.size.height/2);
        CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
        CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
        
        CGContextFillPath(context);
    }
}
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    [self setNeedsDisplay];
}
@end
@implementation AXPopoverCircleProgressView
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 37, 37)]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    _progress = 0.0;
    _progressBgnColor = [UIColor colorWithWhite:1 alpha:.1];
    _progressColor = [UIColor whiteColor];
    _annularEnabled = NO;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Get a rect
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0, 2.0);
    // Get current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Draw
    if (_annularEnabled) {
        // draw background
        BOOL isPre_iOS_7_0 = kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_7_0;
        CGFloat lineWidth = isPre_iOS_7_0 ? 5.0 : 2.0;
        UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
        backgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        CGFloat radius = (self.bounds.size.width - lineWidth) / 2;
        // 90degree
        CGFloat startAngle = -(M_PI) / 2;
        CGFloat endAngle = startAngle + (2.0 * M_PI);
        [backgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressBgnColor set];
        [backgroundPath stroke];
        // draw progress
        UIBezierPath *progressPath = [UIBezierPath bezierPath];
        progressPath.lineCapStyle = isPre_iOS_7_0 ? kCGLineCapRound : kCGLineCapSquare;
        progressPath.lineWidth = lineWidth;
        endAngle = _progress * 2.0 * M_PI + startAngle;
        [progressPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressColor set];
        [progressPath stroke];
    } else {
        // draw background
        [_progressColor setStroke];
        [_progressBgnColor setFill];
        CGContextSetLineWidth(context, 1.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 8) / 2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [_progressColor setFill];
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressBgnColor:(UIColor *)progressBgnColor {
    _progressBgnColor = progressBgnColor;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setAnnularEnabled:(BOOL)annularEnabled {
    _annularEnabled = annularEnabled;
    [self setNeedsDisplay];
}
@end