//
//  CategoryListView.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryDetailView.h"
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import "IndicatorDetailView.h"
#import "CategorySummaryCell.h"


// THIS FILE IS DEPRECATED< AND SHOULD BE REMOVED SOON
@interface CategoryListView : UITableViewController <UIActionSheetDelegate,UINavigationControllerDelegate>
{
    CategoryDetailView* _categoryDetailView;
}

@property (retain) CategoryDetailView* categoryDetailView;

-(IBAction)showActionSheet:(id)sender;

@end
