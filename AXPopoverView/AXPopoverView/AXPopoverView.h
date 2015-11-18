//
//  AXPopoverBubbleView.h
//  AXPopoverView
//
//  Created by ai on 15/11/16.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const AXPopoverPriorityHorizontal;
UIKIT_EXTERN NSString *const AXPopoverPriorityVertical;

@class AXPopoverView;
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
    /// Arrow on the top.
    AXPopoverArrowDirectionTop,
    /// Arrow on the left.
    AXPopoverArrowDirectionLeft,
    /// Arrow on the bottom.
    AXPopoverArrowDirectionBottom,
    /// Arrow on the right.
    AXPopoverArrowDirectionRight
};
///
@interface AXPopoverView : UIView
/// Origin of frame when display the view.
@property(assign, nonatomic) CGPoint offsets;
/// Min size of popover view.
@property(readonly, nonatomic) CGSize minSize;
/// Arrow direction priority.
@property(copy, nonatomic)   NSString *priority;
/// Angle of arrrow. Defaults to 90.
@property(assign, nonatomic) CGFloat arrowAngle;
/// Dim the background or not. Defaults to not.
@property(assign, nonatomic) BOOL dimBackground;
/// Corner radius of popover view.
@property(assign, nonatomic) CGFloat cornerRadius;
/// Arrow length.
@property(assign, nonatomic) CGFloat arrowConstant;
/// Conent view.
@property(readonly, nonatomic) UIView *contentView;
/// Corner radius of arrow.
@property(assign, nonatomic)   CGFloat arrowCornerRadius;
/// Insets of content view.
@property(readonly, nonatomic) UIEdgeInsets contentViewInsets;
/// Delegate.
@property(assign, nonatomic) id<AXPopoverViewDelegate>delegate;
/// Direction of arrow.
@property(assign, nonatomic)   AXPopoverArrowDirection arrowDirection;
/// Should remove from super view when hidden or not.
@property(assign, nonatomic) BOOL removeFromSuperViewOnHide;

- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion;

- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion;

- (void)viewWillShow:(BOOL)animated;
- (void)viewShowing:(BOOL)animated;
- (void)viewDidShow:(BOOL)animated;
- (void)viewWillHide:(BOOL)animated;
- (void)viewHiding:(BOOL)animated;
- (void)viewDidHide:(BOOL)animated;

- (instancetype)initWithCoder __attribute__((unavailable("AXPopoverBubbleView cannot be created by coder")));
@end