//
//  GraphDetailView.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphDetailView.h"

@implementation GraphDetailView

@synthesize indicatorDoc = _indicatorDoc;
@synthesize indicatorDocs;
@synthesize axisLabelStrings = _axisLabelStrings;
@synthesize actualDataForPlot = _actualDataForPlot;
@synthesize goalDataForPlot = _goalDataForPlot;
@synthesize symbolTextAnnotation = _symbolTextAnnotation;
@synthesize graph = _graph;
@synthesize type;

float maximum;

#define yMajorTickCount 7//the number of major ticks on the y axis

#pragma mark Graph Helpers

/*
 * Takes an array of DateRange generated keys, and then sorts them in ascending order
 */
-(NSMutableArray*)orderKeys:(NSMutableArray*) keysArray
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray* sortedArray = [NSMutableArray arrayWithCapacity:[keysArray count]];
    for (NSString* key in keysArray) {
        //get the start date
        NSDate* date = [fmt dateFromString:[key substringToIndex:(19)]];
        //add it to the unsorted array
        [sortedArray addObject:date];
    }
    [fmt release];
    //sort the array
    [sortedArray sortUsingSelector:@selector(compare:)];
    //NSLog(@"array is now sorted: %@",[sortedArray description]);
    //return the dates to string form
    DateRange* keyRange;
    NSMutableArray* sortedKeyArray = [NSMutableArray arrayWithCapacity:[sortedArray count]];
    for (NSDate* date in sortedArray) {
        if (month) {
            //add a month to the start dates
            keyRange = [DateRange monthContainingDate:date];
        }
        else { 
            //add a week to the start date
            keyRange = [DateRange weekContainingDate:date];
        }
        //covert the daterange back into a key
        NSString* key = [DateRange keyFromDateRange:keyRange];
        [sortedKeyArray addObject:key];
    }
    //NSLog(@"Sorted key Array: %@",[sortedKeyArray description]);
    return sortedKeyArray;
}

