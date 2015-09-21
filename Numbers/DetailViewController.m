//
//  DetailViewController.m
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "DetailViewController.h"
#import "HistoryItem.h"
#import "HistoryManager.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self deleteButton];
    [self parseItem];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)deleteButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Удалить" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    
    return rightItem;
}

- (void)deleteAction:(UIButton *)button {
    [[HistoryManager sharedInstance] removeItem:self.item];
    self.navigationItem.title = @"";
    self.textView.text = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)parseItem {
    if (self.item) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        self.navigationItem.titleView = indicator;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *text = [NSString stringWithFormat:@"Предел: %li\n\nДата: %@\n\nПростые числа:\n\n%@", (long)self.item.limit, self.item.date, [self.item.result componentsJoinedByString:@", "]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textView.text = text;
                [indicator stopAnimating];
                self.navigationItem.titleView = nil;
                self.navigationItem.title = [NSString stringWithFormat:@"%li", (long)self.item.limit];
            });
        });
    }
}

@end
