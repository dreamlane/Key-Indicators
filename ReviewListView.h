//
//  ReviewView.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphDetailView.h"
#import "ChartDetailView.h"
#import "IndicatorDatabase.h"
#import "LifetimeSummaryCell.h"
#import "AvgPrevScoreSummaryCell.h"
#import "ReviewSummaryCell.h"
#import "CurrentScoreSummaryCell.h"
#import "CategoryReviewCell.h"

@interface ReviewListView : UITableViewController <UINavigationControllerDelegate>
{
    GraphDetailView* _graphDetailView;
    ChartDetailView* chartDetailView;
    NSDictionary* _indicators;
    NSMutableDictionary* _categories;
    NSArray* _categoryKeys;
    
    NSString* _lastMonthKey;
    NSString* _lastWeekKey;
    NSString* _currentWeek;
    NSString* _currentMonth;
}

@property (nonatomic, retain) GraphDetailView* graphDetailView;
@property (nonatomic, retain) ChartDetailView* chartDetailView;
@property (retain) NSDictionary* indicators;
@property (retain) NSMutableDictionary* categories;
@property (retain) NSArray* categoryKeys;
@property (retain) NSString* lastMonthKey;
@property (retain) NSString* lastWeekKey;
@property (retain) NSString* currentWeek;
@property (retain) NSString* currentMonth;

-(void)sortCategories;
@end
