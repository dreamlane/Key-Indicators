//
//  IndicatorListView.h
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import "IndicatorDetailView.h"
#import "IndicatorSummaryCell.h"
#import "CategorySummaryCell.h"
#import <QuartzCore/QuartzCore.h>

@interface IndicatorListView : UITableViewController <UIActionSheetDelegate,UINavigationControllerDelegate,UIAlertViewDelegate> 
{
	IndicatorDetailView* _indicatorDetailView;
    NSDictionary* _indicators;
    NSMutableDictionary* _categories;
    NSArray* _categoryKeys;
    NSString* thisWeek;
    NSString* thisMonth;
}


@property (retain) IndicatorDetailView* indicatorDetailView;
@property (retain) NSDictionary* indicators;
@property (retain) NSMutableDictionary* categories;
@property (retain) NSArray* categoryKeys;
@property (retain) NSString* thisWeek;
@property (retain) NSString* thisMonth;

-(IBAction)showNewIndicatorActionSheet:(id)sender;
-(void) sortCategories;

@end
