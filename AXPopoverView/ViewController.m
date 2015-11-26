//
//  ViewController.m
//  AXComponents
//
//  Created by ai on 15/11/17.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "ViewController.h"
#import "AXPopoverView.h"
#import "AXPopoverLabel.h"

@interface ViewController ()
@property(strong, nonatomic) AXPopoverView *popoverView;
@property(strong, nonatomic) AXPopoverLabel *popoverLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _popoverView = [[AXPopoverView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    _popoverView.priority = AXPopoverPriorityHorizontal;
    _popoverLabel = [[AXPopoverLabel alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    _popoverLabel.priority = AXPopoverPriorityHorizontal;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)topLeft:(UIButton *)sender {
//    _popoverLabel.title = @"法国";
    /*
     @"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速"
     */
//    _popoverLabel.detail = @"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速";
//    [_popoverLabel showInRect:sender.frame animated:YES duration:2.0];
     [AXPopoverLabel showFromView:sender animated:YES duration:2.0 title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速" configuration:^(AXPopoverLabel *popoverLabel) {
         popoverLabel.showsOnPopoverWindow = NO;
         popoverLabel.preferredArrowDirection = AXPopoverArrowDirectionTop;
         popoverLabel.translucentStyle = AXPopoverTranslucentLight;
//         popoverLabel.showing = ^(AXPopoverView *popoverView, BOOL animated, CGRect targetRect) {
//             if (animated) {
//                 CGRect fromFrame = CGRectZero;
//                 fromFrame.origin = popoverView.animatedFromPoint;
//                 popoverView.transform = CGAffineTransformMakeScale(0, 0);
//                 popoverView.layer.anchorPoint = popoverView.arrowPosition;
//                 [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.6 options:7 animations:^{
//                     popoverView.transform = CGAffineTransformIdentity;
//                 } completion:^(BOOL finish) {
//                     // Call `viewDidShow:` when the animation finished.
//                     if (finish) [popoverView viewDidShow:animated];
//                 }];
//             }
//         };
     }];
//    label.titleFont = [UIFont systemFontOfSize:18];
//    label.detailFont = [UIFont systemFontOfSize:16];
//    [AXPopoverLabel showFromView:sender animated:YES duration:3.0 title:@"这是第二个" detail:@"测试窗口"];
}

- (IBAction)topRight:(UIButton *)sender {
    [_popoverView showInRect:sender.frame animated:YES completion:nil];
}

- (IBAction)bottomLeft:(UIButton *)sender {
    [_popoverView showInRect:sender.frame animated:NO completion:nil];
}

- (IBAction)bottomRight:(UIButton *)sender {
    [_popoverView showInRect:sender.frame animated:YES completion:nil];
}

@end
