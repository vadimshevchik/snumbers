//
//  ViewController.m
//  Numbers
//
//  Created by Vadim Shevchik on 21.09.15.
//  Copyright © 2015 vadimshevchik. All rights reserved.
//

#import "ViewController.h"

#import "HistoryViewController.h"

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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textView.text = @"";
    self.textField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createActivityIndicator {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = CGRectMake(0.0f, 0.0f, 32.0f, 32.0f);
    self.indicatorView.hidesWhenStopped = YES;
    self.navigationItem.titleView = self.indicatorView;
}

- (UIToolbar *)createDoneButton {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Скрыть" style:UIBarButtonItemStylePlain target:self action:@selector(doneEnterLimitAction:)];
    toolbar.items = [NSArray arrayWithObjects:flex, doneButton, nil];
    
    return toolbar;
}

- (UIBarButtonItem *)createHistoryButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"История" style:UIBarButtonItemStylePlain target:self action:@selector(historyAction:)];
    
    return rightItem;
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
    if (self.textView.text.length) {
        return;
    }
    if (limit > 1) {
        [self.textField resignFirstResponder];
        [self.indicatorView startAnimating];
        self.generateButton.enabled = NO;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray * result = [[NSMutableArray alloc] init];
            NSString *resultText = nil;
            BOOL more = NO;
            NSInteger counter = 1;
            
            NSInteger blockLimit = limit;
            
            HistoryItem *cache = [[HistoryManager sharedInstance] getChache];
            if (cache) {
                if (limit >= cache.limit) {
                    counter = limit - (limit - cache.limit);
                    [result addObjectsFromArray:cache.result];
                }
                else if (limit <= cache.limit) {
                    if (cache.limit - limit < limit) {
                        counter = limit;
                        blockLimit = cache.limit;
                        more = YES;
                    }
                }
            }
            
            for (NSInteger i = counter; i < blockLimit; i++) {
                NSInteger repeats = 0;
                
                for (int c = 1; c <= i; c++) {
                    
                    if (i%c == 0 || i%c == i) {
                        repeats++;
                        if (repeats > 2) {
                            break;
                        }
                    }
                    if (c > sqrt(blockLimit) && repeats < 2) {
                        [result addObject:@(i)];
                        break;
                    }
                }
                
                if (repeats == 2) {
                    [result addObject:@(i)];
                }
            }
            
            if (more) {
                NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[cache.result mutableCopy]];
                
                NSInteger resultCount = [result count] > 1 ? [result count] : 0;
                NSInteger originalCount = [cache.result count];
                NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(originalCount - resultCount, resultCount)];
                
                [temp removeObjectsAtIndexes:set];
                
                result = temp;
            }
            
            [[HistoryManager sharedInstance] addToHistory:[HistoryItem itemWithLimit:limit result:result]];
            resultText = [result componentsJoinedByString:@", "];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.textView.text = resultText;
                self.textView.contentOffset = CGPointZero;
                [self.indicatorView stopAnimating];
                self.generateButton.enabled = YES;
            });
            
        });
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.textView.text.length) {
        self.textView.text = @"";
    }
    
    self.textView.text = nil;
    return ([[string lowercaseString] rangeOfString:@"[^0-9]" options:NSRegularExpressionSearch].location == NSNotFound);
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self generateAction:nil];
    return YES;
}

@end
