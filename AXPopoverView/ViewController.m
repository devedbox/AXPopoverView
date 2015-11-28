//
//  ViewController.m
//  AXComponents
//
//  Created by ai on 15/11/17.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "ViewController.h"
#import "AXPopoverView.h"

@interface ViewController ()
@property(strong, nonatomic) AXPopoverView *popoverView;
@property(strong, nonatomic) AXPopoverView *popoverLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _popoverView = [AXPopoverView new];
    _popoverView.priority = AXPopoverPriorityHorizontal;
    _popoverLabel = [[AXPopoverView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    _popoverLabel.priority = AXPopoverPriorityHorizontal;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    headerView.backgroundColor = [UIColor redColor];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    footerView.backgroundColor = [UIColor greenColor];
    _popoverView.headerView = headerView;
    _popoverView.footerView = footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)topLeft:(UIButton *)sender {
     [AXPopoverView showLabelFromView:sender animated:YES duration:10.0 title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速" configuration:^(AXPopoverView *popoverView) {
         popoverView.showsOnPopoverWindow = NO;
         popoverView.translucent = YES;
         popoverView.preferredArrowDirection = AXPopoverArrowDirectionTop;
         popoverView.translucentStyle = AXPopoverTranslucentLight;
         popoverView.headerMode = AXPopoverIndeterminate;
         popoverView.titleTextColor = [UIColor blackColor];
         popoverView.detailTextColor = [UIColor blackColor];
         popoverView.indicatorColor = [UIColor blackColor];
         popoverView.items = @[@"你好"];
         popoverView.itemHandler = ^(UIButton *sender, NSUInteger index) {
             NSLog(@"button item index: %ld", index);
         };
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             popoverView.headerMode = AXPopoverDeterminate;
             popoverView.progress = 0.4;
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 popoverView.headerMode = AXPopoverDeterminateAnnularEnabled;
                 popoverView.progress = 0.6;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     popoverView.headerMode = AXPopoverDeterminateHorizontalBar;
                     popoverView.progress = 0.8;
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         popoverView.headerMode = AXPopoverCustomView;
                     });
                 });
             });
         });
         popoverView.progress = 0.3;
     }];
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
