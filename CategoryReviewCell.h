//
//  CategoryReviewCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 2/15/12.
//  Copyright (c) 2012 Blank Sketch Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryReviewCell : UITableViewCell 
{
    UILabel* titleLabel;
    UILabel* lastMonth;
    UILabel* lastWeek;
}

@property (retain) IBOutlet UILabel* titleLabel;
@property (retain) IBOutlet UILabel* lastMonth;
@property (retain) IBOutlet UILabel* lastWeek;

@end
