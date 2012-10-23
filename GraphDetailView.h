//
//  GraphDetailView.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import "CorePlot-CocoaTouch.h"
#import "DateRange.h"
#import "MBProgressHUD.h"

@interface GraphDetailView : UIViewController <CPTPlotDataSource,CPTScatterPlotDelegate>
{
    CPTXYGraph *_graph;
    IndicatorDoc *_indicatorDoc;
    NSMutableDictionary* indicatorDocs;
    NSMutableArray* _axisLabelStrings;
    NSMutableArray* _actualDataForPlot;
    NSMutableArray* _goalDataForPlot;
    CPTPlotSpaceAnnotation* _symbolTextAnnotation;
    //float _count;
    BOOL month; //used to decide whether to show weekly or monthly info
    MBProgressHUD* mbProgress; //Loading indicator view
    NSString* type;
}

@property (retain) IndicatorDoc* indicatorDoc;
@property (retain) NSMutableDictionary* indicatorDocs;
@property (retain) NSMutableArray* axisLabelStrings;
@property (retain) NSMutableArray* actualDataForPlot;
@property (retain) NSMutableArray* goalDataForPlot;
@property (retain) CPTPlotSpaceAnnotation* symbolTextAnnotation;
@property (retain) CPTXYGraph* graph;
@property (retain) NSString* type;
//@property float count;

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index;
@end
