//
//  ChartDetailView.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 2/17/12.
//  Copyright (c) 2012 Blank Sketch Studios LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import "BNPieChart.h"
#import "DateRange.h"
#import "MBProgressHUD.h"

@interface ChartDetailView : UIViewController <UIPickerViewDelegate>
{
    BNPieChart* chart;
    NSString* category;
    NSString* dateKey;
    NSMutableArray* timerDocs;
    NSMutableArray* dateRanges;
    UIActionSheet* dateRangePickerSheet;
    UILabel* totalTimeLabel;
}

@property (retain) BNPieChart* chart;
@property (retain) NSString* category;
@property (retain) NSString* dateKey;
@property (retain) NSMutableArray* timerDocs;
@property (retain) NSMutableArray* dateRanges;
@property (retain) UIActionSheet* dateRangePickerSheet;
@property (retain) IBOutlet UILabel* totalTimeLabel;

@end
