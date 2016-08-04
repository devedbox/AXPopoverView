//
//  AXAttributedLabel.h
//  AXAttributedLabel
//
//  Created by ai on 16/5/6.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(uint64_t, AXAttributedLabelDetectorType) {    // a single type
    AXAttributedLabelDetectorTypeDate                  = NSTextCheckingTypeDate,
    AXAttributedLabelDetectorTypeAddress               = NSTextCheckingTypeAddress,
    AXAttributedLabelDetectorTypeLink                  = NSTextCheckingTypeLink,
    AXAttributedLabelDetectorTypePhoneNumber           = NSTextCheckingTypePhoneNumber,
    AXAttributedLabelDetectorTypeTransitInformation    = NSTextCheckingTypeTransitInformation,
    AXAttributedLabelDetectorTypeImage                 = 1ULL << 21
    /* No implementation.
     AXAttributedLabelDetectorTypeOrthography           = NSTextCheckingTypeOrthography,
     AXAttributedLabelDetectorTypeSpelling              = NSTextCheckingTypeSpelling,
     AXAttributedLabelDetectorTypeGrammar               = NSTextCheckingTypeGrammar,
     AXAttributedLabelDetectorTypeQuote                 = NSTextCheckingTypeQuote,
     AXAttributedLabelDetectorTypeDash                  = NSTextCheckingTypeDash,
     AXAttributedLabelDetectorTypeReplacement           = NSTextCheckingTypeReplacement,
     AXAttributedLabelDetectorTypeCorrection            = NSTextCheckingTypeCorrection,
     AXAttributedLabelDetectorTypeRegularExpression     = NSTextCheckingTypeRegularExpression,
     */
};

typedef uint64_t AXAttributedLabelDetectorTypes;

typedef NS_ENUM(NSInteger, AXAttributedLabelVerticalAlignment) {
    AXAttributedLabelVerticalAlignmentCenter   = 0,
    AXAttributedLabelVerticalAlignmentTop      = 1,
    AXAttributedLabelVerticalAlignmentBottom   = 2,
};

@protocol AXAttributedLabelDelegate;
@class    AXAttributedLabel;
@class    AXMenuItem;
NS_ASSUME_NONNULL_BEGIN

typedef void(^AXAttributedLabelLinkBlock)(AXAttributedLabel *_Nonnull, NSTextCheckingResult *_Nonnull result);
typedef void(^AXAttributedLabelExclusionViewsBlock)(AXAttributedLabel *_Nonnull, NSUInteger index);

extern NSString *const kAXAttributedLabelRequestCanBecomeFirstResponsderNotification;
extern NSString *const kAXAttributedLabelRequestCanResignFirstResponsderNotification;

NS_CLASS_AVAILABLE(10_0, 7_0) @interface AXAttributedLabel : UITextView
/// Delegate.
@property(assign, nonatomic, nullable) IBOutlet id<AXAttributedLabelDelegate> attribute;
/// Attributed.
@property(assign, nonatomic) IBInspectable BOOL attributedEnabled;
/// Detector for image. If pass null, the label instance will use `[~~~]` rule.
@property(copy, nonatomic, nullable) IBInspectable NSString    *imageDetector UI_APPEARANCE_SELECTOR;
/// Detector types.
@property(assign, nonatomic) AXAttributedLabelDetectorTypes     detectorTypes;
/// Vertical alignment.
@property(assign, nonatomic) AXAttributedLabelVerticalAlignment verticalAlignment;
/// Allows preview urls. Defaults is NO. This effects only when the vertical alignment is Top.
@property(assign, nonatomic) IBInspectable BOOL allowsPreviewURLs UI_APPEARANCE_SELECTOR;
/// Text checking results.
@property(readonly, copy, nonatomic, nullable) NSArray<NSTextCheckingResult *> *textCheckingResults;

/// Line break mode. Defaults is NSLineBreakByTruncatingTail.
@property(assign, NS_NONATOMIC_IOSONLY) NSLineBreakMode lineBreakMode;
/// Number of lines. Defaults is 0 means no limits.
@property(assign, NS_NONATOMIC_IOSONLY) NSUInteger      numberOfLines;

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize for multiline labels
@property(nonatomic) IBInspectable CGFloat preferredMaxLayoutWidth;

