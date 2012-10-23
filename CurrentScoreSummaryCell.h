//
//  CurrentScoreSummaryCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface CurrentScoreSummaryCell : UITableViewCell
{
    UILabel* _currentWeekScoreLabel;
    UILabel* _currentWeekMaxLabel;
    UILabel* _currentMonthScoreLabel;
    UILabel* _currentMonthMaxLabel;
    CustomProgressView* _weekGoalProgressView;
    CustomProgressView* _monthGoalProgressView;
}

@property (retain) IBOutlet UILabel* currentWeekScoreLabel;
@property (retain) IBOutlet UILabel* currentWeekMaxLabel;
@property (retain) IBOutlet UILabel* currentMonthScoreLabel;
@property (retain) IBOutlet UILabel* currentMonthMaxLabel;
@property (retain) IBOutlet CustomProgressView* weekGoalProgressView;
@property (retain) IBOutlet CustomProgressView* monthGoalProgressView;
@end
