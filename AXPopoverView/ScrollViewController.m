//
//  ScrollViewController.m
//  AXPopoverView
//
//  Created by ai on 15/11/25.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "ScrollViewController.h"
#import "AXPopoverView.h"

@interface ScrollViewController ()
@property(weak, nonatomic) IBOutlet UIView *showsView;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) AXPopoverView *popoverView;
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
    [AXPopoverView hideVisiblePopoverViewsAnimated:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showPopoverView) object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(showPopoverView) withObject:nil afterDelay:1.0];
}

- (IBAction)registering:(UISwitch *)sender {
    if (sender.isOn) {
        [_popoverView registerScrollView:_scrollView];
    } else {
        [_popoverView unregisterScrollView];
    }
}

#pragma mark - Shows
- (void)showPopoverView {
    _popoverView = [AXPopoverView showLabelFromView:_showsView animated:YES duration:CGFLOAT_MAX title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車" configuration:^(AXPopoverView *popoverView) {
        popoverView.preferredWidth = 200;
        popoverView.showsOnPopoverWindow = NO;
        popoverView.hideOnTouch = NO;
        [popoverView registerScrollView:_scrollView];
    }];
}
@end