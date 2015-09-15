//
//  HistoryViewController.m
//  Numbers
//
//  Created by Vadim Shevchik on 14.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "HistoryViewController.h"
#import "DetailViewController.h"
#import "HistoryTableCell.h"

#import "HistoryItem.h"

#import "HistoryManager.h"

static NSString *const HistoryCellID = @"HistoryCellID";

@interface HistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *history;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self clearHistoryButton];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"История";
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.history = [[[HistoryManager sharedInstance].history reverseObjectEnumerator] allObjects];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)clearHistoryButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Очистить" style:UIBarButtonItemStylePlain target:self action:@selector(clearAction:)];
    
    return rightItem;
}

- (void)clearAction:(UIButton *)button {
    [[HistoryManager sharedInstance] clearHistory];
    self.history = nil;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:HistoryCellID forIndexPath:indexPath];
    
    HistoryItem *item = self.history[indexPath.row];
    
    cell.limit = [NSString stringWithFormat:@"Предел: %li", (long)item.limit];
    cell.date = [@"Дата: " stringByAppendingString:item.date];
    cell.result = [NSString stringWithFormat:@"Количество результатов: %li",(long)[item.result count]];
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self detailControllerWithItem:self.history[indexPath.row]];
}

- (void)detailControllerWithItem:(HistoryItem *)item {
    if (!item) {
        return;
    }
    
    DetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Detail"];
    detailViewController.item = item;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
