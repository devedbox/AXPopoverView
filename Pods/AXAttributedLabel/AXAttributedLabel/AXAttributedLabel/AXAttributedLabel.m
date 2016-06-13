//
//  AXAttributedLabel.m
//  AXAttributedLabel
//
//  Created by ai on 16/5/6.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXAttributedLabel.h"
#import <objc/runtime.h>

#ifndef kAXImageDetector
#define kAXImageDetector @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#endif

@interface AXTextAttachment : NSTextAttachment
/// Font size.
@property(assign, nonatomic) CGFloat fontSize;
@end

@implementation AXTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0,  -ceil((CGRectGetHeight(lineFrag)-_fontSize)*1.3), lineFrag.size.height, lineFrag.size.height);
}
@end

@interface _AXTextStorage : NSTextStorage
{
@private
    NSMutableAttributedString *_storage;
}
/// Detector types.
@property(assign, nonatomic) AXAttributedLabelDetectorTypes detectorTypes;
/// Image detector string.
@property(copy, nonatomic) NSString *imageDetector;
@end

static NSString *const kAXPhone = @"phone";
static NSString *const kAXDate = @"date";
static NSString *const kAXURL = @"url";
static NSString *const kAXAddress = @"address";
static NSString *const kAXTransit = @"transit";

NSString *const kAXAttributedLabelRequestCanBecomeFirstResponsderNotification = @"kAXAttributedLabelRequestCanBecomeFirstResponsderNotification";
NSString *const kAXAttributedLabelRequestCanResignFirstResponsderNotification = @"kAXAttributedLabelRequestCanResignFirstResponsderNotification";

