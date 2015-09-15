//
//  HistoryItem.h
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryItem : NSObject <NSCoding>

@property (copy, nonatomic) NSString *date;
@property (nonatomic) NSInteger limit;
@property (strong, nonatomic) NSArray *result;

+ (HistoryItem *)itemWithLimit:(NSInteger)limit result:(NSArray *)result;

@end
