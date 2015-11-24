//
//  AXPopoverBubbleView.m
//  AXPopoverView
//
//  Created by ai on 15/11/16.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPopoverView.h"
#import <objc/runtime.h>

@interface AXPopoverView()
{
    UIView   *_contentView;
    UIView   *_backgroundView;
    CGPoint   _arrowPosition;
    CGRect    _targetRect;
    UIColor  *_backgroundDrawingColor;
    dispatch_block_t _showsCompletion;
    dispatch_block_t _hidesCompletion;
}
@property(weak, nonatomic) UIWindow *previousKeyWindow __deprecated;
@property(weak, nonatomic) UITapGestureRecognizer *tap;
@property(weak, nonatomic) UIPanGestureRecognizer *pan;
@end

NSString *const AXPopoverPriorityHorizontal = @"AXPopoverPriorityHorizontal";
NSString *const AXPopoverPriorityVertical = @"AXPopoverPriorityVertical";

UIWindow static *_popoverWindow;

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
    [self addSubview:self.contentView];
    [self setUpWindow];
}

- (void)dealloc {
    [self.popoverWindow unregisterPopoverView:self];
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
    CGContextFillPath(cxt);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize susize = [super sizeThatFits:size];
    CGSize minSize = [self minSize];
    susize.width = MAX(susize.width, minSize.width);
    susize.height = MAX(susize.height, minSize.height);
    return susize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect_self = self.frame;
    CGSize minSize = self.minSize;
    rect_self.size.width = MAX(CGRectGetWidth(rect_self), minSize.width);
    rect_self.size.height = MAX(CGRectGetHeight(rect_self), minSize.height);
    self.frame = rect_self;
    UIEdgeInsets contentInsets = self.contentViewInsets;
    CGRect rect = _contentView.frame;
    rect.origin.x = contentInsets.left;
    rect.origin.y = contentInsets.top;
    rect.size = CGSizeMake(CGRectGetWidth(self.bounds) - (contentInsets.left + contentInsets.right), CGRectGetHeight(self.bounds) - (contentInsets.top + contentInsets.bottom));
    _contentView.frame = rect;
    [self updateFrameWithRect:_targetRect];
}

#pragma mark - Getters
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

#pragma mark - Setters
- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setArrowAngle:(CGFloat)arrowAngle {
    _arrowAngle = arrowAngle;
    [self setNeedsDisplay];
}

- (void)setArrowConstant:(CGFloat)arrowConstant {
    _arrowConstant = arrowConstant;
    [self setNeedsDisplay];
}

- (void)setArrowCornerRadius:(CGFloat)arrowCornerRadius {
    _arrowCornerRadius = arrowCornerRadius;
    [self setNeedsDisplay];
}

- (void)setArrowDirection:(AXPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self setNeedsDisplay];
}

- (void)setPriority:(NSString *)priority {
    _priority = [priority copy];
    [self setNeedsDisplay];
}

- (UIColor *)backgroundColor {
    return _backgroundDrawingColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[UIColor clearColor]];
    _backgroundDrawingColor = backgroundColor;
    [self setNeedsDisplay];
}

#pragma mark - Shows&Hides
- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(dispatch_block_t)completion
{
    _targetRect = rect;
    if (!self.popoverWindow.isKeyWindow) {
        [self.popoverWindow setAppKeyWindow:[UIApplication sharedApplication].keyWindow];
        [self.popoverWindow makeKeyAndVisible];
    }
    [self.popoverWindow registerPopoverView:self];
    [self layoutSubviews];
    _showsCompletion = [completion copy];
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

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion
{
    NSTimeInterval animationDuration = animated?0.25:0.0;
    _hidesCompletion = [completion copy];
    [self viewWillHide:animated];
    if (!_animator.hiding) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.alpha = 0.0;
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
    [UIView animateWithDuration:animationDuration animations:^{
        _backgroundView.alpha = 0.0;
    } completion:nil];
}

- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [self showInRect:rect animated:animated completion:^{
        [self performSelector:@selector(delayHide) withObject:nil afterDelay:duration];
    }];
}

- (void)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [self showFromView:view animated:animated completion:^{
        [self performSelector:@selector(delayHide) withObject:nil afterDelay:duration];
    }];
}

- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion {
    CGRect rect = [view.superview convertRect:view.frame toView:view.window];
    [self showInRect:rect animated:animated completion:completion];
}

- (void)delayHide {
    [self hideAnimated:YES afterDelay:0 completion:nil];
}

- (void)viewWillShow:(BOOL)animated {
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
    if (_showsCompletion) _showsCompletion();
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewDidShow:animated:)]) {
        [_delegate popoverViewDidShow:self animated:animated];
    }
}
- (void)viewWillHide:(BOOL)animated {
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
    self.alpha = 1.0;
    _backgroundView.alpha = 1.0;
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    [self setNeedsLayout];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.popoverWindow unregisterPopoverView:self];
    if (self.popoverWindow.referenceCount == 0) {
        [self.popoverWindow.appKeyWindow makeKeyAndVisible];
    }
    if (_hidesCompletion) _hidesCompletion();
    if (_delegate && [_delegate respondsToSelector:@selector(popoverViewDidHide:animated:)]) {
        [_delegate popoverViewDidHide:self animated:animated];
    }
}

