

# AXPopoverView[![Build Status](https://travis-ci.org/devedbox/AXPopoverView.svg?branch=master)](https://travis-ci.org/devedbox/AXPopoverView)

##Summary
`AXPopoverView` is an iOS customizable view that displays a bubble style view with a custom view when some messages need to show from a target view or a target rect. `AXPopoverLabel` is an enample how to use custom view to customize the popover view. The popover view (mostly used as `AXPopoverLabel`) is a convenient and hommization way for developer to use.

[![](http://7xop5v.com1.z0.glb.clouddn.com/popover.gif)](http://7xop5v.com1.z0.glb.clouddn.com/popover.gif)
[![](http://7xop5v.com1.z0.glb.clouddn.com/movement.gif)](http://7xop5v.com1.z0.glb.clouddn.com/movement.gif)
[![](http://7xop5v.com1.z0.glb.clouddn.com/movement_2.gif)](http://7xop5v.com1.z0.glb.clouddn.com/movement_2.gif)

## Requirements

`AXPopoverView` works on any iOS version. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework

You will need the latest developer tools in order to build AXPopoverView. Old Xcode versions might work, but compatibility will not be explicitly maintained.

## Adding AXPopoverView to your project

### Cocoapods

[CocoaPods](http://cocoapods.org) is the recommended way to add AXPopoverView to your project.

1. Add a pod entry for AXPopoverView to your Podfile `pod 'AXPopoverView', '~> 0.1.4'`
2. Install the pod(s) by running `pod install`.
3. Include MBProgressHUD wherever you need it with `#import "AXPopoverView.h"` or `#import AXPopoverLabel.h`.

### Source files

Alternatively you can directly add the `AXPopoverView.h`/`AXPopoverLabel.h` and `AXPopoverView.m`/`AXPopoverLabel.m` source files to your project.

1. Download the [latest code version](https://github.com/devedbox/AXPopoverView/archive/master.zip) or add the repository as a git submodule to your git-tracked project. 
2. Open your project in Xcode, then drag and drop `AXPopoverView.h`/`AXPopoverLabel.h` and `AXPopoverView.m`/`AXPopoverLabel.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 
3. Include AXPopoverView/AXPopoverLabel wherever you need it with `#import "AXPopoverView.h"` or `#import AXPopoverLabel.h`.

## Usage

`AXPopoverView` support `UI_APPEARANCE_SELECTOR` to configure look of popover view will display on the screen. You should add your customizable code to `configuration block` when you using the `+ instance methods`.

###Showing&hiding

Using `showInRect:animated:completion:` `hideAnimated:afterDelay:completion:` to show popover view or hide. You can also using convenient methods to show the popover label like this:
```objective-c
[AXPopoverLabel showFromView:sender animated:YES duration:2.0 title:@"Your title." detail:@"Your detail contents." configuration:nil];
```
Oh, that's easy!!!

###appearance configuration

Using the selector masked as `UI_APPEARANCE_SELECTOR` to custimize the popover view when application has started.
```objcetive-c
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
```

###block configuration

Simply using a block to customize a specific popover view will show.
```objcetive-c
[AXPopoverLabel showFromView:sender animated:YES duration:2.0 title:@"Your title." detail:@"Your detail contents." configuration:^(AXPopoverLabel *popoverLabel) {
popoverLabel.showsOnPopoverWindow = NO;
popoverLabel.translucent = NO;
popoverLabel.preferredArrowDirection = AXPopoverArrowDirectionTop;
popoverLabel.translucentStyle = AXPopoverTranslucentLight;
}];
```
You can also use as this:

```objective-c
AXPopoverLabel *popoverLabel = [AXPopoverLabel new];
popoverLabel.title = @"Your title.";
popoverLabel.detail = @"Your detail contents.";
popoverLabel.showsOnPopoverWindow = NO;
popoverLabel.translucent = NO;
popoverLabel.preferredArrowDirection = AXPopoverArrowDirectionTop;
popoverLabel.translucentStyle = AXPopoverTranslucentLight;
[popoverLabel showFromView:sender animated:YES duration:2.0];
```
###UI Updates

UI updates should always be done on the main thread. like `setOffsets:`, `setArrowAngle:`, `setTitleFont:`, `setDetailFont:`, `setTranslucent:`, `setArrowCornerRadius:` and so on.

If you need to run your long-running task in the main thread, you should perform it with a slight delay, so UIKit will have enough time to update the UI (i.e., draw the HUD) before you block the main thread with your task.

```objective-c
if ([NSThread isMainThread]) {
/// Do updaing.
} else {
dispatch_async(dispatch_get_main_queue(), ^{
/// Do updating.
});
}
```


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

## Change-log

Updating... 



