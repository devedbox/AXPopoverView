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

- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(nullable dispatch_block_t)completion;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(nullable dispatch_block_t)completion;

- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)showFromView:(UIView *)view animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(nullable dispatch_block_t)completion;

- (void)viewWillShow:(BOOL)animated;
- (void)viewShowing:(BOOL)animated;
- (void)viewDidShow:(BOOL)animated;
- (void)viewWillHide:(BOOL)animated;
- (void)viewHiding:(BOOL)animated;
- (void)viewDidHide:(BOOL)animated;

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