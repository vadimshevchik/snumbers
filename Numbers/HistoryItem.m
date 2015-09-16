//
//  HistoryItem.m
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeInteger:self.limit forKey:@"limit"];
    [coder encodeObject:self.result forKey:@"result"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _date = [coder decodeObjectForKey:@"date"];
        self.limit = [coder decodeIntegerForKey:@"limit"];
        self.result = [coder decodeObjectForKey:@"result"];
    }
    return self;
}

+ (HistoryItem *)itemWithLimit:(NSInteger)limit result:(NSArray *)result {
    HistoryItem *item = [[HistoryItem alloc] init];
    item.limit = limit;
    item.result = result;
    
    return item;
}

- (void)setResult:(NSArray *)result {
    _result = result;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy в HH:mm"];
    NSDate *now = [[NSDate alloc] init];
    _date = [formatter stringFromDate:now];
}

@end
