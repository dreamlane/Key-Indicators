//
//  AvgPrevScoreSummaryCell.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvgPrevScoreSummaryCell.h"

@implementation AvgPrevScoreSummaryCell

@synthesize previousWeekScoreLabel = _previousWeekScoreLabel;
@synthesize previousMonthScoreLabel = _perviousMonthScoreLabel;
@synthesize averageWeekScoreLabel = _averageWeekScoreLabel;
@synthesize averageMonthScoreLabel = _averageMonthScoreLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
