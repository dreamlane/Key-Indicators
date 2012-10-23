//
//  IndicatorSummaryCell.h
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomProgressView.h"

@interface IndicatorSummaryCell : UITableViewCell 
{
    UIImageView* _backingView;
    UILabel* _titleLabel;
    //UILabel* _parentLabel; //REMOVED
    //UIImageView* _iconView; //REMOVED
    UIImageView* _indicatorOnView;
    CustomProgressView* _weekGoalProgressView;
    CustomProgressView* _monthGoalProgressView;
    BOOL _indicatorBulbOn;
}

@property (retain) IBOutlet CustomProgressView* weekGoalProgressView;
@property (retain) IBOutlet CustomProgressView* monthGoalProgressView;
@property (retain) IBOutlet UIImageView* backingView;
@property (retain) IBOutlet UILabel* titleLabel;
//@property (retain) IBOutlet UILabel* parentLabel; //REMOVED
//@property (retain) IBOutlet UIImageView* iconView; //REMOVED
@property (retain) IBOutlet UIImageView* indicatorOnView;
@property BOOL indicatorBulbOn;

@end
