//
//  ReviewSummaryCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewSummaryCell : UITableViewCell 
{
    UILabel* titleLabel;
    UILabel* lastMonth;
    UILabel* lastWeek;
}

@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UILabel* lastMonth;
@property (retain) IBOutlet UILabel* lastWeek;

@end