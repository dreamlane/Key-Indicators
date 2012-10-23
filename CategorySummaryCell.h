//
//  CategorySummaryCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 2/16/12.
//  Copyright (c) 2012 Blank Sketch Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategorySummaryCell : UITableViewCell 
{
    UILabel* titleLabel;
    UILabel* thisMonth;
    UILabel* thisWeek;
}

@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UILabel* thisMonth;
@property (retain) IBOutlet UILabel* thisWeek;

@end
