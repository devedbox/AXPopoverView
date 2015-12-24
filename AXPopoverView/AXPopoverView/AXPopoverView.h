//
//  AXPopoverView.h
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

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#ifndef AXP_REQUIRES_SUPER
#define AXP_REQUIRES_SUPER __attribute((objc_requires_super))
#endif
/// Popover arrow direction priority in horizontal.
UIKIT_EXTERN NSString *const AXPopoverPriorityHorizontal;
/// Popover arrow direction priority in vertical.
UIKIT_EXTERN NSString *const AXPopoverPriorityVertical;
//
@class AXPopoverView, AXPopoverViewAnimator;
/// Configuration call back block to configure popover view when popover view will show.
///
/// @param popoverView a popover view will show.
/// @return Void
typedef void(^AXPopoverViewConfiguration)(AXPopoverView *popoverView);
/// Handler call back block when button item is being cliked.
///
/// @param sender a button item.
/// @param index index of button item.
///
/// @return Void
typedef void(^AXPopoverViewItemHandler)(UIButton *sender, NSUInteger index);
///
/// AXPopoverViewDelegate
///
@protocol AXPopoverViewDelegate <NSObject>
@optional
/// Called when popover view will show with animation.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
- (void)popoverViewWillShow:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view is in showing animation block.
///
/// @discusstion You can add custom animation block to the main animation block
///              by implement the method.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
- (void)popoverViewShowing:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view has shown.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
- (void)popoverViewDidShow:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view will hide.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
- (void)popoverViewWillHide:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view is in hiding animation block.
///
/// @discusstion You can add custom animation block to the main animation block
///              by implement the method.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
- (void)popoverViewHiding:(AXPopoverView *)popoverView animated:(BOOL)animated;
/// Called when popover view has hidden.
///
/// @param popoverView a popover view.
/// @param animated    shows animation.
///
/// @return Void
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
/// Enum of translucent style.
typedef NS_ENUM(NSUInteger, AXPopoverTranslucentStyle) {
    /// Default(Dark) translucent style.
    AXPopoverTranslucentDefault,
    /// Light translucent style.
    AXPopoverTranslucentLight
};
/// Mode of custom header view.
typedef NS_ENUM(NSUInteger, AXPopoverCustomViewMode) {
    /// Shows a custom view
    AXPopoverCustomView,
    /// Progress is shown using an UIActivityIndicatorView. This is the default.
    AXPopoverIndeterminate,
    /// Progress is shown using a round, pie-chart like, progress view.
    AXPopoverDeterminate,
    /// Progress is shown using a horizontal progress bar
    AXPopoverDeterminateHorizontalBar,
    /// Progress is shown using a ring-shaped progress view.
    AXPopoverDeterminateAnnularEnabled,
    /// Show a custom view with success style.
    AXPopoverSuccess,
    /// Show a custom view with error style.
    AXPopoverError
};
/// Style of additional buttons.
typedef NS_ENUM(NSUInteger, AXPopoverAdditionalButtonStyle) {
    /// Lay on the horizontal direction.
    AXPopoverAdditionalButtonHorizontal,
    /// Lay on the vertical direction.
    AXPopoverAdditionalButtonVertical
};
/// Popover view animation block.
/// @discusstion Using this block to customize showing/hiding animation of popover view.
///
/// @param popoverView the popover view to animate.
/// @param animated    a boolean value to decide show popover view with or without animation.
/// @param targetRect  the target rect in the window to show popover view.
///
/// @return Void
typedef void(^AXPopoverViewAnimation)(AXPopoverView *popoverView, BOOL animated, CGRect targetRect, NSDictionary *userInfo);
/// Popover view initial block.
/// @discusstion Using this block to customize popover view before showing.
///
/// @param popoverView the popover view to animate.
///
/// @return A customed user info using in showing block.
typedef NSDictionary *(^AXPopoverViewAnimationInitializing)(AXPopoverView *popoverView);
///
/// AXPopoverView.
///
@interface AXPopoverView : UIView
//
// ---------------------------------------------------------------------------------------
//  @name Base view properties.
// ---------------------------------------------------------------------------------------
//
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
/// Snapshots view.
@property(readonly, nonatomic) UIView *snapshotView;
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
@property(assign, nonatomic, getter=isRemoveFromSuperViewOnHide) BOOL removeFromSuperViewOnHide __deprecated_msg(" Default is always YES.");
/// Translucent the popover view. Do this will ignore the background of popover view. Defaults to `YES`.
@property(assign, nonatomic, getter=isTranslucent) BOOL translucent;
/// Translucent style.
@property(assign, nonatomic) AXPopoverTranslucentStyle translucentStyle UI_APPEARANCE_SELECTOR;
/// Shows on popover window. Defaults to NO.
/// @discusstion If `showsOnPopoverWindow` is `YES`, the popover view will show on a new window.
///              If `showsOnPopoverWindow` is `NO`, the popover view will show on the application
///              main window. Defaults to `YES`.
@property(assign, nonatomic, getter=isShowsOnPopoverWindow) BOOL showsOnPopoverWindow;
/// Lock background.
/// @discusstion If shows window is `popoverWindow`, the `lockBackground` is always `YES`.
///              `LockBackground` set to `YES/NO` will work only when shows window is `APP Window`.
///              Set to `YES` to forbid touch area outside the `popoverView`.
///              Set to `NO` to allow touch area outside the `popoverView`.
@property(assign, nonatomic, getter=isLockBackground) BOOL lockBackground;
/// Hide the popover view on touch when `lockBackground` is `YES`.
@property(assign, nonatomic, getter=isHideOnTouch) BOOL hideOnTouch;
/// Background drawing color
@property(strong, nonatomic) UIColor *backgroundDrawingColor UI_APPEARANCE_SELECTOR;
/// Animator of show/hide animation.
@property(strong, nonatomic) AXPopoverViewAnimator *animator UI_APPEARANCE_SELECTOR;
/// Popover window.
@property(readonly, nonatomic) UIWindow *popoverWindow;
/// Background view.
@property(readonly, nonatomic) UIView   *backgroundView;
/// Shows completion block.
@property(copy, nonatomic) dispatch_block_t showsCompletion;
/// Hides completion block.
@property(copy, nonatomic) dispatch_block_t hidesCompletion;
/// Prefered width of content subviews. Defaults:
/// (screenWidth - (contentViewInsets.left + contentViewInsets.right))
@property(assign, nonatomic) CGFloat preferredWidth UI_APPEARANCE_SELECTOR;
/// Subviews content insets. Defaults to {0, 0, 0, 0}
@property(assign, nonatomic) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;
/// Padding of content subviews. Defaults to 4.
@property(assign, nonatomic) CGFloat padding UI_APPEARANCE_SELECTOR;
//
// ---------------------------------------------------------------------------------------
//  @name Labels properties.
// ---------------------------------------------------------------------------------------
//
/// Title of popover label. 
@property(copy, nonatomic) NSString *title;
/// Detail of popover label.
@property(copy, nonatomic) NSString *detail;
/// Font of title label. Defaults to system 14 font size.
@property(strong, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
/// Title label text color. Defaults to black with 0.7 alpha.
@property(strong, nonatomic) UIColor *titleTextColor UI_APPEARANCE_SELECTOR;
/// Font of detail label. Defaults to system 12 font size.
@property(strong, nonatomic) UIFont *detailFont UI_APPEARANCE_SELECTOR;
/// Detail label text color. Defaults to black with 0.5 alpha.
@property(strong, nonatomic) UIColor *detailTextColor UI_APPEARANCE_SELECTOR;
/// Fade the content. Defaults to NO.
@property(assign, nonatomic) BOOL fadeContentEnabled __deprecated_msg(" Fade content is always disable.");
//
// ---------------------------------------------------------------------------------------
//  @name Additional buttons.
// ---------------------------------------------------------------------------------------
//
/// Items of buttons.
@property(copy, nonatomic) NSArray *items;
/// Button style. Defaults to `AXPopoverAdditionalButtonHorizontal`.
@property(assign, nonatomic) AXPopoverAdditionalButtonStyle itemStyle;
/// Prefered width for single item., Default is 240.
@property(assign, nonatomic) CGFloat preferedWidthForSingleItem;
/// Should use popover prefered width on single item. Defaults to YES;
@property(assign, nonatomic) BOOL shouldUsePopoverPreferedWidthOnSingleItem;
/// Height of button. Defaults to 30 pt.
@property(assign, nonatomic) CGFloat heightOfButtons UI_APPEARANCE_SELECTOR;
/// Minimum width of buttons. Defaults to 44 pt.
@property(assign, nonatomic) CGFloat minWidthOfButtons UI_APPEARANCE_SELECTOR;
/// Tint color of button item. Defaults to black color.
@property(strong, nonatomic) UIColor *itemTintColor UI_APPEARANCE_SELECTOR;
/// Font of button item. Defaults to system 12 font size.
@property(strong, nonatomic) UIFont *itemFont UI_APPEARANCE_SELECTOR;
/// CornerRadius of button item. Defaults to 3.f.
@property(assign, nonatomic) CGFloat itemCornerRadius UI_APPEARANCE_SELECTOR;
/// Handler block. Defauts to NULL.
@property(copy, nonatomic) AXPopoverViewItemHandler itemHandler;
//
// ---------------------------------------------------------------------------------------
//  @name Custom views.
// ---------------------------------------------------------------------------------------
//
/// Custom header view.
@property(strong, nonatomic) UIView *headerView;
/// Custom footer view.
@property(strong, nonatomic) UIView *footerView;
/// Custom header view mode.
@property(assign, nonatomic) AXPopoverCustomViewMode headerMode UI_APPEARANCE_SELECTOR;
/// Progress.
@property(assign, nonatomic) CGFloat progress;
/// Indicator color.
@property(strong, nonatomic) UIColor *indicatorColor UI_APPEARANCE_SELECTOR;
/// Set header view with animation.
///
/// @param headerView a new header view.
/// @oaram animated   a boolean value of animating.
- (void)setHeaderView:(UIView *)headerView animated:(BOOL)animated;
/// Set footer view with animation.
///
/// @param footerView a new footer view.
/// @oaram animated   a boolean value of animating.
- (void)setFooterView:(UIView *)footerView animated:(BOOL)animated;
/// Set header mode with animation.
///
/// @param headerMode a new header mode.
/// @oaram animated   a boolean value of animating.
- (void)setHeaderMode:(AXPopoverCustomViewMode)headerMode animated:(BOOL)animated;
#pragma mark - Methods
/// Show the popover view in a rect in the new popover window.
/// @discusstion the rect is a specific rect in the popover window which is normlly same as the application
///              key window.
///
/// @param rect       the rect in the popover winow.
/// @param animated   a boolean value to decide show popover view with or without animation.
/// @param completion a completion call back block when the shows animation finished.
///
/// @return Void
- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Hide the showing popover view with a delay time internal.
///
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param delay    a double value to descrip delay time time internal.
/// @param completion a completion call back block when the hides animation finished.
///
/// @return Void
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion;
/// Show the popover view in a rect in the new popover window with a constant time internal.
/// @discusstion Show the popover view with a time dutation, and from the popover view shows completely on,
///              the popover view will hide automaticly after the time duration.
///
/// @param rect     the rect in the popover window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
///
/// @return Void
- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration;
/// Show the popover view from a view in the application key and main window with a time duration.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
///
/// @return Void
- (void)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration;
/// Show the popover view from a view in the application key and main window with a completion call back block.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated   a boolean value to decide show popover view with or without animation.
/// @param completion a completion call back block when the shows animation finished.
///
/// @return Void
- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion;
/// Added a background task is executing in a new thread, popover view will hide when finished.
///
/// This method also takes care of autorelease pools so your method does not have to be concerned with setting up a
/// pool.
///
/// @param method The method to be executed while the HUD is shown. This method will be executed in a new thread.
/// @param target The object that the target method belongs to.
/// @param object An optional object to be passed to the method.
/// @param animated If set to YES the HUD will (dis)appear using the current animationType. If set to NO the HUD will not use
/// animations while (dis)appearing.
///
/// @return Void
- (void)addExecuting:(SEL)method onTarget:(id)target withObject:(id)object;
#if NS_BLOCKS_AVAILABLE
/// Added a block is executing on a background queue, popover view will hide when finished.
///
/// @see showAnimated:whileExecutingBlock:onQueue:completionBlock:
///
/// @return Void
- (void)addExecutingBlock:(dispatch_block_t)block;
/// Added a block is executing on a background queue, popover view will hide when finished.
///
/// @see showAnimated:whileExecutingBlock:onQueue:completionBlock:
///
/// @return Void
- (void)addExecutingBlock:(dispatch_block_t)block completionBlock:(dispatch_block_t)completion;
/// Added a block is executing on the specified dispatch queue, popover view will hide when finished.
///
/// @see showAnimated:whileExecutingBlock:onQueue:completionBlock:
///
/// @return Void
- (void)addExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue;
/// Added a block is executing on the specified dispatch queue, executes completion block on the main queue, popover view will hide when finished.
///
/// @param animated If set to YES the HUD will (dis)appear using the current animationType. If set to NO the HUD will
/// not use animations while (dis)appearing.
/// @param block The block to be executed while the HUD is shown.
/// @param queue The dispatch queue on which the block should be executed.
/// @param completion The block to be executed on completion.
///
/// @see completionBlock
///
/// @return Void
- (void)addExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue completionBlock:(dispatch_block_t)completion;
#endif
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
///
/// @return Void
- (void)viewWillShow:(BOOL)animated AXP_REQUIRES_SUPER;
/// View is in showing with a animated value.
/// @discusstion Called when the popover view is in showing. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
- (void)viewShowing:(BOOL)animated AXP_REQUIRES_SUPER;
/// View did show with a animated value.
/// @discusstion Called when the popover view did show. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
- (void)viewDidShow:(BOOL)animated AXP_REQUIRES_SUPER;
/// View will hide with a animated value.
/// @discusstion Called when the popover view will hide. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
- (void)viewWillHide:(BOOL)animated AXP_REQUIRES_SUPER;
/// View is in hiding with a animated value.
/// @discusstion Called when the popover view is in hiding. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
- (void)viewHiding:(BOOL)animated AXP_REQUIRES_SUPER;
/// View did hide with a animated value.
/// @discusstion Called when the popover view did hide. The `animated` value descrip the style of popover view's
///              showing with animation. If animated is `YES`, popover shows with animation. Otherwise, popover view
///              shows without animation.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
- (void)viewDidHide:(BOOL)animated AXP_REQUIRES_SUPER;
/// Hide all visible popover views is the window(both `popoverWindow` and `APP window`).
/// @discusstion Call this methods to hide all the popover views which is not referenced.
///
/// @param animated a boolean value of popover view showing with or without animation.
///
/// @return Void
+ (void)hideVisiblePopoverViewsAnimated:(BOOL)animated;
/// Register a scroll veiw and follow the scrolling.
///
/// @param scrollView a scroll view to be registered.
///
/// @return Void
- (void)registerScrollView:(UIScrollView *)scrollView;
/// Unregister the following.
- (void)unregisterScrollView;
#pragma mark - Deprecated
/// Deprecated initize selector.
- (instancetype)initWithCoder __attribute__((unavailable("`AXPopoverView` cannot be created by coder")));
@end
@interface AXPopoverView (Label)
//
// ---------------------------------------------------------------------------------------
//  @name Labels show methods.
// ---------------------------------------------------------------------------------------
//
/// Show the popover label from a view in the application key and main window with a constant time internal.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
/// @param title title of title label.
/// @param content of detail label.
///
/// @return Void
+ (instancetype)showLabelFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail;
/// Show the popover label from a view in the application key and main window with a constant time internal and a configuration block.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param view a view in the application window.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
/// @param title title of title label.
/// @param content of detail label.
///
/// @return Void
+ (instancetype)showLabelFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverViewConfiguration)config;
/// Show the popover label from a rect in the application key and main window with a constant time internal.
/// @discusstion This method is suggested cause the frame of `view` will be convered to the popover window
///              automaticly.
///
/// @param rect     the rect in the popover winow.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
/// @param title title of title label.
/// @param content of detail label.
///
/// @return Void
+ (instancetype)showLabelInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail;
/// Show the popover label from a rect in the application key and main window with a constant time internal and a configuration block.
///
/// @param rect     the rect in the popover winow.
/// @param animated a boolean value to decide show popover view with or without animation.
/// @param duration a time internal duration the popover shows constants.
/// @param title title of title label.
/// @param content of detail label.
///
/// @return Void
+ (instancetype)showLabelInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration title:(NSString *)title detail:(NSString *)detail configuration:(AXPopoverViewConfiguration)config;
@end
@interface AXPopoverViewAnimator : NSObject
/// Initial state block.
@property(copy, nonatomic) AXPopoverViewAnimationInitializing initializing;
/// Showing animation block
@property(copy, nonatomic) AXPopoverViewAnimation showing;
/// Hiding animation block
@property(copy, nonatomic) AXPopoverViewAnimation hiding;
/// Get a custom animator of popover view to show/hide popover view by a custom animation way.
///
/// @param initializing a initial block to configure the popover view at beginning.
/// @param showing a showing animation block.
/// @param hiding  a hiding animation block.
///
/// @return An animator contains showing and hiding animation block.
+ (instancetype)animatorWithInitializing:(AXPopoverViewAnimationInitializing)initializing showing:(AXPopoverViewAnimation)showing hiding:(AXPopoverViewAnimation)hiding;
/// Get a custom animator of popover view to show/hide popover view by a custom animation way with showing and hiding blocks.
+ (instancetype)animatorWithShowing:(AXPopoverViewAnimation)showing hiding:(AXPopoverViewAnimation)hiding;
@end
@interface UIWindow(AXPopover)
/// Reference count.
@property(readonly, nonatomic) NSUInteger referenceCount;
/// Tap gesture.
@property(readonly, nonatomic) UITapGestureRecognizer *tap;
/// Pan gesture.
@property(readonly, nonatomic) UIPanGestureRecognizer *pan;
/// Registered popover views.
@property(readonly, nonatomic) NSMutableArray *registeredPopoverViews;
/// Application main key window.
@property(assign, nonatomic) UIWindow *appKeyWindow;
/// Register a popover view and added to the popover window.
///
/// @param popoverView a popover view to be registered.
///
/// @return Void
- (void)registerPopoverView:(AXPopoverView *)popoverView;
/// Unregister the popover view in the popover window.
///
/// @param popoverView a popover view to be unregistered.
///
/// @return Void
- (void)unregisterPopoverView:(AXPopoverView *)popoverView;
@end
///
/// AXPopoverBarProgressView
///
@interface AXPopoverBarProgressView : UIView
/// Progress value
@property(assign, nonatomic) CGFloat progress;
/// Line color
@property(strong, nonatomic) UIColor *lineColor;
/// Progress color
@property(strong, nonatomic) UIColor *progressColor;
/// Track color
@property(strong, nonatomic) UIColor *trackColor;
@end
///
/// AXPopoverCircleProgressView
///
@interface AXPopoverCircleProgressView : UIView
/// Progress value
@property(assign, nonatomic) CGFloat progress;
/// Progress color
@property(strong, nonatomic) UIColor *progressColor;
/// Progress background color
@property(strong, nonatomic) UIColor *progressBgnColor;
/// Annular enabled
@property(assign, nonatomic) BOOL annularEnabled;
@end