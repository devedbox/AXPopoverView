//
//  AXPopoverView+Animation.m
//  AXPopoverView
//
//  Created by ai on 15/12/24.
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

#import "AXPopoverView+Animation.h"
#import <AGGeometryKit/AGGeometryKit.h>
#import "POPAnimatableProperty+AGGeometryKit.h"

@implementation AXPopoverView (Animation)
+ (AXPopoverViewAnimator *)turnFlipAnimator {
    return
    [AXPopoverViewAnimator animatorWithInitializing:^NSDictionary *(AXPopoverView *popoverView) {
        UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
        [popoverView.popoverWindow.appKeyWindow drawViewHierarchyInRect:[UIScreen mainScreen].bounds afterScreenUpdates:YES];
        [popoverView.layer ensureAnchorPointIsSetToZero];
        CGFloat constant = CGRectGetHeight(popoverView.frame)/3;
        CGPoint toPoint1=CGPointZero;
        CGPoint toPoint2=CGPointZero;
        AGKQuad quad = popoverView.layer.quadrilateral;
        AGKQuad originalQuad = quad;
        switch (popoverView.arrowDirection) {
            case AXPopoverArrowDirectionBottom:
                quad.tl = popoverView.frame.origin;
                toPoint1 = quad.tl;
                quad.tl.x += constant;
                quad.tl.y += constant;
                quad.tr = CGPointMake(CGRectGetMaxX(popoverView.frame), popoverView.frame.origin.y);
                toPoint2 = quad.tr;
                quad.tr.x -= constant;
                quad.tr.y += constant;
                break;
            case AXPopoverArrowDirectionLeft:
                quad.br = CGPointMake(CGRectGetMaxX(popoverView.frame), CGRectGetMaxY(popoverView.frame));
                toPoint1 = quad.br;
                quad.br.x -= constant;
                quad.br.y -= constant;
                quad.tr = CGPointMake(CGRectGetMaxX(popoverView.frame), popoverView.frame.origin.y);
                toPoint2 = quad.tr;
                quad.tr.x -= constant;
                quad.tr.y += constant;
                break;
            case AXPopoverArrowDirectionRight:
                quad.tl = popoverView.frame.origin;
                toPoint1 = quad.tl;
                quad.tl.x += constant;
                quad.tl.y += constant;
                quad.bl = CGPointMake(popoverView.frame.origin.x, CGRectGetMaxY(popoverView.frame));
                toPoint2 = quad.bl;
                quad.bl.x += constant;
                quad.bl.y -= constant;
                break;
            case AXPopoverArrowDirectionTop:
                quad.bl = CGPointMake(popoverView.frame.origin.x, CGRectGetMaxY(popoverView.frame));;
                toPoint1 = quad.bl;
                quad.bl.x += constant;
                quad.bl.y -= constant;
                quad.br = CGPointMake(CGRectGetMaxX(popoverView.frame), CGRectGetMaxY(popoverView.frame));
                toPoint2 = quad.br;
                quad.br.x -= constant;
                quad.br.y -= constant;
                break;
            default:
                break;
        }
        popoverView.layer.quadrilateral = quad;
        UIGraphicsEndImageContext();
        return @{@"constant":@(constant), @"toPoint1":[NSValue valueWithCGPoint:toPoint1], @"toPoint2":[NSValue valueWithCGPoint:toPoint2], @"quad":[NSValue valueWithAGKQuad:originalQuad]};
    } showing:^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect, NSDictionary *userInfo) {
        if (animated) {
            NSValue *toValue1 = [userInfo objectForKey:@"toPoint1"];
            NSValue *toValue2 = [userInfo objectForKey:@"toPoint2"];
            NSString *propertyName1=@"";
            NSString *propertyName2=@"";
            switch (popoverView.arrowDirection) {
                case AXPopoverArrowDirectionBottom:
                    propertyName1 = kPOPLayerAGKQuadTopLeft;
                    propertyName2 = kPOPLayerAGKQuadTopRight;
                    break;
                case AXPopoverArrowDirectionLeft:
                    propertyName1 = kPOPLayerAGKQuadBottomRight;
                    propertyName2 = kPOPLayerAGKQuadTopRight;
                    break;
                case AXPopoverArrowDirectionRight:
                    propertyName1 = kPOPLayerAGKQuadTopLeft;
                    propertyName2 = kPOPLayerAGKQuadBottomLeft;
                    break;
                case AXPopoverArrowDirectionTop:
                    propertyName1 = kPOPLayerAGKQuadBottomLeft;
                    propertyName2 = kPOPLayerAGKQuadBottomRight;
                    break;
                default:
                    break;
            }
            __block BOOL isAnim_1Finished = NO;
            __block BOOL isAnim_2Finished = NO;
            dispatch_block_t completion=^(){
                if (isAnim_1Finished && isAnim_2Finished) {
                    [popoverView viewDidShow:animated];
                }
            };
            POPSpringAnimation *anim1 = [popoverView.layer pop_animationForKey:propertyName1];
            POPSpringAnimation *anim2 = [popoverView.layer pop_animationForKey:propertyName2];
            if(anim1 == nil)
            {
                anim1 = [POPSpringAnimation animation];
                anim1.property = [POPAnimatableProperty AGKPropertyWithName:propertyName1];
                [popoverView.layer pop_addAnimation:anim1 forKey:propertyName1];
                anim1.completionBlock=^(POPAnimation *ani, BOOL finished){
                    if (finished) {
                        isAnim_1Finished = YES;
                        completion();
                    }
                };
            }
            if (anim2 == nil) {
                anim2 = [POPSpringAnimation animation];
                anim2.property = [POPAnimatableProperty AGKPropertyWithName:propertyName2];
                [popoverView.layer pop_addAnimation:anim2 forKey:propertyName2];
                anim2.completionBlock=^(POPAnimation *ani, BOOL finished){
                    if (finished) {
                        isAnim_2Finished = YES;
                        completion();
                    }
                };
            }
            
            anim1.springBounciness = 12;
            anim1.springSpeed = 20;
            anim2.springBounciness = 12;
            anim2.springSpeed = 20;
            anim1.toValue = toValue1;
            anim2.toValue = toValue2;
        } else {
            AGKQuad quad = [userInfo[@"quad"] AGKQuadValue];
            popoverView.layer.quadrilateral = quad;
            [popoverView viewShowing:animated];
            [popoverView viewDidShow:animated];
        }
    } hiding:NULL];
}

