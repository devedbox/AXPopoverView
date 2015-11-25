//
//  ScrollViewController.m
//  AXPopoverView
//
//  Created by ai on 15/11/25.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "ScrollViewController.h"
#import "AXPopoverLabel.h"

@interface ScrollViewController ()
@property(weak, nonatomic) IBOutlet UIView *showsView;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) AXPopoverLabel *popoverLabel;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _scrollView.contentInset = UIEdgeInsetsMake(64, 20, 64, 20);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [AXPopoverLabel hideVisiblePopoverViewsAnimated:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPopoverView) object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(showPopoverView) withObject:nil afterDelay:1.0];
}

- (IBAction)registering:(UISwitch *)sender {
    if (sender.isOn) {
        [_popoverLabel registerScrollView:_scrollView];
    } else {
        [_popoverLabel unregisterScrollView];
    }
}

#pragma mark - Shows
- (void)showPopoverView {
    _popoverLabel = [AXPopoverLabel showFromView:_showsView animated:YES duration:CGFLOAT_MAX title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車" configuration:^(AXPopoverLabel *popoverLabel) {
        popoverLabel.preferredWidth = 200;
        popoverLabel.showsOnPopoverWindow = NO;
        popoverLabel.hideOnTouch = NO;
        [popoverLabel registerScrollView:_scrollView];
    }];
}
@end