//
//  AppDelegate.m
//  AXPopoverView
//
//  Created by ai on 15/11/17.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AppDelegate.h"
#import "AXPopoverView.h"
#import <AGGeometryKit/AGGeometryKit.h>
#import <AGGeometryKit+POP/POPAnimatableProperty+AGGeometryKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[AXPopoverView appearance] setBackgroundColor:[UIColor colorWithRed:0.165f green:0.639f blue:0.937f alpha:1.00f]];
    [[AXPopoverView appearance] setBackgroundDrawingColor:[UIColor colorWithRed:0.165f green:0.639f blue:0.937f alpha:1.00f]];
    [[AXPopoverView appearance] setPreferredArrowDirection:AXPopoverArrowDirectionTop];
    [[AXPopoverView appearance] setTitleTextColor:[UIColor whiteColor]];
    [[AXPopoverView appearance] setDetailTextColor:[UIColor whiteColor]];
    [[AXPopoverView appearance] setArrowConstant:6];
    [[AXPopoverView appearance] setTranslucentStyle:AXPopoverTranslucentDefault];
    [[AXPopoverView appearance] setItemTintColor:[[UIColor blackColor] colorWithAlphaComponent:0.8]];
    [[AXPopoverView appearance] setAnimator:[AXPopoverViewAnimator animatorWithShowing:^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect) {
        if (animated) {
            CGRect fromFrame = CGRectZero;
            fromFrame.origin = popoverView.animatedFromPoint;
            popoverView.transform = CGAffineTransformMakeScale(0, 0);
            popoverView.layer.anchorPoint = popoverView.arrowPosition;
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:7 animations:^{
                popoverView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finish) {
                // Call `viewDidShow:` when the animation finished.
                if (finish) [popoverView viewDidShow:animated];
            }];
        }
    } hiding:nil]];
    /*
    [[AXPopoverView appearance] setAnimator:[AXPopoverViewAnimator animatorWithShowing:^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect) {
        if (animated) {
            CGPoint anchorPoint = popoverView.layer.anchorPoint;
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
//            CATransform3D transform = CATransform3DMakeRotation(-M_PI_4, 1, 0, 0);
//            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:7 animations:^{
////                popoverView.transform = CGAffineTransformIdentity;
//                popoverView.layer.transform = transform;
//            } completion:^(BOOL finish) {
//                // Call `viewDidShow:` when the animation finished.
//                if (finish) [popoverView viewDidShow:animated];
//            }];
//            CGPoint pointOfTouchInside = [recognizer locationInView:view];
            [popoverView.layer ensureAnchorPointIsSetToZero];
            POPSpringAnimation *anim1 = [popoverView.layer pop_animationForKey:propertyName1];
            
            if(anim1 == nil)
            {
                anim1 = [POPSpringAnimation animation];
                anim1.property = [POPAnimatableProperty AGKPropertyWithName:propertyName1];
                [popoverView.layer pop_addAnimation:anim1 forKey:propertyName1];
            }
            
            anim1.velocity = [NSValue valueWithCGPoint:[recognizer velocityInView:self.view]];
            anim1.toValue = [NSValue valueWithCGPoint:controlPointView.center];
            anim1.springBounciness = 1;
            anim1.springSpeed = 7;
            anim1.dynamicsFriction = 7;
        }
    } hiding:nil]];
     */
    [[AXPopoverView appearance] setPreferredArrowDirection:AXPopoverArrowDirectionTop];
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    [_window makeKeyAndVisible];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_window.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageNamed:@"test.jpg"];
    [_window addSubview:imageView];
    [_window insertSubview:imageView atIndex:0];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
