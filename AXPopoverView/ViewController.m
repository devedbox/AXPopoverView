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
@property(strong, nonatomic) AXPopoverView *popover;
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
    _popoverView.showsOnPopoverWindow = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)topLeft:(UIButton *)sender {
     _popover = [AXPopoverView showLabelFromView:sender animated:YES duration:17.0 title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速" configuration:^(AXPopoverView *popoverView) {
         popoverView.showsOnPopoverWindow = NO;
         popoverView.translucent = YES;
         popoverView.lockBackground = YES;
         popoverView.dimBackground = YES;
         popoverView.preferredArrowDirection = AXPopoverArrowDirectionTop;
         popoverView.translucentStyle = AXPopoverTranslucentLight;
         popoverView.headerMode = AXPopoverIndeterminate;
         popoverView.titleTextColor = [UIColor blackColor];
         popoverView.detailTextColor = [UIColor blackColor];
         popoverView.indicatorColor = [UIColor blackColor];
         popoverView.itemTintColor = [UIColor blackColor];
         popoverView.items = @[@"你好", @"你好啊"];
         popoverView.itemHandler = ^(UIButton *sender, NSUInteger index) {
             [AXPopoverView showLabelInRect:CGRectMake(self.view.bounds.size.width*.5-5, 10, 10, 10) animated:YES duration:2.5 title:@"消息" detail:@"你好，这是点击｀你好｀之后的消息" configuration:^(AXPopoverView *popoverView2) {
                 popoverView2.showsOnPopoverWindow = NO;
                 popoverView2.translucent = YES;
                 popoverView2.preferredArrowDirection = AXPopoverArrowDirectionTop;
                 popoverView2.translucentStyle = AXPopoverTranslucentLight;
                 popoverView2.titleTextColor = [UIColor blackColor];
                 popoverView2.detailTextColor = [UIColor blackColor];
                 popoverView2.indicatorColor = [UIColor blackColor];
             }];
         };
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [popoverView setHeaderMode:AXPopoverDeterminateAnnularEnabled animated:YES];
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [popoverView setHeaderMode:AXPopoverDeterminate animated:YES];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [popoverView setHeaderMode:AXPopoverDeterminateHorizontalBar animated:YES];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [popoverView setHeaderMode:AXPopoverSuccess animated:YES];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [popoverView setHeaderMode:AXPopoverError animated:YES];
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [popoverView setHeaderMode:AXPopoverCustomView animated:YES];
                             });
                         });
                     });
                 });
             });
         });
         [popoverView addExecuting:@selector(myTask) onTarget:self withObject:nil];
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

- (void)myTask {
    float progress = 0.0f;
    while (progress < 1.0f)
    {
        progress += 0.005f;
        _popover.progress = progress;
        usleep(50000);
    }
}
@end