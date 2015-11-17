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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _popoverView = [[AXPopoverView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    _popoverView.priority = AXPopoverPriorityHorizontal;
    _popoverView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
- (IBAction)topLeft:(UIButton *)sender {
    [_popoverView showInRect:sender.frame animated:YES completion:nil];
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
