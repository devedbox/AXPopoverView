//
//  AXPopoverBubbleView.h
//  AXPopoverView
//
//  Created by ai on 15/11/16.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString *const AXPopoverPriorityHorizontal;
UIKIT_EXTERN NSString *const AXPopoverPriorityVertical;

#ifndef AXP_REQUIRES_SUPER
#define AXP_REQUIRES_SUPER __attribute((objc_requires_super))
#endif

@class AXPopoverView, AXPopoverViewAnimator;
@protocol AXPopoverViewDelegate <NSObject>
@optional
/// Called when popover view will show with animation.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewWillShow:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view is in showing animation block.
///
/// @discusstion You can add custom animation block to the main animation block
///              by implement the method.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewShowing:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view has shown.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewDidShow:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view will hide.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewWillHide:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view is in hiding animation block.
///
/// @discusstion You can add custom animation block to the main animation block
///              by implement the method.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewHiding:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view has hidden.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
- (void)popoverViewDidHide:(AXPopoverView *)popoverView animated:(BOOL)animated;
@end
/// Enum of arrow direction.
typedef NS_ENUM(NSUInteger, AXPopoverArrowDirection) {
    /// Arrow on any direction.
    AXPopoverArrowDirectionAny,
    /// Arrow on the top.
    AXPopoverArrowDirectionTop,
    /// Arrow on the left.
    AXPopoverArrowDirectionLeft,
    /// Arrow on the bottom.
    AXPopoverArrowDirectionBottom,
    /// Arrow on the right.
    AXPopoverArrowDirectionRight
};

typedef void(^AXPopoverViewAnimation)(AXPopoverView *popoverView, BOOL animated, CGRect targetRect);
///
@interface AXPopoverView : UIView
/// Origin of frame when display the view.
@property(assign, nonatomic) CGPoint offsets UI_APPEARANCE_SELECTOR;
/// Min size of popover view.
@property(readonly, nonatomic) CGSize minSize;
/// Arrow direction priority.
@property(copy, nonatomic)   NSString *priority UI_APPEARANCE_SELECTOR;
/// Angle of arrrow. Defaults to 90.
@property(assign, nonatomic) CGFloat arrowAngle UI_APPEARANCE_SELECTOR;
/// Dim the background or not. Defaults to not.
@property(assign, nonatomic) BOOL dimBackground;
/// Corner radius of popover view.
@property(assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;
/// Arrow length.
@property(assign, nonatomic) CGFloat arrowConstant UI_APPEARANCE_SELECTOR;
/// Conent view.
@property(readonly, nonatomic) UIView *contentView;
/// Corner radius of arrow.
@property(assign, nonatomic)   CGFloat arrowCornerRadius UI_APPEARANCE_SELECTOR;
/// Position of arrow.
@property(readonly, nonatomic) CGPoint arrowPosition;
/// Animated from origin point.
@property(readonly, nonatomic) CGPoint animatedFromPoint;
/// Insets of content view.
@property(readonly, nonatomic) UIEdgeInsets contentViewInsets;
/// Delegate.
@property(assign, nonatomic) id<AXPopoverViewDelegate>delegate;
/// Direction of arrow.
@property(readonly, nonatomic)   AXPopoverArrowDirection arrowDirection;
/// Prefered direction of arrow.
@property(assign, nonatomic)     AXPopoverArrowDirection preferredArrowDirection UI_APPEARANCE_SELECTOR;
/// Should remove from super view when hidden or not.
@property(assign, nonatomic) BOOL removeFromSuperViewOnHide;
/// Background drawing color
@property(strong, nonatomic) UIColor *backgroundDrawingColor UI_APPEARANCE_SELECTOR;
/// Animator.
@property(strong, nonatomic) AXPopoverViewAnimator *animator UI_APPEARANCE_SELECTOR;
/// Show the popover view in a rect in the new popover window.
/// @discusstion the rect is a specific rect in the popover window which is normlly same as the application
///              key window.
///
/// @param rect       the rect in the popover winow.
/// @param animated   a boolean value to decide show popover view with or without animation.
/// @param completion a completion call back block when the shows animation finished.
- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(nullable dispatch_block_t)completion;
/// Hide the showing popover view with a delay time internal.
///
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param delay    a double value to descrip delay time time internal.
/// @param completion a completion call back block when the hides animation finished.
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(nullable dispatch_block_t)completion;
/// Show the popover view in a rect in the new popover window with a constant time internal.
/// @discusstion Show the popover view with a time dutation, and from the popover view shows completely on,
///              the popover view will hide automaticly after the time duration.
///
/// @param rect     the rect in the popover window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration;
/// Show the popover view from a view in the application key and main window with a time duration.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
- (void)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration;
/// Show the popover view from a view in the application key and main window with a completion call back block.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated   a boolean value to decide show popover view with or without animation.
/// @param completion a completion call back block when the shows animation finished.
- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(nullable dispatch_block_t)completion;
//
//
// These methods is called during popover view's showing or hiding blcok. If overriding a custom antion of animation,
// you need to call `super` first.
//
//
/// View will show with a animated value.
/// @discusstion Called when the popover view will show. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewWillShow:(BOOL)animated AXP_REQUIRES_SUPER;
/// View is in showing with a animated value.
/// @discusstion Called when the popover view is in showing. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewShowing:(BOOL)animated AXP_REQUIRES_SUPER;
/// View did show with a animated value.
/// @discusstion Called when the popover view did show. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewDidShow:(BOOL)animated AXP_REQUIRES_SUPER;
/// View will hide with a animated value.
/// @discusstion Called when the popover view will hide. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewWillHide:(BOOL)animated AXP_REQUIRES_SUPER;
/// View is in hiding with a animated value.
/// @discusstion Called when the popover view is in hiding. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewHiding:(BOOL)animated AXP_REQUIRES_SUPER;
/// View did hide with a animated value.
/// @discusstion Called when the popover view did hide. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
- (void)viewDidHide:(BOOL)animated AXP_REQUIRES_SUPER;
/// Deprecated initize selector.
- (instancetype)initWithCoder __attribute__((unavailable("AXPopoverBubbleView cannot be created by coder")));
@end
@interface AXPopoverViewAnimator : NSObject
/// Showing animation block
@property(copy, nonatomic) AXPopoverViewAnimation showing;
/// Hiding animation block
@property(copy, nonatomic) AXPopoverViewAnimation hiding;
+ (instancetype)animatorWithShowing:(nullable AXPopoverViewAnimation)showing hiding:(nullable AXPopoverViewAnimation)hiding;
@end
NS_ASSUME_NONNULL_END