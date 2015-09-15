//
//  HistoryTableCell.m
//  Numbers
//
//  Created by Vadim Shevchik on 15.09.15.
//  Copyright (c) 2015 vadimshevchik. All rights reserved.
//

#import "HistoryTableCell.h"

@interface HistoryTableCell ()

@property (weak, nonatomic) IBOutlet UILabel *limitLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation HistoryTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.limit = nil;
    self.result = nil;
    self.date = nil;
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.limit = nil;
    self.result = nil;
    self.date = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLimit:(NSString *)limit {
    _limit = limit;
    self.limitLabel.text = limit;
}

- (void)setResult:(NSString *)result {
    _result = result;
    self.resultLabel.text = result;
}

- (void)setDate:(NSString *)date {
    _date = date;
    self.dateLabel.text = date;
}

@end
