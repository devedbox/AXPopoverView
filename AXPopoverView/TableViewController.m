//
//  TableViewController.m
//  AXPopoverView
//
//  Created by ai on 15/11/25.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import "TableViewController.h"
#import "AXPopoverKit.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [AXPopoverView showLabelFromView:cell.detailTextLabel inView:self.tableView animated:YES duration:2.5 title:@"法国" detail:@"法国警方抓获巴黎血案isis恐怖袭击嫌犯的场面，十分惊险的！上面2架直升机，下面二三十部車" configuration:^(AXPopoverView *popoverView) {
        popoverView.preferredWidth = 200;
//        [popoverView registerScrollView:tableView];
        popoverView.hideOnTouch = NO;
        popoverView.translucent = YES;
        switch (indexPath.row) {
            case 0:// 上边显示
                popoverView.preferredArrowDirection = AXPopoverArrowDirectionBottom;
                break;
            case 1:// 下边显示
                popoverView.preferredArrowDirection = AXPopoverArrowDirectionTop;
                break;
            case 2:// 左边显示
                popoverView.preferredArrowDirection = AXPopoverArrowDirectionRight;
                break;
            case 3:// 右边显示
                popoverView.preferredArrowDirection = AXPopoverArrowDirectionLeft;
                break;
            default:// 任意方向显示
                popoverView.preferredArrowDirection = AXPopoverArrowDirectionAny;
                break;
        }
    }];
}
@end
