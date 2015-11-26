//
//  AppDelegate.m
//  AXPopoverView
//
//  Created by ai on 15/11/17.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AppDelegate.h"
#import "AXPopoverLabel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[AXPopoverLabel appearance] setBackgroundColor:[UIColor colorWithRed:0.165f green:0.639f blue:0.937f alpha:1.00f]];
    [[AXPopoverLabel appearance] setBackgroundDrawingColor:[UIColor colorWithRed:0.165f green:0.639f blue:0.937f alpha:1.00f]];
    [[AXPopoverLabel appearance] setPreferredArrowDirection:AXPopoverArrowDirectionTop];
    [[AXPopoverLabel appearance] setTitleTextColor:[UIColor whiteColor]];
    [[AXPopoverLabel appearance] setDetailTextColor:[UIColor whiteColor]];
    [[AXPopoverLabel appearance] setArrowConstant:6];
    [[AXPopoverLabel appearance] setTranslucentStyle:AXPopoverTranslucentDefault];
    [[AXPopoverLabel appearance] setAnimator:[AXPopoverViewAnimator animatorWithShowing:^(AXPopoverView * _Nonnull popoverView, BOOL animated, CGRect targetRect) {
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