// Default value : empty array  An array of UIBezierPath representing the exclusion paths inside the receiver's bounding rect.
@property(copy, NS_NONATOMIC_IOSONLY) NSArray<UIBezierPath *> *exclusionPaths;
@property(copy, NS_NONATOMIC_IOSONLY) NSArray<UIView *> *exclusionViews;
@property(assign, nonatomic) IBInspectable BOOL shouldInteractWithExclusionViews UI_APPEARANCE_SELECTOR;// Defaults is NO.
@property(copy, nonatomic, nullable) AXAttributedLabelExclusionViewsBlock exclusionViewHandler;

// Blocks.
@property(copy, nonatomic, nullable) AXAttributedLabelLinkBlock urlHandler;// Block to handle url info.
@property(copy, nonatomic, nullable) AXAttributedLabelLinkBlock dateHandler;// Block to handle date info.
@property(copy, nonatomic, nullable) AXAttributedLabelLinkBlock phoneHandler;// Block to handle phone info.
@property(copy, nonatomic, nullable) AXAttributedLabelLinkBlock addressHandler;// Block to handle address info.
@property(copy, nonatomic, nullable) AXAttributedLabelLinkBlock transitHandler;// Block to hanle transit info.

@property(assign, nonatomic, getter=isInteractWithURLs)        IBInspectable BOOL shouldInteractWithURLs UI_APPEARANCE_SELECTOR;// Defaults is NO.
@property(assign, nonatomic, getter=isInteractWithAttachments) IBInspectable BOOL shouldInteractWithAttachments UI_APPEARANCE_SELECTOR;// Defaults is NO.

@property(assign, nonatomic) IBInspectable BOOL showsMenuItems UI_APPEARANCE_SELECTOR;// Defaults is NO.
@property(assign, nonatomic) IBInspectable BOOL dimBackgroundsOnMenuItems UI_APPEARANCE_SELECTOR;// Defaults is YES.

+ (instancetype)attributedLabel;
- (CGRect)boundingRectForTextRange:(NSRange)range;
- (CGSize)boundingSizeForLabelWithText:(NSString *)text font:(UIFont *_Nonnull)font exclusionPaths:(NSArray<UIBezierPath *> *_Nullable)exclusionPaths perferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth;

- (void)setMenuItems:(NSArray<AXMenuItem *>*)menuItems UI_APPEARANCE_SELECTOR;
- (void)addMenuItem:(AXMenuItem *)item,...;

/// Adds a link to a URL for a specified range in the label text.
///
/// @param url The url to be linked to
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
- (void)addLinkToURL:(NSURL *)url withRange:(NSRange)range;
/// Adds a link to an address for a specified range in the label text.
///
/// @param addressComponents A dictionary of address components for the address to be linked to
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
///
/// @discussion The address component dictionary keys are described in `NSTextCheckingResult`'s "Keys for Address Components."
- (void)addLinkToAddress:(NSDictionary *)addressComponents withRange:(NSRange)range;
/// Adds a link to a phone number for a specified range in the label text.
///
/// @param phoneNumber The phone number to be linked to.
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
- (void)addLinkToPhoneNumber:(NSString *)phoneNumber withRange:(NSRange)range;
/// Adds a link to a date for a specified range in the label text.
///
/// @param date The date to be linked to.
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
- (void)addLinkToDate:(NSDate *)date withRange:(NSRange)range;
/// Adds a link to a date with a particular time zone and duration for a specified range in the label text.
///
/// @param date The date to be linked to.
/// @param timeZone The time zone of the specified date.
/// @param duration The duration, in seconds from the specified date.
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
- (void)addLinkToDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration withRange:(NSRange)range;
/// Adds a link to transit information for a specified range in the label text.
///
/// @param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
/// @param range The range in the label text of the link. The range must not exceed the bounds of the receiver.
- (void)addLinkToTransitInformation:(NSDictionary *)components withRange:(NSRange)range;
@end

