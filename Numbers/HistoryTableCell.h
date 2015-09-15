//
//  HistoryTableCell.h
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableCell : UITableViewCell

@property (copy, nonatomic) NSString *limit;
@property (copy, nonatomic) NSString *result;
@property (copy, nonatomic) NSString *date;

@end
