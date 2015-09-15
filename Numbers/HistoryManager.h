//
//  HistoryManager.h
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HistoryItem;

@interface HistoryManager : NSObject

@property (strong, nonatomic, readonly) NSArray *history;

+ (instancetype)sharedInstance;

- (void)addToHistory:(HistoryItem *)item;
- (void)clearHistory;
- (void)removeItem:(HistoryItem *)item;
- (HistoryItem *)cacheDataForLimit:(NSInteger)limit;

//
- (BOOL)existInHistory:(NSInteger)limit;
- (NSArray *)resultForLimit:(NSInteger)limit;

@end
