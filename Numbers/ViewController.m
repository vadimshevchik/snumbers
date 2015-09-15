//
//  ViewController.m
//  Numbers
//
//  Created by Vadim Shevchik on 14.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "ViewController.h"
#import "HistoryViewController.h"
#import "DetailViewController.h"

#import "HistoryItem.h"
#import "HistoryManager.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

- (IBAction)generateAction:(UIButton *)button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textField.inputAccessoryView = [self createDoneButton];
    [self createActivityIndicator];
    self.navigationItem.rightBarButtonItem = [self createHistoryButton];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createActivityIndicator {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicatorView.frame = CGRectMake(0.0f, 0.0f, 32.0f, 32.0f);
    self.indicatorView.color = [UIColor darkGrayColor];
    self.indicatorView.hidesWhenStopped = YES;
    self.navigationItem.titleView = self.indicatorView;
}

- (UIToolbar *)createDoneButton {
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];

    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Скрыть" style:UIBarButtonItemStylePlain target:self action:@selector(doneEnterLimitAction:)];
    toolbar.items = [NSArray arrayWithObjects:flex, doneButton, nil];
    
    return toolbar;
}

- (UIBarButtonItem *)createHistoryButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"История" style:UIBarButtonItemStylePlain target:self action:@selector(historyAction:)];
    
    return rightItem;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
//        CGRect tableViewRect = self.tableView.frame;
//        tableViewRect.size.height = self.view.frame.size.height - keyboardSize.height;
//        self.tableView.frame = tableViewRect;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    double duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
//        CGRect viewRect = self.view.frame;
////        viewRect.size.height += ;
//        self.view.frame = tableViewRect;
    }];
}

- (void)doneEnterLimitAction:(UIButton *)button {
    [self.textField resignFirstResponder];
    [self generateAction:nil];
}

- (void)historyAction:(UIButton *)button {
    
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
    
    HistoryViewController *historyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"History"];
    [self.navigationController pushViewController:historyViewController animated:YES];
}

- (IBAction)generateAction:(UIButton *)button {
    NSInteger limit = [self.textField.text integerValue];
    [self generateNumbersForLimit:limit];
}

- (void)generateNumbersForLimit:(NSInteger)limit {
    if (limit > 1) {
        self.textView.text = @"";
        [self.textField resignFirstResponder];
        [self.indicatorView startAnimating];
        self.generateButton.enabled = NO;

        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * result = [[NSMutableArray alloc] init];
            BOOL needGenerated = YES;
            BOOL more = NO;
            NSInteger counter = 1;
            
            NSInteger blockLimit = limit;
            
            HistoryItem *item = [[HistoryManager sharedInstance] cacheDataForLimit:limit];
            if (item) {
                if (limit == item.limit) {
                    [result addObjectsFromArray:item.result];
                    needGenerated = NO;
                }
                else {
                    if (limit > item.limit) {
                        counter = limit - (limit - item.limit);
                        [result addObjectsFromArray:item.result];
                    }
                    else if (limit < item.limit){
                        counter = limit;
                        blockLimit = item.limit; //257827
                        more = YES;
                    }
                }
            }
            
            if (needGenerated) {
                for (NSInteger i = counter; i < blockLimit; i++) {
                    
                    NSInteger d = 0;
                    
                    for (int c = 1; c <= i; c++) {
                        if (i%c == 0 || i%c == i) {
                            d++;
                            if (d > 2) {
                                break;
                            }
                        }
                    }
                    
                    if (d == 2) {
                        [result addObject:@(i)];
                    }
                }
            }
            
            if (more) {
                NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[item.result mutableCopy]];
                
                NSInteger resultCount = [result count] > 1 ? [result count] : 0;
                NSInteger originalCount = [item.result count];
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(originalCount - resultCount, resultCount)];
                
                [temp removeObjectsAtIndexes:set];
                
                result = temp;
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HistoryManager sharedInstance] addToHistory:[HistoryItem itemWithLimit:limit result:result]];
                self.textView.text = [result componentsJoinedByString:@", "];
                self.textView.contentOffset = CGPointZero;
                [self.indicatorView stopAnimating];
                self.generateButton.enabled = YES;
            });
            
        });
    }
    else {
        self.textField.text = @"";
    }
}

- (void)showHistoryResult {
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.textView.text = nil;
    return ([[string lowercaseString] rangeOfString:@"[^0-9]" options:NSRegularExpressionSearch].location == NSNotFound);
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self generateAction:nil];
    return YES;
}

@end