-(void)generatePlotData
{
    self.axisLabelStrings = [NSMutableArray arrayWithCapacity:1];
    self.actualDataForPlot = [NSMutableArray arrayWithCapacity:1];
    self.goalDataForPlot = [NSMutableArray arrayWithCapacity:1];
    maximum = 0.0f;
    if ([type isEqualToString:@"Indicator"]) 
    {
        //get the applicable keys: month or week
        NSArray* allKeys = [_indicatorDoc.data.periodGoals allKeys];
        NSMutableArray* prunedKeys = [NSMutableArray arrayWithCapacity:1];
        //NSLog(@"keys: %@",[allKeys description]);
        //get the highest value of the goals
        if (month) //monthly view section
        {
            for (NSString* key in allKeys) {
                //NSLog(key);
                if(![DateRange isWeekKey:key])
                {
                    [prunedKeys addObject:key]; //add the month key to the prunedkeys list
                    //check for maximum
                    if (maximum < [[_indicatorDoc.data.periodGoals objectForKey:key] floatValue])
                        maximum = [[_indicatorDoc.data.periodGoals objectForKey:key] floatValue];
                    if (maximum < [_indicatorDoc periodValueWithKey:key])
                        maximum = [_indicatorDoc periodValueWithKey:key];
                }
            }
        }
        else //Weekly data
        {
            for (NSString* key in allKeys) {
                //NSLog(key);
                if([DateRange isWeekKey:key])
                {
                    [prunedKeys addObject:key]; //add the week key to the prunedkeys list
                    //check for maximum
                    if (maximum < [[_indicatorDoc.data.periodGoals objectForKey:key] floatValue])
                        maximum = [[_indicatorDoc.data.periodGoals objectForKey:key] floatValue];
                    if (maximum < [_indicatorDoc periodValueWithKey:key])
                        maximum = [_indicatorDoc periodValueWithKey:key];
                }
            }

        }
        //sort the keys
        prunedKeys = [self orderKeys:prunedKeys];
        //now that they are sorted, add all the label keys
        for (NSString* key in prunedKeys) {
            [_axisLabelStrings addObject:[DateRange periodLabelWithKey:key]]; //add the label string
        }
        //NSLog(@"prunedKeys: %@",[prunedKeys description]);
        //NSLog(@"axisLabels: %@",[_axisLabelStrings description]);
        NSUInteger i = 0;
        for (NSString* key in prunedKeys)
        {
            //get the actual
            id yActualPoint = [NSNumber numberWithFloat:[_indicatorDoc periodValueWithKey:key]];
            id xActualPoint = [NSNumber numberWithInt:i];
            //get the goal
            id yGoalPoint = [NSNumber numberWithFloat:[[_indicatorDoc.data.periodGoals objectForKey:key] floatValue]];
            id xGoalPoint = [NSNumber numberWithInt:i];
            //NSLog(@"Actual for key %@ is: %1.2f, and goal is: %1.2f",key,[yActualPoint floatValue],[yGoalPoint floatValue]);
            //add them to the dataset
            [_actualDataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:xActualPoint,@"xActualPoint",yActualPoint,@"yActualPoint", nil]];
            [_goalDataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:xGoalPoint,@"xGoalPoint",yGoalPoint,@"yGoalPoint",nil]];
            i++;
        }
    }
    else if ([self.type isEqualToString:@"Score"]) // A Score graph
    {
        //get the applicable keys: month or week
        NSMutableArray* prunedKeys = [NSMutableArray arrayWithCapacity:1];
        self.indicatorDocs = [[IndicatorDatabase sharedDatabase] loadIndicatorDocs];
        //get the highest value of the goals
        if (month) //monthly view section
        {
            for (NSString* iKey in self.indicatorDocs)
            {
                IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
                for (NSString* key in doc.data.periodScores) {
                    //NSLog(key);
                    if(![DateRange isWeekKey:key])
                    {
                        //Make sure the key is not already a part of the set, this is an O(n^2) operation, but at most n should be 100 or so... we are already 2 loops deep though... The first loop should run at most 25 times, the second at most 100... TODO: optimize by making prunedKeys a set instead of a array
                        if ([prunedKeys indexOfObject:key] == NSNotFound) 
                        {
                            [prunedKeys addObject:key]; //add the month key to the prunedkeys list
                        }
                    }
                }
            }
        }
        else //weekly view section
        {
            for (NSString* iKey in self.indicatorDocs)
            {
                IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
                for (NSString* key in doc.data.periodScores) 
                {
                    //NSLog(key);
                    if([DateRange isWeekKey:key])
                    {
                        //Make sure the key is not already a part of the set, this is an O(n^2) operation, but at most n should be 100 or so,
                        if ([prunedKeys indexOfObject:key] == NSNotFound) 
                        {
                            [prunedKeys addObject:key]; //add the month key to the prunedkeys list
                        }
                    }
                }
            }
        }
        //check for maximum
        for (NSString* key in prunedKeys)
        {
            int keyTotal = 0;
            for (NSString* iKey in self.indicatorDocs)
            {
                IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
                keyTotal += [[doc.data.periodScores objectForKey:key] intValue];
            }
            if (keyTotal > maximum) {
                maximum = keyTotal;
            }
        }
        //sort the keys
        prunedKeys = [self orderKeys:prunedKeys];
        //now that they are sorted, add all the label keys
        for (NSString* key in prunedKeys) {
            [_axisLabelStrings addObject:[DateRange periodLabelWithKey:key]]; //add the label string
        }
        //NSLog(@"prunedKeys: %@",[prunedKeys description]);
        //NSLog(@"axisLabels: %@",[_axisLabelStrings description]);
        NSUInteger i = 0;
        for (NSString* key in prunedKeys)
        {
            //get the score
            float dateScore = 0.0f;
            for (NSString* iKey in self.indicatorDocs)
            {
                IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
                dateScore += [[doc.data.periodScores objectForKey:key] floatValue];
            }
            NSLog(@"DateScore: %1.2f",dateScore);
            id yActualPoint = [NSNumber numberWithFloat:dateScore];
            id xActualPoint = [NSNumber numberWithInt:i];
            //add them to the dataset
            [_actualDataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:xActualPoint,@"xActualPoint",yActualPoint,@"yActualPoint", nil]];
            i++;
        }
    }
    else if ([self.type isEqualToString:@"Lifetime Score"]) // Lifetime Score Graph
    {
        //get the applicable keys: month or week
        NSMutableArray* prunedKeys = [NSMutableArray arrayWithCapacity:1];
        self.indicatorDocs = [[IndicatorDatabase sharedDatabase] loadIndicatorDocs];
        //get the highest value of the goals
        for (NSString* iKey in self.indicatorDocs)
        {
            IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
            for (NSString* key in doc.data.periodScores) {
                        //Make sure the key is not already a part of the set, this is an O(n^2) operation, but at most n should be 100 or so... we are already 2 loops deep though... The first loop should run at most 25 times, the second at most 100
                if ([prunedKeys indexOfObject:key] == NSNotFound) 
                {
                    [prunedKeys addObject:key]; //add the key to the list
                }
            }
        }
        //sort the keys
        //now that they are sorted, add all the 
        for (int i = 1;i <= [prunedKeys count];i++) {
            [_axisLabelStrings addObject:[NSString stringWithFormat:@"",i]]; //add the label string
        }
        //NSLog(@"prunedKeys: %@",[prunedKeys description]);
        //NSLog(@"axisLabels: %@",[_axisLabelStrings description]);
        NSUInteger i = 0;
        float accumScore = 0.0f; // Accumulated score
        for (NSString* key in prunedKeys)
        {
            //get the score
            float keyScore = 0.0f;
            for (NSString* iKey in self.indicatorDocs)
            {
                IndicatorDoc* doc = [self.indicatorDocs objectForKey:iKey];
                keyScore += [[doc.data.periodScores objectForKey:key] floatValue];
            }
            keyScore /= 2;
            accumScore += keyScore;
            id yActualPoint = [NSNumber numberWithFloat:accumScore];
            id xActualPoint = [NSNumber numberWithInt:i];
            //add them to the dataset
            [_actualDataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:xActualPoint,@"xActualPoint",yActualPoint,@"yActualPoint", nil]];
            i++;
        }
        maximum = accumScore*1.15;
    }
    
    // replace the last key with "This Month" or This Week
    if (![self.type isEqualToString:@"Lifetime Score"])
    {
        if (month) {
            [_axisLabelStrings replaceObjectAtIndex:[_axisLabelStrings count]-1 withObject:@"This Month"];
        }
        else
            [_axisLabelStrings replaceObjectAtIndex:[_axisLabelStrings count]-1 withObject:@"This Week"];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)createGraph
{
    //NSLog(@"month is %d",month); // 0=NO 1=YES
    //Generate the data
    
    //NSLog(@"max is : %1.2f",maximum); 
    // NSLog(@"count is : %1.2f",self.count);
    self.graph = [[CPTXYGraph alloc] initWithFrame: self.view.bounds];
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView*)self.view;
    
    //set up the theme for the graph
    
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
	[self.graph applyTheme:theme];
    self.graph.fill = nil;
    self.graph.plotAreaFrame.fill = nil;
    hostingView.hostedGraph = self.graph;
    
    
    // Set up all of the paddings
    // The graph itself
    self.graph.paddingLeft = 5.0;
    self.graph.paddingTop =8.0;
    self.graph.paddingRight =5.0;
    self.graph.paddingBottom = 100.0;
    // The plot area within the graph
    self.graph.plotAreaFrame.paddingTop    = 20.0;
    self.graph.plotAreaFrame.paddingBottom = 75.0; //increase if bottom labels are getting cutoff
    self.graph.plotAreaFrame.paddingLeft   = 53.0; //increase if the y values are getting cut off
    self.graph.plotAreaFrame.paddingRight  = 10.0;
    
    //generate the plot data
    [self generatePlotData]; //This needs to be done before a lot of the other things below
    
    // setup the plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1) 
                                                    length:CPTDecimalFromFloat([_actualDataForPlot count]+2.0f)];
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1) 
                                                          length:CPTDecimalFromFloat([_actualDataForPlot count]+2.0f)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) /*set to min?*/
                                                          length:CPTDecimalFromFloat(maximum*1.33f)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) /*set to min?*/
                                                    length:CPTDecimalFromFloat(maximum*1.33f)];
    
    CPTMutableLineStyle* graphPlotBorderLine = [CPTMutableLineStyle lineStyle];
    graphPlotBorderLine.lineColor = [CPTColor lightGrayColor];
    graphPlotBorderLine.lineWidth = 3.0f;
    [self.graph plotAreaFrame].borderLineStyle = graphPlotBorderLine;
    [self.graph plotAreaFrame].cornerRadius = 3.0f;
    
    //set up the axes
    //get the axes labels
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTMutableTextStyle* axisTextStyle = [CPTMutableTextStyle textStyle];
    axisTextStyle.fontName = @"Futura";
    [axisTextStyle setColor:[CPTColor colorWithComponentRed:0.0f green:0.5 blue:0.65 alpha:1]];
    x.labelTextStyle = axisTextStyle;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0]; 
    x.majorIntervalLength = CPTDecimalFromFloat(1);
    x.minorTicksPerInterval = 0;
    x.titleTextStyle = axisTextStyle;
    if (month)
        x.title = @"Month";
    else
        x.title = @"Week";
    if ([self.type isEqualToString:@"Lifetime Score"]) {
        x.title = @"";
    }
    x.titleOffset = 55;
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    
    //setup the linestyles
    CPTMutableLineStyle *axisLineStyle = [CPTLineStyle lineStyle];
    CPTMutableLineStyle *xMajorTickLineStyle = [CPTMutableLineStyle lineStyle];
    CPTMutableLineStyle *goalLineStyle = [CPTMutableLineStyle lineStyle];
    CPTMutableLineStyle *actualLineStyle = [CPTMutableLineStyle lineStyle];
    // Axis Lines
    axisLineStyle.lineColor = [CPTColor darkGrayColor];
    axisLineStyle.lineWidth = 2.0f;
    // Major Tick Lines for X axis
    xMajorTickLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:8.0f], nil];
    xMajorTickLineStyle.lineColor = [CPTColor lightGrayColor];
    xMajorTickLineStyle.lineWidth = 1.0f;
    // Goal Line Style
    goalLineStyle.lineColor = [CPTColor redColor];
    goalLineStyle.lineWidth = 3.0f;
    goalLineStyle.lineCap = kCGLineCapRound;
    // Actual Line Style
    if ([self.type isEqualToString:@"Indicator"])
    {
        actualLineStyle.lineColor = [CPTColor colorWithComponentRed:0.0f green:0.52f blue:0.68f alpha:1.0f];
        actualLineStyle.lineWidth = 3.0f;
        actualLineStyle.lineCap = kCGLineCapRound;
        actualLineStyle.lineJoin = kCGLineJoinRound;
    }
    else
    {
        actualLineStyle.lineColor = [CPTColor colorWithComponentRed:0.8f green:0.52f blue:0.28f alpha:1.0f];
        actualLineStyle.lineWidth = 3.0f;
        actualLineStyle.lineCap = kCGLineCapRound;
        actualLineStyle.lineJoin = kCGLineJoinRound;
    }
    //Apply x axis line styles
    x.axisLineStyle = axisLineStyle;
    x.majorGridLineStyle = xMajorTickLineStyle;
    
    /* --Define some custom labels for the data elements-- */
    x.labelingPolicy = CPTAxisLabelingPolicyNone; // This allows us to create custom axis labels for x axis
    NSMutableArray *ticks = [NSMutableArray arrayWithCapacity:1];
    for(unsigned int counter = 0; counter < [_axisLabelStrings count];counter++) {
        // Here the instance variable _axisLabelStrings is a list of custom labels
        [ticks addObject:[NSNumber numberWithInt:counter]];
    }
    NSUInteger labelLocation = 0;
    NSMutableArray* customLabels = [NSMutableArray arrayWithCapacity:[_axisLabelStrings count]];
    @try {
        for (NSNumber *tickLocation in ticks) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [_axisLabelStrings objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
            newLabel.tickLocation = [tickLocation decimalValue];
            newLabel.offset = 3.0f;//x.labelOffset + x.majorTickLength could be useful here.
            newLabel.rotation = M_PI/3.5f;
            [customLabels addObject:newLabel];
            [newLabel release];
        }
    }
    @catch (NSException * e) {
        NSLog(@"An exception occured while creating date labels for x-axis");
    }
    @finally {
        x.axisLabels =  [NSSet setWithArray:customLabels];  
    }
    x.majorTickLocations = [NSSet setWithArray:ticks];
    
    // set up the y axis
    CPTXYAxis *y = axisSet.yAxis;    
    CPTMutableLineStyle *yMajorTickLineStyle = [CPTMutableLineStyle lineStyle];
    y.majorIntervalLength = CPTDecimalFromFloat(maximum/(yMajorTickCount-1)); //Show yMajorTickCount majorTicks
    y.axisLineStyle = axisLineStyle;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelTextStyle = axisTextStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    //Setup the number labels
    if ([self.type isEqualToString:@"Indicator"])
    {
        if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) {
            //setup the array of labels for time so that they look like 2:34 etc
            NSMutableArray* yLabelTicks = [NSMutableArray arrayWithCapacity:yMajorTickCount]; //7 used here because that's the number of major ticks on the y axis
            NSMutableArray* yCustomLabels = [NSMutableArray arrayWithCapacity:yMajorTickCount];
            for (unsigned int counter = 0; counter <= yMajorTickCount; counter++)
            {
                [yLabelTicks addObject:[NSNumber numberWithFloat:(maximum/yMajorTickCount)*(yMajorTickCount-counter)]];
            }
            @try {
                for (NSNumber* tickLocation in yLabelTicks) {
                    int minutes = [tickLocation floatValue]*60;
                    int hours = ((minutes - (minutes%60))/60);
                    minutes = minutes%60;
                    CPTAxisLabel* newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d:%02d",hours,minutes] textStyle:y.labelTextStyle];
                    newLabel.tickLocation = [tickLocation decimalValue];
                    newLabel.offset = 5.0f;
                    [yCustomLabels addObject:newLabel];
                    [newLabel release];
                }
            } @catch (NSException* e) {
                //NSLog(@"An exception occured while creating th edata labels for the y axis");
            }
            @finally {
                y.axisLabels = [NSSet setWithArray:yCustomLabels];
            }
            y.majorTickLocations = [NSSet setWithArray:yLabelTicks];
            
        }
        else // Tallies
        {
            //setup the array of labels for tallies so that they look like 234 etc
            NSMutableArray* yLabelTicks = [[[NSMutableArray alloc] initWithCapacity:yMajorTickCount] autorelease]; //7 used here because that's the number of major ticks on the y axis
            NSMutableArray* yCustomLabels = [NSMutableArray arrayWithCapacity:1];
            for (unsigned int counter = 0; counter <= yMajorTickCount; counter++)
            {
                [yLabelTicks addObject:[NSNumber numberWithFloat:(maximum/yMajorTickCount)*(yMajorTickCount-counter)]];
            }
            @try {
                for (NSNumber* tickLocation in yLabelTicks) {
                    CPTAxisLabel* newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",[tickLocation intValue]] textStyle:y.labelTextStyle];
                    newLabel.tickLocation = [tickLocation decimalValue];
                    newLabel.offset = 5.0f;
                    [yCustomLabels addObject:newLabel];
                    [newLabel release];
                }
            } @catch (NSException* e) {
                //NSLog(@"An exception occured while creating the data labels for the y axis");
            }
            @finally {
                y.axisLabels = [NSSet setWithArray:yCustomLabels];
            }
            y.majorTickLocations = [NSSet setWithArray:yLabelTicks];
            
        }
    }
    else if ([self.type isEqualToString:@"Score"] || [self.type isEqualToString:@"Lifetime Score"])// Scores y axis labels
    {
        //setup the array of labels for scores so that they look like 234 etc
        NSMutableArray* yLabelTicks = [[[NSMutableArray alloc] initWithCapacity:yMajorTickCount] autorelease]; //7 used here because that's the number of major ticks on the y axis
        NSMutableArray* yCustomLabels = [NSMutableArray arrayWithCapacity:1];
        for (unsigned int counter = 0; counter <= yMajorTickCount; counter++)
        {
            [yLabelTicks addObject:[NSNumber numberWithFloat:(maximum/yMajorTickCount)*(yMajorTickCount-counter)]];
        }
        @try {
            for (NSNumber* tickLocation in yLabelTicks) {
                CPTAxisLabel* newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d",[tickLocation intValue]] textStyle:y.labelTextStyle];
                newLabel.tickLocation = [tickLocation decimalValue];
                newLabel.offset = 5.0f;
                [yCustomLabels addObject:newLabel];
                [newLabel release];
            }
        } @catch (NSException* e) {
            //NSLog(@"An exception occured while creating the data labels for the y axis");
        }
        @finally {
            y.axisLabels = [NSSet setWithArray:yCustomLabels];
        }
        y.majorTickLocations = [NSSet setWithArray:yLabelTicks];
    }

    //setup the y axis major tick line style
    yMajorTickLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:4.0f], nil];
    yMajorTickLineStyle.lineColor = [CPTColor lightGrayColor];
    yMajorTickLineStyle.lineWidth = 1.0f;
    y.majorGridLineStyle = yMajorTickLineStyle;
    //insert the data
    //actual
    CPTScatterPlot* actualLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    if ([self.type isEqualToString:@"Indicator"]) 
    {
        if ([_indicatorDoc.data.type isEqual:@"Timer"])
            actualLinePlot.identifier = @"Actual Hours";
        else
            actualLinePlot.identifier = @"Actual Tallies";
    }
    else
    {
        actualLinePlot.identifier = @"Score";
    }
    actualLinePlot.dataLineStyle = actualLineStyle;
    actualLinePlot.dataSource = self;
    [self.graph addPlot:actualLinePlot];
    
    // Add plot symbols (The symbols that represent plotted points)
	CPTMutableLineStyle *actualSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	actualSymbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *actualPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	actualPlotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
	actualPlotSymbol.lineStyle = actualSymbolLineStyle;
    actualPlotSymbol.size = CGSizeMake(10.0, 10.0);
    actualLinePlot.plotSymbol = actualPlotSymbol;
    actualLinePlot.delegate = self; //Set the delegate for tap detection on plotted points
    actualLinePlot.plotSymbolMarginForHitDetection = 5.0f; // set the hit detection area...
    
    //goal Line
    CPTScatterPlot *goalLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
    goalLinePlot.identifier = @"Goal";
    goalLinePlot.dataLineStyle = goalLineStyle;
    goalLinePlot.dataSource = self;
    if ([self.type isEqualToString:@"Indicator"]) {
        [self.graph addPlot:goalLinePlot];
    }
    //Add plot symbols
    CPTMutableLineStyle *goalSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	goalSymbolLineStyle.lineColor = [CPTColor blackColor];
	CPTPlotSymbol *goalPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	goalPlotSymbol.fill = [CPTFill fillWithColor:[CPTColor brownColor]];
	goalPlotSymbol.lineStyle = goalSymbolLineStyle;
    goalPlotSymbol.size = CGSizeMake(10.0, 10.0);
    goalLinePlot.plotSymbol = goalPlotSymbol;
    goalLinePlot.delegate = self; // Set the delegate for plotted points detection
    goalLinePlot.plotSymbolMarginForHitDetection = 8.0f; // set the hit detection area
    
    // Add legend if it's an indicator
    if ([self.type isEqualToString:@"Indicator"])
    {
        self.graph.legend = [CPTLegend legendWithGraph:self.graph];
        self.graph.legend.textStyle = axisTextStyle;
        self.graph.legend.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:.95 green:.96 blue:.98 alpha:1]];
        self.graph.legend.borderLineStyle = x.axisLineStyle;
        self.graph.legend.cornerRadius = 4.0f;
        self.graph.legend.swatchSize = CGSizeMake(25.0, 25.0);
        self.graph.legendAnchor = CPTRectAnchorBottom;
        self.graph.legendDisplacement = CGPointMake(0.0, 60.0);
    }
    
    //Add a UIImage to the background
    UIImageView* backingImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IndicatorOverviewCelliPhone-tally.png"]];
    [backingImage setFrame:CGRectMake(8.0f, 103.0f, 304.0f, 253.0f)];
    backingImage.transform = CGAffineTransformMakeRotation(M_PI);//the image is upside down for some reason, so this flips it
    [self.view insertSubview:backingImage atIndex:0];
    [backingImage release];
    
    //Add the button only if we are not looking at a Lifetime Score graph
    if (![self.type isEqualToString:@"Lifetime Score"]) {
        //Add a button to switch between month and week views
        UIButton* switchPlotsButton = [[UIButton alloc] initWithFrame:CGRectMake(98, 20, 125, 30)];
        [switchPlotsButton.titleLabel setFont:[UIFont fontWithName:@"Futura" size:17.0f]];
        [switchPlotsButton setTitleColor:[UIColor colorWithRed:0.0f green:0.52f blue:0.68f alpha:1] forState:UIControlStateNormal];
        if (month) {
            [switchPlotsButton setTitle:@"View Weeks" forState:UIControlStateNormal];
        }
        else
            [switchPlotsButton setTitle:@"View Months" forState:UIControlStateNormal];    
        [switchPlotsButton setBackgroundImage:[UIImage imageNamed:@"largeButton.png"] forState:UIControlStateNormal]; 
        //The button is flipped for some reason, so lets fix it...
        switchPlotsButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        switchPlotsButton.transform = CGAffineTransformRotate(switchPlotsButton.transform, M_PI);
        
        //Set up the buttons call back function
        [switchPlotsButton addTarget:self action:@selector(switchPlotsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:switchPlotsButton];
        [self.view bringSubviewToFront:switchPlotsButton];
        [switchPlotsButton release];
    }
    [self.graph reloadData];
    //end the loading screen
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}
#pragma mark - View lifecycle
/*
 * 
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.type isEqualToString:@"Indicator"]) {
        self.title = _indicatorDoc.data.title; //Set the graph's title to be the name of the indicator
    }
    else if ([self.type isEqualToString:@"Score"]) {
        self.title = @"Score Graph";
    }
    else if ([self.type isEqualToString:@"Lifetime Score"]) {
        self.title = @"Lifetime Score";
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    [self performSelector:@selector(createGraph) withObject:nil afterDelay:0.01];
}

#pragma mark - Plot Data Source methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([self.type isEqualToString:@"Score"] || [self.type isEqualToString:@"Lifetime Score"])
    {
        return [_actualDataForPlot count];
    }
    else
        return [_goalDataForPlot count]; 
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;
    if ([plot.identifier isEqual:@"Actual Hours"] || [plot.identifier isEqual:@"Actual Tallies"]) {
        //NSLog(@"Actual data: %@",[_actualDataForPlot description]);
        num = [[_actualDataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"xActualPoint" : @"yActualPoint")];
    }
    else if([plot.identifier isEqual:@"Goal"]) {
        num = [[_goalDataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"xGoalPoint" : @"yGoalPoint")];
    }
    else if ([plot.identifier isEqual:@"Score"])
    {
        num = [[_actualDataForPlot objectAtIndex:index] valueForKey:(fieldEnum == CPTScatterPlotFieldX ? @"xActualPoint" : @"yActualPoint")];
    }
    else
    {
        //NSLog(@"Error getting numberForPlot, returning NSNumber equal to 0.0");
        num = [NSNumber numberWithInt:0];
    }
    //NSLog(@"num is: %1.2f", [num floatValue]);
    return num;
}

#pragma mark - Button Callbacks
-(void)switchPlotsButtonTapped
{
    //NSLog(@"Switch plots button tapped");
    if (month) {
        month = NO;
    }
    else
        month = YES;
    if (self.symbolTextAnnotation != nil) {
        //NSLog(@"Removing annotation");
        [self.graph.plotAreaFrame.plotArea removeAnnotation:self.symbolTextAnnotation];
        //[self.symbolTextAnnotation release];
        self.symbolTextAnnotation = nil;
    }
    [self viewDidLoad];
}

#pragma mark -
#pragma mark CPTScatterPlot delegate method

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if (self.symbolTextAnnotation) {
        [self.graph.plotAreaFrame.plotArea removeAllAnnotations];
        //[self.symbolTextAnnotation release];
        self.symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPTColor colorWithComponentRed:0.0f green:.52 blue:.68 alpha:1];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Futura";
    
    // Determine point of symbol in plot coordinates
    NSArray* anchorPoint;
    NSNumber* y;
    NSNumber* x;
    //NSLog(@"Actual data: %@",[self.actualDataForPlot description]);
    if ([plot.identifier isEqual:@"Actual Hours"] ||
        [plot.identifier isEqual:@"Actual Tallies"] ||
        [plot.identifier isEqual:@"Score"])  
    {
        x = [[self.actualDataForPlot objectAtIndex:index] valueForKey:@"xActualPoint"];
        y = [[self.actualDataForPlot objectAtIndex:index] valueForKey:@"yActualPoint"];
        //NSLog(@"actual y is: %@:",[y description]);
        anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    }
    else
    {
        x = [[self.goalDataForPlot objectAtIndex:index] valueForKey:@"xGoalPoint"];
        y = [[self.goalDataForPlot objectAtIndex:index] valueForKey:@"yGoalPoint"];
        //NSLog(@"goal y is: %@:",[y description]);
        anchorPoint = [NSArray arrayWithObjects:x, y, nil];
    }
    // Add annotation
    // First make a string for the y value
    NSString* annotationString;
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) {
        int minutes = [y floatValue]*60;
        int hours = (minutes - (minutes%60))/60; //subtract the number of extra minutes from the total to give a number like 60 or 120, and then divide by 60 to determine how many hours
        minutes = minutes - (hours*60);
        //NSLog(@"Minutes is: %d, and hours is: %d",minutes,hours);
        annotationString = [NSString stringWithFormat:@"%d:%02d",hours,minutes];
    }
    else
    {
        annotationString =[NSString stringWithFormat:@"%d",[y intValue]];
    }
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:annotationString style:hitAnnotationTextStyle] autorelease];
    self.symbolTextAnnotation = [[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:self.graph.defaultPlotSpace anchorPlotPoint:anchorPoint] autorelease];
    self.symbolTextAnnotation.contentLayer = textLayer;
    self.symbolTextAnnotation.displacement = CGPointMake(0.0f, 20.0f);
    [self.graph.plotAreaFrame.plotArea addAnnotation:self.symbolTextAnnotation];   
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc 
{
	[_actualDataForPlot release];
    _actualDataForPlot = nil;
    [_goalDataForPlot release];
    _goalDataForPlot = nil;
    [_axisLabelStrings release];
    _axisLabelStrings = nil;
    [_indicatorDoc release];
    _indicatorDoc = nil;
    [super dealloc];
    
}


@end
