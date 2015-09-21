//
//  HistoryManager.m
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "HistoryManager.h"
#import "HistoryItem.h"

static NSString *const nCacheLimit = @"nCacheLimit";
static NSString *const nCacheResult = @"nCacheResult";

@interface HistoryManager ()

@property (copy, nonatomic) NSString *path;

@end

@implementation HistoryManager

+ (instancetype)sharedInstance {
    static dispatch_once_t oncePredicate;
    static HistoryManager *_sharedManager = nil;
    
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"history"];
        [self load];
    }
    
    return self;
}
- (BOOL)save
{
    return [NSKeyedArchiver archiveRootObject:self.history toFile:self.path];
}

- (void)load
{
    NSArray *history = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
    if (![history isKindOfClass:[NSArray class]])
    {
        _history = nil;
    }
    
    _history = history;
}

- (void)addToHistory:(HistoryItem *)item {
    if (!item) {
        return;
    }
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.history];
    
    if (!temp) {
        temp = [[NSMutableArray alloc] init];
    }
    
    [temp addObject:item];
    _history = [temp copy];
    [self updateCacheForLimit:item.limit result:item.result];
    [self save];
}

/*
- (HistoryItem *)cacheDataForLimit:(NSInteger)limit {
    if ([self.history count]) {
        NSArray *sortedHistory = [self.history sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"limit"ascending:YES]]];
        
        HistoryItem *min = [sortedHistory firstObject];
        HistoryItem *max = nil;
        if ([sortedHistory count] > 1) {
            max = [sortedHistory lastObject];
        }
        
        HistoryItem *historyItem = nil;
        

        for (HistoryItem *item in sortedHistory) {
            if (item.limit == limit) {
                return item;
            }
            else if (item.limit < limit && (min && item.limit > min.limit)) {
                min = item;
            }
            else if (item.limit > limit && (max && item.limit < max.limit)) {
                max = item;
            }
            
            if (max && item.limit > max.limit) {
                break;
            }
        }
        
        historyItem = (min && max) ? ( (limit - min.limit < max.limit - limit) ? min : max ) : min;
        
        return historyItem;
    }
    
    return nil;
}
*/

- (void)removeItem:(HistoryItem *)item {
    if (!item) {
        return;
    }
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:self.history];
    
    [temp removeObject:item];
    _history = [temp copy];
    [self save];
}

- (void)clearHistory {
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    [self clearCache];
    _history = nil;
}

- (void)updateCacheForLimit:(NSInteger)limit result:(NSArray *)result {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastLimit = [defaults objectForKey:nCacheLimit] ? [[defaults objectForKey:nCacheLimit] integerValue] : 0;
    if (lastLimit < limit) {
        [defaults setObject:@(limit) forKey:nCacheLimit];
        [defaults setObject:result forKey:nCacheResult];
        [defaults synchronize];
    }
}

- (HistoryItem *)getChache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:nCacheLimit] && [defaults objectForKey:nCacheResult]) {
        return [HistoryItem itemWithLimit:[[defaults objectForKey:nCacheLimit] integerValue] result:[defaults objectForKey:nCacheResult]];
    }
    return nil;
}

- (void)clearCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:nCacheLimit];
    [defaults removeObjectForKey:nCacheResult];
    [defaults synchronize];
}

@end
