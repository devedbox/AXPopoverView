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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)topLeft:(UIButton *)sender {
     [AXPopoverView showLabelFromView:sender animated:YES duration:2.0 title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車，警察和 isis上演生死時速" configuration:^(AXPopoverView *popoverView) {
         popoverView.showsOnPopoverWindow = NO;
         popoverView.translucent = NO;
         popoverView.preferredArrowDirection = AXPopoverArrowDirectionTop;
         popoverView.translucentStyle = AXPopoverTranslucentLight;
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
