//
//  DetailViewController.h
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryItem;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) HistoryItem *item;

@end