@protocol AXAttributedLabelDelegate <NSObject>
@required
/// Get the image of attachment in the label.
///
/// @param attributedLabel the attributed label to be add attachment.
/// @param result text checking result in attributed label.
- (UIImage *)imageAttachmentForAttributedLabel:(AXAttributedLabel *)attributedLabel result:(NSTextCheckingResult *)result;
@optional
/// Tells the delegate that the user did select a link to a URL.
///
/// @param attributedLabel The label whose link was selected.
/// @param url The URL for the selected link.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectURL:(NSURL *)url;
/// Tells the delegate that the user did select a link to an address.
///
/// @param attributedLabel The label whose link was selected.
/// @param addressComponents The components of the address for the selected link.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectAddress:(NSDictionary *)addressComponents;
/// Tells the delegate that the user did select a link to a phone number.
///
/// @param attributedLabel The label whose link was selected.
/// @param phoneNumber The phone number for the selected link.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectPhoneNumber:(NSString *)phoneNumber;
/// Tells the delegate that the user did select a link to a date.
///
/// @param attributedLabel The label whose link was selected.
/// @param date The datefor the selected link.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectDate:(NSDate *)date;
/// Tells the delegate that the user did select a link to a date with a time zone and duration.
///
/// @param attributedLabel The label whose link was selected.
/// @param date The date for the selected link.
/// @param timeZone The time zone of the date for the selected link.
/// @param duration The duration, in seconds from the date for the selected link.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration;
/// Tells the delegate that the user did select a link to transit information
///
/// @param attributedLabel The label whose link was selected.
/// @param components A dictionary containing the transit components. The currently supported keys are `NSTextCheckingAirlineKey` and `NSTextCheckingFlightKey`.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectTransitInformation:(NSDictionary *)components;
/// Tells the delegate that the user did select a attachment to a text checking result.
///
/// @param attributedLabel The label whose link was selected.
/// @param attachment The custom text attachment.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectAttachment:(NSTextAttachment *)attachment;
/// Tells the delegate that the user did select a link to a text checking result.
///
/// @discussion This method is called if no other delegate method was called, which can occur by either now implementing the method in `AXAttributedLabel` corresponding to a particular link, or the link was added by passing an instance of a custom `NSTextCheckingResult` subclass into `-addLinkWithTextCheckingResult:`.
///
/// @param attributedLabel The label whose link was selected.
/// @param result The custom text checking result.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result;
/// Tells the delegate that the user did select a index of exclusion view.
///
/// @param attributedLabel The label whose link was selected.
/// @param index The index of selected exclusion view.
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectExclusionViewAtIndex:(NSUInteger)index;
@end

typedef void(^AXMenuItemBlock)(AXAttributedLabel *_Nonnull label, AXMenuItem *_Nonnull item);

@interface AXMenuItem : NSObject
/// Title.
@property(readonly, nonatomic) NSString *title;
/// Handler.
@property(copy, nonatomic, nullable) AXMenuItemBlock handler;

- (instancetype)initWithTitle:(NSString *)title handler:(AXMenuItemBlock)handler;
+ (instancetype)itemWithTitle:(NSString *)title handler:(AXMenuItemBlock)handler;
@end

@interface AXAttributedStringOptions : NSObject
/// Attributes.
@property(strong, nonatomic, nullable) NSDictionary<NSString*, id> *attributes;
/// Image detector pattern.
@property(copy, nonatomic, nullable) NSString *imageDetectorPattern;
/// Should interact with URLs.
@property(assign, nonatomic) BOOL shouldInteractWithURLs;
/// Detector types.
@property(assign, nonatomic) AXAttributedLabelDetectorTypes detectorTypes;
/// Other links.
@property(copy, nonatomic, nullable) NSArray<NSTextCheckingResult *> *results;
/// Font.
@property(strong, nonatomic) UIFont *font;
/// Attributed label.
@property(weak, nonatomic, nullable) AXAttributedLabel *attributedLabel;
@end

@interface AXAttributedLabel (Unavailable)
#pragma mark - Unavailable Methods
- (void)scrollRangeToVisible:(NSRange)range __attribute__((unavailable("AXAttributedLabel cannot scroll range to visible rect for current version")));
- (void)setEditable:(BOOL)editable __attribute__((unavailable("AXAttributedLabel cannot set editable for current version. Default is NO.")));
- (void)setSelectable:(BOOL)selectable __attribute__((unavailable("AXAttributedLabel cannot set selectable for current version. Default is NO.")));
- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes __attribute__((unavailable("AXAttributedLabel cannot data detector types for current version. Default is null.")));
- (void)setAllowsEditingTextAttributes:(BOOL)allowsEditingTextAttributes __attribute__((unavailable("AXAttributedLabel cannot set allows editing text attributes for current version. Default is NO.")));
- (void)setTypingAttributes:(NSDictionary<NSString *,id> *)typingAttributes __attribute__((unavailable("AXAttributedLabel cannot set typing attributes for current version. Default is null.")));
- (void)setInputView:(UIView *_Nullable)inputView __attribute__((unavailable("AXAttributedLabel cannot set input view for current version.")));
- (void)setInputAccessoryView:(UIView *_Nullable)inputAccessoryView __attribute__((unavailable("AXAttributedLabel cannot set input accessory view for current version.")));
- (void)setDelegate:(id<UITextViewDelegate>)delegate __attribute__((unavailable("AXAttributedLabel cannot set delegate for current version.")));

