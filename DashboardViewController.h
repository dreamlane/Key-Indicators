//
//  DashboardViewController.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorSummaryCell.h"

@interface DashboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView* _tmpTableView;
    
}

@property (retain) IBOutlet UITableView* tmpTableView;
@end
