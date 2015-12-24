//
//  AXPopoverView+Animation.h
//  AXPopoverView
//
//  Created by ai on 15/12/24.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "AXPopoverView.h"

@interface AXPopoverView (Animation)
+ (AXPopoverViewAnimator *)turnFlipAnimator;
+ (AXPopoverViewAnimator *)flipSpringAnimator;
@end