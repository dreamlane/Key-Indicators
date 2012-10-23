//
//  ChartDetailView.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 2/17/12.
//  Copyright (c) 2012 Blank Sketch Studios LLC. All rights reserved.
//
//
// NOTE: Pass "all" to this object's category field to get all key indicators

#import "ChartDetailView.h"

@implementation ChartDetailView

@synthesize chart;
@synthesize category;
@synthesize dateKey;
@synthesize timerDocs;
@synthesize dateRanges;
@synthesize dateRangePickerSheet;
@synthesize totalTimeLabel;

NSString* tempDateKey;
#define kDateRangePickerSheet 1
#define allCategoriesKey @"AllCategoriesBreakdown"

/*
 * Takes an array of DateRange generated keys, and then sorts them in ascending order
 * NOTE, DateRange should have sorting functionality added
 */
-(NSMutableArray*)orderKeys:(NSMutableArray*) keysArray
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSMutableArray* sortedWeeksArray = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray* sortedMonthsArray = [NSMutableArray arrayWithCapacity:1];
    for (NSString* key in keysArray) {
        //get the start date
        NSDate* date = [fmt dateFromString:[key substringToIndex:(19)]];
        if ([DateRange isWeekKey:key]) {
            [sortedWeeksArray addObject:date];
        }
        else
            [sortedMonthsArray addObject:date];
    }
    [fmt release];
    //sort the array of dates
    [sortedWeeksArray sortUsingSelector:@selector(compare:)];
    sortedWeeksArray = (NSMutableArray*)[[sortedWeeksArray reverseObjectEnumerator] allObjects];
    [sortedMonthsArray sortUsingSelector:@selector(compare:)];
    sortedMonthsArray = (NSMutableArray*)[[sortedMonthsArray reverseObjectEnumerator] allObjects];
    //NSLog(@"array is now sorted: %@",[sortedArray description]);
    //return the dates to string form
    DateRange* keyRange;
    //Begin the list with the all values key
    NSMutableArray* sortedKeyArray = [NSMutableArray arrayWithCapacity:[sortedWeeksArray count]+[sortedMonthsArray count]];
    [sortedKeyArray addObject:@"All Time"];
    for (NSDate* date in sortedMonthsArray) {
        //add a month to the start dates
        keyRange = [DateRange monthContainingDate:date];
        NSString* key = [DateRange keyFromDateRange:keyRange];
        [sortedKeyArray addObject:key];
    }
    for (NSDate* date in sortedWeeksArray) {
        keyRange = [DateRange weekContainingDate:date];
        NSString* key = [DateRange keyFromDateRange:keyRange];
        [sortedKeyArray addObject:key];
    }

    
    //NSLog(@"Sorted key Array: %@",[sortedKeyArray description]);    
    return sortedKeyArray;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([category isEqualToString:allCategoriesKey])
    {
        self.title = @"Categories";
    }
    else
        self.title = category;
    self.dateRanges = [NSMutableArray arrayWithCapacity:1];
    // Load all of the timer docs for the category
    self.timerDocs = [NSMutableArray arrayWithCapacity:1];
    for (NSString* key in [IndicatorDatabase sharedDatabase].indicatorDocs)
    {
        IndicatorDoc* doc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:key];
        if ([doc.data.type isEqualToString:@"Timer"] && 
            ([doc.data.category isEqualToString:self.category] || [self.category isEqualToString:allCategoriesKey])) // Make sure it's a timer and it's in a pertinent category, or this is a categorical breakdown
        {    
            [self.timerDocs addObject:doc]; // Add it to the working docs array
        }
    }
    // Get date ranges
    for (IndicatorDoc* doc in self.timerDocs)
    {
        for (NSString* dateRangeKey in [doc.data.periodValues allKeys]) {
            if (![self.dateRanges containsObject:dateRangeKey])
            {
                [self.dateRanges addObject:dateRangeKey];
            }
        }
    }
    // Now we have all of the date range keys
    
    // Sort them, with months appearing before weeks
    self.dateRanges = [self orderKeys:self.dateRanges];
    CGRect frame = CGRectMake(10, 15, 300, 300); // Set the chart's size and position
    self.chart = [[[BNPieChart alloc] initWithFrame:frame] autorelease];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Determine the datekey to use
    tempDateKey = nil;
    if  (self.dateKey == nil)
    {
        // If no dateKey is set, give the current date as the key
        self.dateKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
    }
    // Use this boolean to ensure that the chart is not empty
    BOOL chartHasSlice = NO;
    // Calculate the total time
    float totalTime = 0.0f;
    if ([dateKey isEqualToString:@"All Time"]) {
        for (IndicatorDoc* doc in self.timerDocs) {
            for (NSString* key in doc.data.periodValues)
            {
                //NSLog(@"Adding Time");
                // add it's time to the total time to get the denominator for our slice portion calculations
                // Just get the weeks
                if ([DateRange isWeekKey:key]) {
                    totalTime += [[doc.data.periodValues objectForKey:key] floatValue];
                }
            }
        }
    }
    else
    {
        for (IndicatorDoc* doc in self.timerDocs) {
                // add it's time to the total time to get the denominator for our slice portion calculations
                totalTime += [[doc.data.periodValues objectForKey:self.dateKey] floatValue];
        }
    }
    //NSLog(@"total Time : %1.2f",totalTime);
    
    // Set the total time label
    int totalMinutes = totalTime*60;
    int totalHours = totalMinutes/60;
    [self.totalTimeLabel setText:[NSString stringWithFormat:@"%d:%02d",totalHours,totalMinutes%60]];
    // ----Config the chart----

    [self.chart reset];
    [self.chart removeFromSuperview];
    // Get the timer docs and calculate their portions
    if ([self.category isEqualToString:allCategoriesKey])  // A categorical breakdown
    {
        if ([dateKey isEqualToString:@"All Time"]) 
        {
            for (NSString* currentCategory in [[IndicatorDatabase sharedDatabase] categories])
            {
                float time = 0.0f;
                for (IndicatorDoc* doc in self.timerDocs)
                {
                    if ([doc.data.category isEqualToString:currentCategory]) 
                    {
                        for (NSString* key in doc.data.periodValues)
                        {
                            if ([DateRange isWeekKey:key]) 
                            {
                                time += [[doc.data.periodValues objectForKey:key] floatValue];
                            }
                        }
                    }
                }
                    // create a slice for it if the time is not 0
                if (time != 0.0f) 
                {  // NOTE: an epsilon value could be useful here
                    if ([currentCategory length] > 10) 
                    {
                        [chart addSlicePortion:time/totalTime withName:[NSString stringWithFormat:@"%@...",[currentCategory substringToIndex: 9]]];
                    }
                    else
                        [chart addSlicePortion:time/totalTime withName:currentCategory];
                    chartHasSlice = YES; // Record that we have at least one slice
                }
            }
            
        }
        else
        {
            for (NSString* currentCategory in [[IndicatorDatabase sharedDatabase] categories])
            {
                float time = 0.0f;
                for (IndicatorDoc* doc in self.timerDocs)
                {
                    if ([doc.data.category isEqualToString:currentCategory]) {
                        time += [[doc.data.periodValues objectForKey:self.dateKey] floatValue];
                    }
                }
                // create a slice for it if the time is not 0
                if (time != 0.0f) 
                {  // NOTE: an epsilon value could be useful here
                    if ([currentCategory length] > 10) 
                    {
                        [chart addSlicePortion:time/totalTime withName:[NSString stringWithFormat:@"%@...",[currentCategory substringToIndex: 9]]];
                    }
                    else
                        [chart addSlicePortion:time/totalTime withName:currentCategory];
                    chartHasSlice = YES; // Record that we have at least one slice
                }
            }
        }

    }
    else //An in-category breakdown
    {
        if ([dateKey isEqualToString:@"All Time"]) 
        {
            for (IndicatorDoc* doc in self.timerDocs)
            {
                float time = 0.0f;
                for (NSString* key in doc.data.periodValues)
                {
                    if ([DateRange isWeekKey:key]) {
                        time += [[doc.data.periodValues objectForKey:key] floatValue];
                    }
                }
                // create a slice for it if the time is not 0
                if (time != 0.0f) {  // NOTE: an epsilon value could be useful here
                    if ([doc.data.title length] > 10) {
                        [chart addSlicePortion:time/totalTime withName:[NSString stringWithFormat:@"%@...",[doc.data.title substringToIndex: 9]]];
                    }
                    else
                        [chart addSlicePortion:time/totalTime withName:doc.data.title];
                    chartHasSlice = YES; // Record that we have at least one slice
                }
            }

        }
        else
        {
            for (IndicatorDoc* doc in self.timerDocs)
            {
                float time = [[doc.data.periodValues objectForKey:self.dateKey] floatValue];
                // create a slice for it if the time is not 0
                if (time != 0.0f) {  // NOTE: an epsilon value could be useful here
                    if ([doc.data.title length] > 10) {
                        [chart addSlicePortion:time/totalTime withName:[NSString stringWithFormat:@"%@...",[doc.data.title substringToIndex: 9]]];
                    }
                    else
                        [chart addSlicePortion:time/totalTime withName:doc.data.title];
                    chartHasSlice = YES; // Record that we have at least one slice
                }
            }
        }
    }
    // Add the chart to the view if the chart has a slice
    if (chartHasSlice) {
        [self.view addSubview:self.chart];
    }
    else {
        //Handle no chart here
    }
    // Set up the button for date range picking
    UIButton* changeDateRangeButton = [[UIButton alloc] initWithFrame:CGRectMake(72, 310, 175, 30)];
    [changeDateRangeButton.titleLabel setFont:[UIFont fontWithName:@"Futura" size:17.0f]];
    [changeDateRangeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.52f blue:0.68f alpha:1] forState:UIControlStateNormal];
    if ([dateKey isEqualToString:@"All Time"])
    {
        [changeDateRangeButton setTitle:dateKey forState:UIControlStateNormal];
    }
    else
    {
        if ([DateRange isWeekKey:dateKey]) {
            [changeDateRangeButton setTitle:[NSString stringWithFormat:@"Week of: %@",[DateRange periodLabelWithKey:dateKey]]
                                   forState:UIControlStateNormal];   
        }
        else {
            [changeDateRangeButton setTitle:[NSString stringWithFormat:@"Month of: %@",[DateRange periodLabelWithKey:dateKey]]
                                   forState:UIControlStateNormal];
        }
    }
    [changeDateRangeButton setBackgroundImage:[UIImage imageNamed:@"largeButton.png"] forState:UIControlStateNormal]; 
    
    //Set up the buttons call back function
    [changeDateRangeButton addTarget:self action:@selector(changeDateRangeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeDateRangeButton];
    [self.view bringSubviewToFront:changeDateRangeButton];
    [changeDateRangeButton release];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
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

#pragma mark - Button Callback(s)

-(void)changeDateRangeButtonTapped
{
    // ---Create a picker view that allows selection of date ranges available from the given data---
    
    // Make the UIPickerView
    self.dateRangePickerSheet = [[UIActionSheet alloc] initWithTitle:@"Select Date Range" 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [dateRangePickerSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.tag = kDateRangePickerSheet;
    //select the correct row for default
    if ([dateKey isEqualToString:@"All Time"]) {
        //[pickerView selectRow:0 inComponent:0 animated:NO];
    }
    else
        [pickerView selectRow:[dateRanges indexOfObject:dateKey] inComponent:0 animated:NO];
    [dateRangePickerSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor darkGrayColor];
    [closeButton addTarget:self action:@selector(dismissDateRangePickerSheet) forControlEvents:UIControlEventValueChanged];
    [dateRangePickerSheet addSubview:closeButton];
    [closeButton release];
    [dateRangePickerSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [dateRangePickerSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Set the temporary date key
    tempDateKey = [dateRanges objectAtIndex:row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.dateRanges count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString* datePickerKey = [dateRanges objectAtIndex:row];
    if ([datePickerKey isEqualToString:@"All Time"])
    {
        return datePickerKey;
    }
    if ([DateRange isWeekKey:datePickerKey]) {
        return [NSString stringWithFormat:@"Week of: %@",[DateRange periodLabelWithKey:datePickerKey]];
    }
    else
        return [NSString stringWithFormat:@"Month of: %@",[DateRange periodLabelWithKey:datePickerKey]];
}

#pragma mark - Dismisall Callbacks
-(void)dismissDateRangePickerSheet
{
    [self.dateRangePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
    //SAVE DATA
    //put up the loading screen
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //set the date-key, if the date was picked
    if (tempDateKey != nil)
    {
        self.dateKey = tempDateKey;
    }
    //refresh the view
    [self performSelector:@selector(viewWillAppear:) withObject:nil afterDelay:0.01];
}
@end
