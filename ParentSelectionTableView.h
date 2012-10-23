//
//  ParentSelectionTableView.h
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorData.h"
#import "IndicatorDatabase.h"
#import "IndicatorDoc.h"

@interface ParentSelectionTableView : UITableViewController {
	NSMutableArray* _legalParents;
	IndicatorDoc* _indicatorDoc;
}

@property (retain) IndicatorDoc* indicatorDoc;
@property (retain) NSMutableArray* legalParents;

@end
