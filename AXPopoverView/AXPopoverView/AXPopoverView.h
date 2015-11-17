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

typedef NS_ENUM(NSUInteger, AXPopoverArrowDirection) {
    AXPopoverArrowDirectionTop,
    AXPopoverArrowDirectionLeft,
    AXPopoverArrowDirectionBottom,
    AXPopoverArrowDirectionRight
};

@interface AXPopoverView : UIView
@property(assign, nonatomic) CGPoint offsets;
@property(copy, nonatomic)   NSString *priority;
@property(assign, nonatomic) CGFloat arrowAngle;
@property(assign, nonatomic) BOOL dimBackground;
@property(assign, nonatomic) CGFloat cornerRadius;
@property(assign, nonatomic) CGFloat arrowConstant;
@property(readonly, nonatomic) UIView *contentView;
@property(assign, nonatomic)   CGFloat arrowCornerRadius;
@property(readonly, nonatomic) UIEdgeInsets contentViewInsets;
@property(assign, nonatomic)   AXPopoverArrowDirection arrowDirection;

- (void)showInRect:(CGRect)rect animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(dispatch_block_t)completion;

- (void)showInRect:(CGRect)rect animated:(BOOL)animated duration:(NSTimeInterval)duration;
- (void)showFromView:(UIView *)view animated:(BOOL)animated completion:(dispatch_block_t)completion;

- (instancetype)initWithCoder __attribute__((unavailable("AXPopoverBubbleView cannot be created by coder")));
@end

@interface AXPopoverView(MessageTips)
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *detail;
@property(strong, nonatomic) UIFont *titleFont;
@property(strong, nonatomic) UIFont *detailFont;
@end