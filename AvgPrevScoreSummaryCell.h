//
//  AvgPrevScoreSummaryCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvgPrevScoreSummaryCell : UITableViewCell
{
    UILabel* _previousMonthScoreLabel;
    UILabel* _previousWeekScoreLabel;
    UILabel* _averageMonthScoreLabel;
    UILabel* _averageWeekScoreLabel;
}

@property (retain) IBOutlet UILabel* previousWeekScoreLabel;
@property (retain) IBOutlet UILabel* previousMonthScoreLabel;
@property (retain) IBOutlet UILabel* averageMonthScoreLabel;
@property (retain) IBOutlet UILabel* averageWeekScoreLabel;
@end