- (void)setContentOffset:(CGPoint)contentOffset __attribute__((unavailable("AXAttributedLabel cannot set content offset for current version.")));
- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated __attribute__((unavailable("AXAttributedLabel cannot set content offset for current version.")));
- (void)setContentSize:(CGSize)contentSize __attribute__((unavailable("AXAttributedLabel cannot set content size for current version.")));
- (void)setContentInset:(UIEdgeInsets)contentInset __attribute__((unavailable("AXAttributedLabel cannot set content inset for current version.")));
- (void)setDirectionalLockEnabled:(BOOL)directionalLockEnabled __attribute__((unavailable("AXAttributedLabel cannot set directiona lLock enabled for current version.")));
- (void)setBounces:(BOOL)bounces __attribute__((unavailable("AXAttributedLabel cannot set bounces for current version.")));
- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical __attribute__((unavailable("AXAttributedLabel cannot set always bounce vertical for current version.")));
- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal __attribute__((unavailable("AXAttributedLabel cannot set always bounce horizontal for current version.")));
- (void)setPagingEnabled:(BOOL)pagingEnabled __attribute__((unavailable("AXAttributedLabel cannot set paging enabled for current version.")));
- (void)setScrollEnabled:(BOOL)scrollEnabled __attribute__((unavailable("AXAttributedLabel cannot set scroll enabled for current version.")));
- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator __attribute__((unavailable("AXAttributedLabel cannot set shows vertical scroll indicator for current version.")));
- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator __attribute__((unavailable("AXAttributedLabel cannot set shows horizontal scroll indicatorfor current version.")));
- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets __attribute__((unavailable("AXAttributedLabel cannot set scroll indicator insets for current version.")));
- (void)setIndicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle __attribute__((unavailable("AXAttributedLabel cannot set indicator style for current version.")));
- (void)setDecelerationRate:(CGFloat)decelerationRate __attribute__((unavailable("AXAttributedLabel cannot set deceleration rate for current version.")));
- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated __attribute__((unavailable("AXAttributedLabel cannot scroll rect to visible for current version.")));
- (void)flashScrollIndicators __attribute__((unavailable("AXAttributedLabel cannot flash scroll indicators for current version.")));
- (void)setDelaysContentTouches:(BOOL)delaysContentTouches __attribute__((unavailable("AXAttributedLabel cannot set delays content touches for current version.")));
- (void)setCanCancelContentTouches:(BOOL)canCancelContentTouches __attribute__((unavailable("AXAttributedLabel cannot set can cancel content touches for current version.")));
- (void)setMinimumZoomScale:(CGFloat)minimumZoomScale __attribute__((unavailable("AXAttributedLabel cannot set minimum zoom scale for current version.")));
- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale __attribute__((unavailable("AXAttributedLabel cannot set maximum zoom scale for current version.")));
- (void)setZoomScale:(CGFloat)zoomScale __attribute__((unavailable("AXAttributedLabel cannot set zoom scale for current version.")));
- (void)setZoomScale:(CGFloat)scale animated:(BOOL)animated __attribute__((unavailable("AXAttributedLabel cannot set zoom scale for current version.")));
- (void)zoomToRect:(CGRect)rect animated:(BOOL)animated __attribute__((unavailable("AXAttributedLabel cannot zoom to rect for current version.")));
- (void)setBouncesZoom:(BOOL)bouncesZoom __attribute__((unavailable("AXAttributedLabel cannot set bounces zoom for current version.")));
- (void)setScrollsToTop:(BOOL)scrollsToTop __attribute__((unavailable("AXAttributedLabel cannot set scrolls to top for current version.")));
- (void)setKeyboardDismissMode:(UIScrollViewKeyboardDismissMode)keyboardDismissMode __attribute__((unavailable("AXAttributedLabel cannot set keyboard dismiss mode for current version.")));
@end
NS_ASSUME_NONNULL_END