+ (AXPopoverViewAnimator *)flipSpringAnimator {
    return
    [AXPopoverViewAnimator animatorWithShowing:^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect, NSDictionary *userInfo) {
        if (animated) {
//            CGRect fromFrame = CGRectZero;
//            fromFrame.origin = popoverView.animatedFromPoint;
            popoverView.transform = CGAffineTransformMakeScale(0, 0);
            popoverView.layer.anchorPoint = popoverView.arrowPosition;
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:7 animations:^{
                popoverView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                // Call `viewDidShow:` when the animation finished.
                if (finished) [popoverView viewDidShow:animated];
            }];
        } else {
            [popoverView viewHiding:animated];
            [popoverView viewDidShow:animated];
        }
    } hiding:NULL];
}
/// TODO: Finish pop animator.
+ (AXPopoverViewAnimator *)popFlipSpringAnimator {
    return
    [AXPopoverViewAnimator animatorWithInitializing:^NSDictionary *(AXPopoverView *popoverView) {
        popoverView.layer.anchorPoint = popoverView.arrowPosition;
        return @{};
    } showing:^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect, NSDictionary *userInfo) {
        if (animated) {
            POPSpringAnimation *ani = [popoverView.layer pop_animationForKey:@"_frame"];
            if (!ani) {
                ani = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
            }
            ani.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
            ani.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
            ani.completionBlock = ^(POPAnimation *ani, BOOL finished){
                // Call `viewDidShow:` when the animation finished.
                if (finished) [popoverView viewDidShow:animated];
            };
            ani.springBounciness = 8;
            ani.springSpeed = 10;
            [popoverView.layer pop_removeAllAnimations];
            [popoverView.layer pop_addAnimation:ani forKey:@"_frame"];
        } else {
            [popoverView viewHiding:animated];
            [popoverView viewDidShow:animated];
        }
    } hiding:NULL];
}
@end