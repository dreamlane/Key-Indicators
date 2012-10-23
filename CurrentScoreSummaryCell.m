//
//  CurrentScoreSummaryCell.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CurrentScoreSummaryCell.h"

@implementation CurrentScoreSummaryCell

@synthesize currentWeekMaxLabel = _currentWeekMaxLabel;
@synthesize currentWeekScoreLabel = _currentWeekScoreLabel;
@synthesize currentMonthMaxLabel = _currentMonthMaxLabel;
@synthesize currentMonthScoreLabel = _currentMonthScoreLabel;
@synthesize weekGoalProgressView = _weekGoalProgressView; //how close to the max score?
@synthesize monthGoalProgressView = _monthGoalProgressView;

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