#pragma mark - Actions
- (void)handleGestures:(id)sender __deprecated {
    [self hideAnimated:YES afterDelay:0.1f completion:nil];
}

#pragma mark - Helper

- (void)setUpWindow {
    _backgroundView = [[UIView alloc] initWithFrame:self.popoverWindow.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
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
        if (margins.left > CGRectGetWidth(self.bounds) && (margins.top - _offsets.y > _cornerRadius || margins.bottom > _cornerRadius)) {// 左边显示
            [availableDirections addObject:@(AXPopoverArrowDirectionRight)];
        } if (margins.right > CGRectGetWidth(self.bounds) && (margins.top - _offsets.y > _cornerRadius || margins.bottom > _cornerRadius)) {// 右边显示
            [availableDirections addObject:@(AXPopoverArrowDirectionLeft)];
        } if (margins.top > CGRectGetHeight(self.bounds) && (margins.left - _offsets.x > _cornerRadius || margins.right > _cornerRadius)) {// 优先在上方显示
            [availableDirections addObject:@(AXPopoverArrowDirectionBottom)];
        } if (margins.bottom > CGRectGetHeight(self.bounds) && (margins.left - _offsets.x > _cornerRadius || margins.right > _cornerRadius)) {// 下方显示
            [availableDirections addObject:@(AXPopoverArrowDirectionTop)];
        }
    } else {
        if (margins.top > CGRectGetHeight(self.bounds) && (margins.left - _offsets.x > _cornerRadius || margins.right > _cornerRadius)) {// 优先在上方显示
            [availableDirections addObject:@(AXPopoverArrowDirectionBottom)];
        } if (margins.bottom > CGRectGetHeight(self.bounds) && (margins.left - _offsets.x > _cornerRadius || margins.right > _cornerRadius)) {// 下方显示
            [availableDirections addObject:@(AXPopoverArrowDirectionTop)];
        } if (margins.left > CGRectGetWidth(self.bounds) && (margins.top - _offsets.y > _cornerRadius || margins.bottom > _cornerRadius)) {// 左边显示
            [availableDirections addObject:@(AXPopoverArrowDirectionRight)];
        } if (margins.right > CGRectGetWidth(self.bounds) && (margins.top - _offsets.y > _cornerRadius || margins.bottom > _cornerRadius)) {// 右边显示
            [availableDirections addObject:@(AXPopoverArrowDirectionLeft)];
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
    return AXPopoverArrowDirectionTop;
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
    if (xConstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, MAX(xConstant, _cornerRadius), CGRectGetMinY(self.bounds) + height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant - constant, CGRectGetMinY(self.bounds) + height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMinY(self.bounds) + height, xConstant + constantX, CGRectGetMinY(self.bounds) + height - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMinY(self.bounds));
    xConstant = x + arrowWidth_2;
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
    if (xConstant + constant > CGRectGetWidth(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, MIN(xConstant, CGRectGetWidth(self.bounds) - _cornerRadius), CGRectGetMaxY(self.bounds) - height);
    } else {
        CGContextAddLineToPoint(cxt, xConstant + constant, CGRectGetMaxY(self.bounds) - height);
        CGContextAddArcToPoint(cxt, xConstant, CGRectGetMaxY(self.bounds) - height, xConstant - constantX, CGRectGetMaxY(self.bounds) - height + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, x, CGRectGetMaxY(self.bounds));
    xConstant = x - arrowWidth_2;
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
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant + constant);
        CGContextAddArcToPoint(cxt, CGRectGetMinX(self.bounds) + width, Yconstant, CGRectGetMinX(self.bounds) + width - constantX, Yconstant - constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMinX(self.bounds), y);
    Yconstant = y - arrowHtight_2;
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
    if (Yconstant - constant < _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MAX(Yconstant, _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant - constant);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant + constantY, _arrowCornerRadius);
    }
    CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds), y);
    Yconstant = y + arrowHtight_2;
    if (Yconstant + constant > CGRectGetHeight(self.bounds) - _cornerRadius) {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width, MIN(Yconstant, CGRectGetHeight(self.bounds) - _cornerRadius));
    } else {
        CGContextAddLineToPoint(cxt, CGRectGetMaxX(self.bounds) - width + constantX, Yconstant - constantY);
        CGContextAddArcToPoint(cxt, CGRectGetMaxX(self.bounds) - width, Yconstant, CGRectGetMaxX(self.bounds) - width, Yconstant + constant, _arrowCornerRadius);
    }
}

- (void)removeGestures __deprecated {
    [self.popoverWindow removeGestureRecognizer:self.tap];
    [self.popoverWindow removeGestureRecognizer:self.pan];
    self.tap = nil;
    self.pan = nil;
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
    if (self.referenceCount == 0) {
        
    }
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
}

- (void)unregisterPopoverView:(AXPopoverView *)popoverView {
    if (popoverView.superview == self) {
        [popoverView removeFromSuperview];
        [popoverView.backgroundView removeFromSuperview];
        @synchronized(self) {
            [self.registeredPopoverViews removeObject:popoverView];
        }
    }
}
@end