@interface AXAttributedLabel ()<UITextViewDelegate, UIGestureRecognizerDelegate, NSLayoutManagerDelegate>
{
@private
    NSString *_storage;
    UIFont   *_font;
    UIColor  *_textColor;
    UIView   * __weak _textContainerView;
    /// Attributed label delegate.
    id<AXAttributedLabelDelegate> __weak __delegate;
    /// Touch background view.
    UIView  *_touchView;
    /// Touch begined.
    BOOL     _touchBegan;
    /// Should becom first responsder.
    BOOL     _shouldBecomFirstResponsder;
    /// Menu items.
    NSArray<UIMenuItem *>* _menuItems;
    /// Original menu items.
    NSArray<AXMenuItem *>* _originalMenuItems;
}
/// Links.
@property(strong, nonatomic) NSMutableArray *links;
/// Long press gesture.
@property(strong, nonatomic) UILongPressGestureRecognizer *longPressGesture;
@end
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
@interface AXAttributedLabel ()<UIViewControllerPreviewingDelegate>
@end
#endif
@interface NSURL (AXAttributedLabel)
/// Result object.
@property(readwrite, strong, nonatomic) NSTextCheckingResult *result;
/// Flag string.
@property(readwrite, strong, nonatomic) NSString *flag;
@end
@implementation NSURL (AXAttributedLabel)
- (NSTextCheckingResult *)result {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResult:(NSTextCheckingResult *)result {
    objc_setAssociatedObject(self, @selector(result), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)flag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlag:(NSString *)flag {
    objc_setAssociatedObject(self, @selector(flag), flag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)URLWithFlag:(NSString *)flag urlString:(NSString *)urlString result:(NSTextCheckingResult *)result {
    NSURL *url = [NSURL URLWithString:urlString?:flag];
    url.flag = flag;
    url.result = result;
    return url;
}
@end

@interface NSTextCheckingResult (AXAttributedLabel)
/// URL.
@property(readwrite, strong, nonatomic) NSURL *flagedUrl;
@end
@implementation NSTextCheckingResult (AXAttributedLabel)
- (NSURL *)flagedUrl {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlagedUrl:(NSURL * _Nullable)flagedUrl {
    objc_setAssociatedObject(self, @selector(flagedUrl), flagedUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation AXAttributedLabel
#pragma mark - Initializer
+ (instancetype)attributedLabel {
    AXAttributedLabel *label = [[AXAttributedLabel alloc] init];
    label.attributedEnabled = YES;
    return label;
}

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

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:CGRectZero textContainer:textContainer]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)initializer {
    // Super properties.
    typeof(self) __weak wsekf = self;
    super.editable     = NO;
    super.selectable   = YES;
    super.scrollsToTop = NO;
    super.delegate     = wsekf;
    //------------------
    _font              = super.font?:[UIFont systemFontOfSize:15];
    _textColor         = super.textColor?:[UIColor blackColor];
    _verticalAlignment = AXAttributedLabelVerticalAlignmentTop;
    self.detectorTypes = AXAttributedLabelDetectorTypeDate|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypePhoneNumber;
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    super.textContainerInset = UIEdgeInsetsMake(4, 0, 4, 0);
    // Set the image indicator view to hidden and get the refrence of the text container view.
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setHidden:YES];
            [view removeFromSuperview];
        } else if ([view isKindOfClass:NSClassFromString(@"_UITextContainerView")]) {
            _textContainerView = view;
            for (UIView *view in _textContainerView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UITextSelectionView")]) {
                    [view setHidden:YES];
                    [view setAlpha:0.0];
                    [view removeFromSuperview];
                }
            }
        }
    }
    // Set up layout manager.
    self.layoutManager.allowsNonContiguousLayout = NO;
    self.layoutManager.delegate = self;
    // Set up text container.
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textContainer.widthTracksTextView  = YES;
    self.textContainer.heightTracksTextView = YES;
    self.textContainer.lineFragmentPadding  = 0.0;
    self.numberOfLines = 0;
    // Set initializer value.
    [self setAllowsPreviewURLs:_allowsPreviewURLs?:NO];
    [self setShouldInteractWithURLs:_shouldInteractWithURLs?:NO];
    [self setShouldInteractWithAttachments:_shouldInteractWithAttachments?:NO];
    [self setShouldInteractWithExclusionViews:_shouldInteractWithExclusionViews?:NO];
    [self setDimBackgroundsOnMenuItems:_dimBackgroundsOnMenuItems?:YES];
    [self setShowsMenuItems:_showsMenuItems?:NO];
    // Set up long press gesture.
    [self addGestureRecognizer:self.longPressGesture];
    // Add notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuControllerWillHideNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Override
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([[[NSStringFromSelector(aSelector) componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"menuItem"]) {
        return self;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSInteger index = [[[NSStringFromSelector(anInvocation.selector) componentsSeparatedByString:@"_"] lastObject] integerValue];
    if (index != NSNotFound && index >= 0 && index <= _originalMenuItems.count-1) {
        AXMenuItem *item = _originalMenuItems[index];
        if (item.handler) {
            item.handler(self, item);
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([[[NSStringFromSelector(aSelector) componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"menuItem"]) {
        return [self.class instanceMethodSignatureForSelector:@selector(__didSelectMenuItem)];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([[[NSStringFromSelector(aSelector) componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"menuItem"]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}

- (BOOL)canBecomeFirstResponder {
    [[NSNotificationCenter defaultCenter] postNotificationName:kAXAttributedLabelRequestCanBecomeFirstResponsderNotification object:self];
    if (_shouldBecomFirstResponsder) {
        if (_dimBackgroundsOnMenuItems) {
            UIView *view = objc_getAssociatedObject(self, _cmd);
            if (!view) {
                view = [[UIView alloc] initWithFrame:self.bounds];
                view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
                view.alpha = 0;
                [self addSubview:view];
                [UIView animateWithDuration:0.1 animations:^{
                    view.alpha = 1.0;
                }];
                objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return YES;
    }
    UIViewController *viewController = nil;
    id next = self.nextResponder;
    while (![next isKindOfClass:[UIViewController class]]) {
        next = [next nextResponder];
    }
    viewController = next;
    if (viewController) {
        [viewController setEditing:NO];
    }
    return NO;
}

- (BOOL)canResignFirstResponder {
    [[NSNotificationCenter defaultCenter] postNotificationName:kAXAttributedLabelRequestCanResignFirstResponsderNotification object:self];
    if (_dimBackgroundsOnMenuItems) {
        UIView *view = objc_getAssociatedObject(self, @selector(canBecomeFirstResponder));
        if (view) {
            [UIView animateWithDuration:0.1 animations:^{
                view.alpha = 0.0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                objc_setAssociatedObject(self, @selector(canBecomeFirstResponder), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }];
        }
    }
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ([[[NSStringFromSelector(action) componentsSeparatedByString:@"_"] firstObject] isEqualToString:@"menuItem"]) {
        return YES;
    }
    if (action == @selector(paste:) || action == @selector(copy:) || action == @selector(cut:) || action == @selector(select:) || action == @selector(selectAll:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isMemberOfClass:NSClassFromString(@"_UIRevealGestureRecognizer")]) {
        if (_verticalAlignment != AXAttributedLabelVerticalAlignmentTop) {
            return NO;
        } else {
            return _allowsPreviewURLs;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Disable the pan force gesture.
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:NSClassFromString(@"_UITextSelectionForceGesture")]) {
            gesture.enabled = NO;
        }
    }
    // Hide the menu controller if needed.
    [self updateMenuControllerVisiable];
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 0 || !_shouldInteractWithExclusionViews) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIView *view in _exclusionViews) {
        if (CGRectContainsPoint(view.frame, point)) {
            _touchView.frame = CGRectInset(view.frame, -2, -2);
            _touchView.hidden = NO;
            _touchBegan = YES;
            objc_setAssociatedObject(_touchView, _cmd, view, OBJC_ASSOCIATION_ASSIGN);
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 0) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    if (_touchBegan) {
        CGPoint point = [[touches anyObject] locationInView:self];
        for (UIView *view in _exclusionViews) {
            if (CGRectContainsPoint(view.frame, point)) {
                _touchView.frame = CGRectInset(view.frame, -2, -2);
                _touchView.hidden = NO;
                objc_setAssociatedObject(_touchView, _cmd, view, OBJC_ASSOCIATION_ASSIGN);
            } else {
                _touchView.hidden = YES;
                objc_setAssociatedObject(_touchView, _cmd, nil, OBJC_ASSOCIATION_ASSIGN);
            }
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchBegan) {
        _touchView.hidden = YES;
        _touchBegan = NO;
        UIView *view = objc_getAssociatedObject(_touchView, @selector(touchesBegan:withEvent:));
        if (view) {
            [self didSelectExclusionViewsAtIndex:[_exclusionViews indexOfObject:view]];
            objc_setAssociatedObject(_touchView, @selector(touchesBegan:withEvent:), nil, OBJC_ASSOCIATION_ASSIGN);
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchBegan) {
        _touchView.hidden = YES;
        _touchBegan = NO;
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.translatesAutoresizingMaskIntoConstraints == NO) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize susize = [super sizeThatFits:size];
    susize.width = self.frame.size.width;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    susize.height = ceil([self.layoutManager usedRectForTextContainer:self.textContainer].size.height)+self.textContainerInset.top+self.textContainerInset.bottom;
    return susize;
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    if (size.width>0&&size.height>0) {
        return size;
    }
    
    size = [[self class] boundingSizeForLabelWithText:_storage font:_font exclusionPaths:self.exclusionPaths perferredMaxLayoutWidth:_preferredMaxLayoutWidth];
    
    return CGSizeMake(ceil(size.width)+self.textContainerInset.left+self.textContainerInset.right, ceil(size.height)+self.textContainerInset.top+self.textContainerInset.bottom);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Layout the text container view.
    if (_textContainerView) {
        self.textContainer.size = self.bounds.size;
        [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
        CGRect rect_container = _textContainerView.frame;
        [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
        CGSize usedSize = [self.layoutManager usedRectForTextContainer:self.textContainer].size;
        rect_container.size = CGSizeMake(ceil(usedSize.width)+self.textContainerInset.left+self.textContainerInset.right, ceil(usedSize.height+self.textContainerInset.top+self.textContainerInset.bottom));
        rect_container.size.width = MAX(rect_container.size.width, CGRectGetWidth(self.frame));
        if (CGRectGetHeight(rect_container)>=CGRectGetHeight(self.frame)) {
            // Use AXAttributedLabelVerticalAlignmentTop.
            rect_container.origin.y = .0;
            rect_container.size.height = CGRectGetHeight(self.frame);
        } else {
            // Use the vertical alignment.
            switch (_verticalAlignment) {
                case AXAttributedLabelVerticalAlignmentTop:
                    rect_container.origin.y = .0;
                    break;
                case AXAttributedLabelVerticalAlignmentBottom:
                    rect_container.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(rect_container);
                    break;
                case AXAttributedLabelVerticalAlignmentCenter:
                default:
                    rect_container.origin.y = CGRectGetHeight(self.frame)*.5-CGRectGetHeight(rect_container)*.5;
                    break;
            }
        }
        _textContainerView.frame = rect_container;
    }
}
#pragma mark - Getters
- (NSString *)text {
    return _storage?:super.text;
}

- (UIFont *)font {
    if (_attributedEnabled) {
        // Get the font of attributed string.
        if (self.attributedText.length == 0) {
            return super.font;
        }
        UIFont *font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        return font ? font : super.font;
    } else {
        return super.font;
    }
}

- (UIColor *)textColor {
    if (_attributedEnabled) {
        // Get the text color of attributed string.
        if (self.attributedText.length == 0) {
            return super.textColor;
        }
        UIColor *color = [self.attributedText attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
        return color?color:super.textColor;
    } else {
        return super.textColor;
    }
}

- (BOOL)isShouldInteractWithURLs {
    return _shouldInteractWithURLs;
}

- (BOOL)isShouldInteractWithAttachments {
    return _shouldInteractWithAttachments;
}

- (NSLineBreakMode)lineBreakMode {
    return self.textContainer.lineBreakMode;
}

- (NSUInteger)numberOfLines {
    return self.textContainer.maximumNumberOfLines;
}

- (NSArray<UIBezierPath *> *)exclusionPaths {
    return self.textContainer.exclusionPaths;
}

- (NSArray *)textCheckingResults {
    NSMutableArray *results = [_links mutableCopy];
    if (!results) {
        results = [@[] mutableCopy];
    }
    NSError *error;
    NSRegularExpression *image = [[NSRegularExpression alloc] initWithPattern:_imageDetector?_imageDetector:kAXImageDetector options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(error == nil, @"%@", error);
    NSDataDetector *other = [NSDataDetector dataDetectorWithTypes:_detectorTypes error:&error];
    NSAssert(error == nil, @"%@", error);
    [results addObjectsFromArray:[image matchesInString:_storage options:0 range:NSMakeRange(0, _storage.length)]];
    [results addObjectsFromArray:[other matchesInString:_storage options:0 range:NSMakeRange(0, _storage.length)]];
    return results;
}

- (UILongPressGestureRecognizer *)longPressGesture {
    if (_longPressGesture) return _longPressGesture;
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    _longPressGesture.minimumPressDuration = 0.3;
    // Required other gesture failure.
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gesture requireGestureRecognizerToFail:_longPressGesture];
        }
    }
    return _longPressGesture;
}
#pragma mark - Setters
- (void)setText:(NSString *)text {
    // Store the copy version of text.
    _storage = [text copy];
    if (_attributedEnabled) {
        // Set attributed label text string.
        super.text = nil;
        self.attributedText = [self attributedString];
    } else {
        self.attributedText = nil;
        super.dataDetectorTypes = UIDataDetectorTypeNone;
        super.text = _storage;
        super.font = _font;
        super.textColor = _textColor;
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    _font = font?:_font;
    if (_attributedEnabled) {
        // Set the font of attributed text.
        self.attributedText = [self attributedString];
    } else {
        super.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor?:_textColor;
    if (_attributedEnabled) {
        // Set the text color of attributed text.
        self.attributedText = [self attributedString];
    } else {
        super.textColor = textColor;
    }
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedEnabled:(BOOL)attributedEnabled {
    _attributedEnabled = attributedEnabled;
    [self setText:_storage];
}

- (void)setDetectorTypes:(AXAttributedLabelDetectorTypes)detectorTypes {
    _detectorTypes = detectorTypes;
    if (_shouldInteractWithURLs) {
        // Address.
        if (_detectorTypes&AXAttributedLabelDetectorTypeAddress) { if (!(super.dataDetectorTypes&UIDataDetectorTypeAddress)) {
            super.dataDetectorTypes|=UIDataDetectorTypeAddress;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeAddress) {
            super.dataDetectorTypes&=~UIDataDetectorTypeAddress;
        }}
        // Calendar event.
        if (_detectorTypes&AXAttributedLabelDetectorTypeDate) { if (!(super.dataDetectorTypes&UIDataDetectorTypeCalendarEvent)) {
            super.dataDetectorTypes|=UIDataDetectorTypeCalendarEvent;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeCalendarEvent) {
            super.dataDetectorTypes&=~UIDataDetectorTypeCalendarEvent;
        }}
        // Link.
        if (_detectorTypes&AXAttributedLabelDetectorTypeLink) { if (!(super.dataDetectorTypes&UIDataDetectorTypeLink)) {
            super.dataDetectorTypes|=UIDataDetectorTypeLink;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeLink) {
            super.dataDetectorTypes&=~UIDataDetectorTypeLink;
        }}
        // Phone number.
        if (_detectorTypes&AXAttributedLabelDetectorTypePhoneNumber) { if (!(super.dataDetectorTypes&UIDataDetectorTypePhoneNumber)) {
            super.dataDetectorTypes|=UIDataDetectorTypePhoneNumber;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypePhoneNumber) {
            super.dataDetectorTypes&=~UIDataDetectorTypePhoneNumber;
        }}
    } else {
        super.dataDetectorTypes=UIDataDetectorTypeNone;
    }
    [self setText:_storage];
}

- (void)setVerticalAlignment:(AXAttributedLabelVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    [self setNeedsLayout];
}

- (void)setAllowsPreviewURLs:(BOOL)allowsPreviewURLs {
    _allowsPreviewURLs = allowsPreviewURLs;
    // Disable the preview gesture.
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:NSClassFromString(@"_UIRevealGestureRecognizer")]) {
            if (_verticalAlignment != AXAttributedLabelVerticalAlignmentTop) {
                gesture.enabled = NO;
                return;
            }
            gesture.enabled = _allowsPreviewURLs;
        }
    }
}

- (void)setShouldInteractWithURLs:(BOOL)shouldInteractWithURLs {
    _shouldInteractWithURLs = shouldInteractWithURLs;
    [self setDetectorTypes:_detectorTypes];
}

- (void)setShouldInteractWithAttachments:(BOOL)shouldInteractWithAttachments {
    _shouldInteractWithAttachments = shouldInteractWithAttachments;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    self.textContainer.lineBreakMode = lineBreakMode;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    self.textContainer.maximumNumberOfLines = numberOfLines;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setExclusionPaths:(NSArray<UIBezierPath *> *)exclusionPaths {
    self.textContainer.exclusionPaths = exclusionPaths;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setExclusionViews:(NSArray<UIView *> *)exclusionViews {
    _exclusionViews = [exclusionViews copy];
    NSMutableArray *exclusionPaths = [@[] mutableCopy];
    for (UIView *view in _textContainerView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in _exclusionViews) {
        CGRect frame = view.frame;
        frame.origin.x += self.textContainerInset.left;
        frame.origin.y += self.textContainerInset.top;
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:view.frame cornerRadius:view.layer.cornerRadius];
        [exclusionPaths addObject:bezier];
        view.frame = frame;
        [_textContainerView addSubview:view];
        view.userInteractionEnabled = YES;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
//        if ([[[UIDevice currentDevice] systemVersion] intValue]>=9) {
//            UIViewController *viewController = nil;
//            id nextResponsder = self.nextResponder;
//            while (![nextResponsder isKindOfClass:[UIViewController class]]) {
//                nextResponsder = [nextResponsder nextResponder];
//            }
//            viewController = nextResponsder;
//            if (viewController) {
//                [viewController registerForPreviewingWithDelegate:self sourceView:view];
//            }
//        }
#endif
    }
    [self setExclusionPaths:exclusionPaths];
    if (!_touchView) {
        _touchView = [[UIView alloc] initWithFrame:CGRectZero];
        _touchView.layer.cornerRadius = 4.0;
        _touchView.layer.masksToBounds = YES;
        _touchView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _touchView.hidden = YES;
        [_textContainerView addSubview:_touchView];
    }
}

- (void)setShowsMenuItems:(BOOL)showsMenuItems {
    _showsMenuItems = showsMenuItems;
    self.longPressGesture.enabled = showsMenuItems;
}

#pragma mark - Public
- (void)setMenuItems:(NSArray<AXMenuItem *> *)menuItems {
    _originalMenuItems = [menuItems copy];
    NSMutableArray *__menuItems = [@[] mutableCopy];
    for (NSInteger i = 0; i < _originalMenuItems.count; i++) {
        [__menuItems addObject:[[UIMenuItem alloc] initWithTitle:_originalMenuItems[i].title action:NSSelectorFromString([NSString stringWithFormat:@"menuItem_%@", @(i)])]];
    }
    _menuItems = [__menuItems copy];
}

- (void)addMenuItem:(AXMenuItem *)item, ... {
    va_list args;
    va_start(args, item);
    AXMenuItem *_item;
    if (!_originalMenuItems) {
        _originalMenuItems = @[];
    }
    NSMutableArray *items = [_originalMenuItems mutableCopy];
    [items addObject:item];
    while ((_item = va_arg(args, AXMenuItem *))) {
        [items addObject:_item];
    }
    va_end(args);
    [self setMenuItems:items];
}

- (void)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    if (!_links) {
        _links = [@[] mutableCopy];
    }
    if (![_links containsObject:result]) {
        [_links addObject:result];
    }
    [self setText:_storage];
}

- (void)addLinkToURL:(NSURL *)url withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult linkCheckingResultWithRange:range URL:url];
    result.flagedUrl = [NSURL URLWithFlag:kAXURL urlString:url.absoluteString result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToAddress:(NSDictionary *)addressComponents withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult addressCheckingResultWithRange:range components:addressComponents];
    result.flagedUrl = [NSURL URLWithFlag:kAXURL urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToPhoneNumber:(NSString *)phoneNumber withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult phoneNumberCheckingResultWithRange:range phoneNumber:phoneNumber];
    result.flagedUrl = [NSURL URLWithFlag:kAXPhone urlString:[NSString stringWithFormat:@"tel:%@",phoneNumber] result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToDate:(NSDate *)date withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult dateCheckingResultWithRange:range date:date];
    result.flagedUrl = [NSURL URLWithFlag:kAXDate urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult dateCheckingResultWithRange:range date:date timeZone:timeZone duration:duration];
    result.flagedUrl = [NSURL URLWithFlag:kAXDate urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToTransitInformation:(NSDictionary *)components withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult transitInformationCheckingResultWithRange:range components:components];
    result.flagedUrl = [NSURL URLWithFlag:kAXTransit urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}

- (CGRect)boundingRectForTextRange:(NSRange)range {
    return [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
}

+ (CGSize)boundingSizeForLabelWithText:(NSString *)text font:(UIFont *_Nonnull)font exclusionPaths:(NSArray<UIBezierPath *> *)exclusionPaths perferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth {
    NSTextStorage *textStorage = [NSTextStorage new];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(preferredMaxLayoutWidth, CGFLOAT_MAX)];
    
    layoutManager.allowsNonContiguousLayout = NO;
    
    textContainer.maximumNumberOfLines = 0;
    textContainer.widthTracksTextView = YES;
    textContainer.heightTracksTextView = YES;
    textContainer.lineFragmentPadding = .0;
    textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    AXAttributedStringOptions *options = [AXAttributedStringOptions new];
    options.detectorTypes = [[self appearance] detectorTypes]|(AXAttributedLabelDetectorTypeDate|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypeImage|AXAttributedLabelDetectorTypeAddress|AXAttributedLabelDetectorTypePhoneNumber|AXAttributedLabelDetectorTypeTransitInformation);
    options.imageDetectorPattern = [[self appearance] imageDetector]?:kAXImageDetector;
    options.attributes = @{NSForegroundColorAttributeName:[[self appearance] textColor]?:[UIColor blackColor]};
    options.shouldInteractWithURLs = YES;
    options.results = nil;
    options.font = font;
    options.attributedLabel = nil;
    
    [textStorage setAttributedString:[[self class] attributedStringWithString:text?:@"" options:options]];
    
    if (exclusionPaths.count > 0) {
        textContainer.exclusionPaths = [exclusionPaths copy];
    }
    
    [layoutManager ensureLayoutForTextContainer:textContainer];
    CGSize size = [layoutManager usedRectForTextContainer:textContainer].size;
    
    return size;
}
#pragma mark - Private
+ (NSAttributedString *)attributedStringWithString:(NSString *)string options:(AXAttributedStringOptions *)options {
    if (string.length == 0) {
        return [NSAttributedString new];
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[string copy]];
    [attributedString setAttributes:options.attributes range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSFontAttributeName value:options.font range:NSMakeRange(0, string.length)];
    
    NSError *error;
    
    if (options.detectorTypes&AXAttributedLabelDetectorTypeImage) {
        static NSRegularExpression *imageRE;
        imageRE = imageRE?:[[NSRegularExpression alloc] initWithPattern:options.imageDetectorPattern?options.imageDetectorPattern:kAXImageDetector options:NSRegularExpressionCaseInsensitive error:&error];
        NSAssert(error == nil, @"%@", error);
        [imageRE enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            AXTextAttachment *attachment = [[AXTextAttachment alloc] initWithData:nil ofType:nil];
            attachment.fontSize = [options.font pointSize];
            NSString *imageString = [string substringWithRange:result.range];
            if (options.attributedLabel.attribute && [options.attributedLabel.attribute respondsToSelector:@selector(imageAttachmentForAttributedLabel:result:)]) {
                attachment.image = [options.attributedLabel.attribute imageAttachmentForAttributedLabel:options.attributedLabel result:[result copy]];
            }
            NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSRange targetRange = [attributedString.string rangeOfString:imageString];
            [attributedString replaceCharactersInRange:targetRange withAttributedString:attachString];
            [attributedString addAttribute:NSFontAttributeName value:options.font range:NSMakeRange(targetRange.location, 1)];
        }];
    } if (options.detectorTypes&AXAttributedLabelDetectorTypeTransitInformation) {
        // Transit information detector.
        static NSDataDetector *transitInformation;
        transitInformation = transitInformation?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeTransitInformation error:&error];
        NSAssert(error == nil, @"%@", error);
        [transitInformation enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString *_string = [string substringWithRange:result.range];
            NSURL *url = [NSURL URLWithFlag:kAXTransit urlString:nil result:[result copy]];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:options.font}];
            NSRange targetRange = [attributedString.string rangeOfString:_string];
            [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
        }];
    }
    if (!options.shouldInteractWithURLs) {
        if (options.detectorTypes&AXAttributedLabelDetectorTypeDate) {
            // Date detecor.
            static NSDataDetector *date;
            date = date?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
            NSAssert(error == nil, @"%@", error);
            [date enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *_string = [string substringWithRange:result.range];
                NSString *dateStr = _string;
                NSURL *url = [NSURL URLWithFlag:kAXDate urlString:nil result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url?:dateStr,NSFontAttributeName:options.font}];
                NSRange targetRange = [attributedString.string rangeOfString:_string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (options.detectorTypes&AXAttributedLabelDetectorTypeLink) {
            // Link detecor.
            static NSDataDetector *link;
            link = link?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            NSAssert(error == nil, @"%@", error);
            [link enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *_string = [string substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXURL urlString:_string result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:options.font}];
                NSRange targetRange = [attributedString.string rangeOfString:_string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (options.detectorTypes&AXAttributedLabelDetectorTypeAddress) {
            // Address detecor.
            static NSDataDetector *address;
            address = address?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress error:&error];
            NSAssert(error == nil, @"%@", error);
            [address enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *_string = [string substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXAddress urlString:nil result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:options.font}];
                NSRange targetRange = [attributedString.string rangeOfString:_string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (options.detectorTypes&AXAttributedLabelDetectorTypePhoneNumber) {
            // Phone number detecor.
            static NSDataDetector *phone;
            phone = phone?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
            NSAssert(error == nil, @"%@", error);
            [phone enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *_string = [string substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXPhone urlString:[NSString stringWithFormat:@"tel:%@",_string] result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:options.font}];
                NSRange targetRange = [attributedString.string rangeOfString:_string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        }
    }
    
    for (NSTextCheckingResult *result in options.results) {
        NSString *_string = [string substringWithRange:result.range];
        NSURL *url = [NSURL URLWithFlag:result.flagedUrl.flag urlString:result.flagedUrl.absoluteString result:[result copy]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:_string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:options.font}];
        NSRange targetRange = [attributedString.string rangeOfString:_string];
        [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
    }
    return attributedString;
}

- (NSAttributedString *)attributedString {
    AXAttributedStringOptions *options = [AXAttributedStringOptions new];
    options.detectorTypes = _detectorTypes;
    options.imageDetectorPattern = _imageDetector;
    options.attributes = @{NSForegroundColorAttributeName:_textColor};
    options.shouldInteractWithURLs = _shouldInteractWithURLs;
    options.results = _links;
    options.font = _font;
    options.attributedLabel = self;
    return [[self class] attributedStringWithString:_storage options:options];
}

- (void)didSelectExclusionViewsAtIndex:(NSUInteger)index {
    if (_exclusionViewHandler) {
        _exclusionViewHandler(self, index);
    }
    if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectExclusionViewAtIndex:)]) {
        [_attribute attributedLabel:self didSelectExclusionViewAtIndex:index];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _shouldBecomFirstResponsder = YES;
            if ([self becomeFirstResponder]) {
                UIMenuController *menuController = [UIMenuController sharedMenuController];
                [menuController setMenuItems:_menuItems];
                [menuController setTargetRect:self.bounds inView:self];
                [menuController setMenuVisible:YES animated:YES];
            }
            break;
        default:
            _shouldBecomFirstResponsder = NO;
            break;
    }
}

- (void)__didSelectMenuItem{}
#pragma mark -
- (void)setupNormalMenuController {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)updateMenuControllerVisiable {
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
    [self setupNormalMenuController];
}

- (void)handleMenuControllerWillHideNotification:(NSNotification *)aNotification {
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
    }
}
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {return NO;}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {return NO;}
- (void)textViewDidBeginEditing:(UITextView *)textView {}
- (void)textViewDidEndEditing:(UITextView *)textView {}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {return NO;}
- (void)textViewDidChange:(UITextView *)textView {}
- (void)textViewDidChangeSelection:(UITextView *)textView {}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (_shouldInteractWithURLs) {
        return _shouldInteractWithURLs;
    }
    if ([URL.flag isEqualToString:kAXURL]) {// url.
        if (_urlHandler) {
            _urlHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectURL:)]) {
            [_attribute attributedLabel:self didSelectURL:URL];
        }
    } else if ([URL.flag isEqualToString:kAXDate]) {// date.
        if (_dateHandler) {
            _dateHandler(self, URL.result);
        }
        if (URL.result.timeZone && [_attribute respondsToSelector:@selector(attributedLabel:didSelectDate:timeZone:duration:)]) {
            [_attribute attributedLabel:self didSelectDate:URL.result.date timeZone:URL.result.timeZone duration:URL.result.duration];
        } if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectDate:)]) {
            [_attribute attributedLabel:self didSelectDate:URL.result.date];
        }
    } else if ([URL.flag isEqualToString:kAXPhone]) {// phone number.
        if (_phoneHandler) {
            _phoneHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectPhoneNumber:)]) {
            [_attribute attributedLabel:self didSelectPhoneNumber:[[URL.absoluteString componentsSeparatedByString:@":"] lastObject]];
        }
    } else if ([URL.flag isEqualToString:kAXAddress]) {// address.
        if (_addressHandler) {
            _addressHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectAddress:)]) {
            [_attribute attributedLabel:self didSelectAddress:URL.result.addressComponents];
        }
    } else if ([URL.flag isEqualToString:kAXTransit]) {// transit.
        if (_transitHandler) {
            _transitHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectTransitInformation:)]) {
            [_attribute attributedLabel:self didSelectTransitInformation:URL.result.components];
        }
    } else {
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectTextCheckingResult:)]) {
            [_attribute attributedLabel:self didSelectTextCheckingResult:URL.result];
        }
    }
    return _shouldInteractWithURLs;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (_shouldInteractWithURLs) {
        return _shouldInteractWithURLs;
    }
    if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectAttachment:)]) {
        [_attribute attributedLabel:self didSelectAttachment:textAttachment];
    }
    return _shouldInteractWithAttachments;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
#pragma mark - UIViewControllerPreviewingDelegate
- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    return nil;
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
}
#endif

#pragma mark - NSLayoutManagerDelegate
- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender {
    [self invalidateIntrinsicContentSize];
}
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    [self invalidateIntrinsicContentSize];
}
- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize {
    [self invalidateIntrinsicContentSize];
}
@end

@implementation AXMenuItem
@synthesize title = _title;
- (instancetype)initWithTitle:(NSString *)title handler:(AXMenuItemBlock)handler {
    if (self = [super init]) {
        _title = [title copy];
        _handler = [handler copy];
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title handler:(AXMenuItemBlock)handler {
    return [[AXMenuItem alloc] initWithTitle:title handler:handler];
}
@end

@implementation AXAttributedStringOptions
@end