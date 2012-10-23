//
//  IndicatorDetailView.m
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import "IndicatorDetailView.h"

@implementation IndicatorDetailView

//IBOutlets
@synthesize monthProgressView = _monthProgressView;
@synthesize weekProgressView = _weekProgressView;
@synthesize widgetButton = _widgetButton;
@synthesize addMonthValueButton = _addMonthValueButton;
@synthesize addWeekValueButton = _addWeekValueButton;
@synthesize goalMonthButton = _goalMonthButton;
@synthesize goalWeekButton = _goalWeekButton;
@synthesize categorySelectorButton = _categorySelectorButton;
@synthesize priorityButton = _priorityButton;
@synthesize undoButton = _undoButton;
@synthesize redoButton = _redoButton;
@synthesize undoLabel = _undoLabel;
@synthesize redoLabel = _redoLabel;
@synthesize allTimeLabel;

//Action Sheets
@synthesize priorityPickerActionSheet = _priorityPickerActionSheet;
@synthesize categoryPickerActionSheet = _categoryPickerActionSheet;
@synthesize addHoursPickerActionSheet = _addHoursPickerActionSheet;
@synthesize goalPickerActionSheet = _goalPickerActionSheet;
@synthesize datePicker = _datePicker;

//Data
@synthesize indicatorDoc = _indicatorDoc;
@synthesize priorityPickerArray = _priorityPickerArray;

//Pickers
#define kPriorityPickerView 0 //Used as priority picker view's tag field
#define kCategoryPickerView 1 //Used as category picker view's tag field
#define kWeekGoalPickerView 2 //Used to tag the picker view when the week goal button is tapped
#define kMonthGoalPickerView 3 //Used to tag the picker view when the MONTH goal button is tapped
//AlertViews
#define kTrashAlertVeiw 0 //Used as delete/deactivate alertview tag field
#define kAddCategoryAlertView 1 //Used as add category alertview tag field
#define kSaveTimeAlertView 2 //Used as a tag for the alert view that shows when saving tracked time
#define kWeekGoalTallyAlertView 3 //Used to tag the alert view for setting tally weekly goal
#define kMonthGoalTallyAlertView 4 //Used to tag the alert view for setting tally monthly goal
#define kRenameAlertView 5 //Used to tag the alertview that shows up the first time a indicator's details are view (on creation), and whenever the user decided to rename the indicator
#define kOptionsAlertView 6 //Used to tag the options alertview that is presented when a user selects the edit button at the top right of the screen.
#define kAddTalliesAlertView 7 //Used to tag the alertview that shows when a user taps one of the "Actual: xxxx" buttons on a tally indicator

-(void)viewWillAppear:(BOOL)animated
{    
    //NSLog(@"IndicatroDetailView viewWillAppear");
    if (self.indicatorDoc.data.isActive)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //NSLog(@"viewWillAppear active indicator");
        //Add an edit button to the top bar on the right
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                                   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                   target:self action:@selector(showOptionsMenu)] autorelease];
        // Set the view title to the name of the indicator
        self.title = self.indicatorDoc.data.title;
        //set up the timer type indicators view
        if (([self.indicatorDoc.data.type isEqualToString:@"Timer"])) 
        {
            [self initTimerView];
        }
        //set up the tally view
        else if (([self.indicatorDoc.data.type isEqualToString:@"Tally"]))
        {
            [self initTallyView];		
        }
        
        // Set the category button text
        [self.categorySelectorButton setTitle:self.indicatorDoc.data.category forState:UIControlStateNormal];
        
        //initialize the array for Priority picking
        self.priorityPickerArray = [NSArray arrayWithObjects:@"Very High",@"High",@"Average",@"Low",@"Very Low", nil];
        //set up the NSTimer that will refresh the view once per second, thereby making the widgetButton's text reflect the ammount of tracked time
        refreshtimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
        [super viewWillAppear:animated];
        //NSLog(@"ViewWillAppearEND");
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];    
}//END ViewDidLoad

-(void)viewWillDisappear:(BOOL)animated{
	if (self.indicatorDoc.data.isActive) { //make sure it was active in the first place
        [refreshtimer invalidate];
        refreshtimer = nil;
    }

	//NSLog(@"viewWillDisappear");
}

#pragma mark - View Inits

- (void)initTimerView
{
    //NSLog(@"initing timer view");
    NSString* monthRangeKey = [DateRange keyFromDateRange:[DateRange currentMonth]]; // Used to determine which goal and weight values to display
    NSString* weekRangeKey = [DateRange keyFromDateRange:[DateRange currentWeek]]; // Used to determine which goal and weight 
    //set up the labels for goals and actuals
    int weekMinutes = [self.indicatorDoc periodValueWithKey:weekRangeKey]*60;
    int monthMinutes = [self.indicatorDoc periodValueWithKey:monthRangeKey]*60;
    int weekHours = ((weekMinutes - (weekMinutes%60)) / 60);
    int monthHours = ((monthMinutes - (monthMinutes%60))/60);
    //Label the buttons
    [self.addMonthValueButton setTitle:[NSString stringWithFormat:@"Actual: %d:%02d",monthHours,monthMinutes%60] forState:UIControlStateNormal];
    [self.addWeekValueButton setTitle:[NSString stringWithFormat:@"Actual: %d:%02d",weekHours,weekMinutes%60] forState:UIControlStateNormal];
    
    //Set up the progress bars
    if (self.indicatorDoc.data.isInverseGoal)
    {
        //NSLog(@"Is inverse goal, setting up progress bar");
        self.monthProgressView.progress = (1-(1/([[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue])*[self.indicatorDoc periodValueWithKey:monthRangeKey])); //Drain the bar, intsead of filling it: 1-(1/goal)*actual
        self.weekProgressView.progress = (1-(1/([[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue])*[self.indicatorDoc periodValueWithKey:weekRangeKey])); //Drain the bar, intsead of filling it: 1-(1/goal)*actual
    }
    else if (!self.indicatorDoc.data.isInverseGoal)
    {
        //NSLog(@"Is not inverse goal, setting up progress bar");
        self.monthProgressView.progress = ([self.indicatorDoc periodValueWithKey:monthRangeKey]/[[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue]);
        self.weekProgressView.progress = ([self.indicatorDoc periodValueWithKey:weekRangeKey]/[[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue]);
    }
    //These following assignments are here to tell the progress bars to be full and red if and only if the goals are 0
    self.monthProgressView.goal = [[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue];
    self.weekProgressView.goal = [[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue];
    [self.monthProgressView setNeedsDisplay];
    [self.weekProgressView setNeedsDisplay];
    //Set up the widget button
    if (self.indicatorDoc.data.isTrackingTime) {
        int trackedMinutes = [self getInterval];
        int trackedHours = ((trackedMinutes - (trackedMinutes%60))/60);
        [self.widgetButton setTitle:[NSString stringWithFormat:@"Save Time: %d:%02d",trackedHours,trackedMinutes%60] forState:UIControlStateNormal];
    }
    else {
        [self.widgetButton setTitle:@"Start Timer" forState:UIControlStateNormal];
    }
    //set up the priority button view
    if (fabsf(self.indicatorDoc.data.weightBase - .9) < .001) {
        [self.priorityButton setTitle:@"Priority: Very High" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .7) < .001) {
        [self.priorityButton setTitle:@"Priority: High" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .5) < .001) {
        [self.priorityButton setTitle:@"Priority: Average" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .3) < .001) {
        [self.priorityButton setTitle:@"Priority: Low" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .1) < .001) {
        [self.priorityButton setTitle:@"Priority: Very Low" forState:UIControlStateNormal];
    }
    else
    {
        //NSLog(@"no priority set, weight is: %1.2f",self.indicatorDoc.data.weightBase);
        //NSLog(@"Setting priority to average");
        self.indicatorDoc.data.weightBase = 0.5f;
        [self.indicatorDoc saveData];
    }
    //Set up the goal value views
    int weekGoalMinutes;
    int monthGoalMinutes;
    if (self.indicatorDoc.data.periodGoals == nil) { //init if needed and set the goal to 0
        self.indicatorDoc.data.periodGoals = [NSMutableDictionary dictionaryWithCapacity:2];
        [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:0.0f] forKey:monthRangeKey];
        [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:0.0f] forKey:weekRangeKey];
    }
    weekGoalMinutes = [[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue]*60;
    monthGoalMinutes = [[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue]*60;
    int weekGoalHours = ((weekGoalMinutes - (weekGoalMinutes%60))/60);
    int monthGoalHours = ((monthGoalMinutes - (monthGoalMinutes%60))/60);
    [self.goalWeekButton setTitle:[NSString stringWithFormat:@"Goal: %d:%02d",weekGoalHours,weekGoalMinutes%60] forState:UIControlStateNormal];
    [self.goalMonthButton setTitle:[NSString stringWithFormat:@"Goal: %d:%02d", monthGoalHours,monthGoalMinutes%60] forState:UIControlStateNormal];
    //setup the undo/redo buttons
    //Make them all hidden initially
    [self.undoButton setHidden:YES];
    [self.undoButton setEnabled:NO];
    [self.redoButton setHidden:YES];
    [self.redoButton setEnabled:NO];
    [self.redoLabel setHidden:YES];
    [self.undoLabel setHidden:YES];
    if (lastValueAdded != 0) {
        [self.undoButton setHidden:NO];
        [self.undoButton setEnabled:YES];
        [self.redoButton setHidden:YES];
        [self.redoButton setEnabled:NO];
        [self.redoLabel setHidden:YES];
        [self.undoLabel setHidden:NO];
        //set up the label
        int hoursAdded = ((lastValueAdded - (lastValueAdded%60))/60);
        [self.undoLabel setText:[NSString stringWithFormat:@"Undo: %d:%02d",hoursAdded,lastValueAdded%60]];
    }
    else if (lastValueRemoved != 0) {
        [self.undoButton setHidden:YES];
        [self.undoButton setEnabled:NO];
        [self.redoButton setHidden:NO];
        [self.redoButton setEnabled:YES];
        [self.redoLabel setHidden:NO];
        [self.undoLabel setHidden:YES];
        //set up the label
        int hoursAdded = ((lastValueRemoved - (lastValueRemoved%60))/60);
        [self.redoLabel setText:[NSString stringWithFormat:@"Redo: %d:%02d",hoursAdded,lastValueRemoved%60]];
    }
    
    // Set the all Time Label
    float allTime = 0.0f;
    for (NSString* key in self.indicatorDoc.data.periodValues)
    {
        if ([DateRange isWeekKey:key]) {
            allTime += [[self.indicatorDoc.data.periodValues objectForKey:key] floatValue];
        }
    }
    allTime*=60.0f;
    int allTimeHours = ((allTime - ((int)allTime%60))/60);
    [self.allTimeLabel setText:[NSString stringWithFormat:@"%d:%02d",allTimeHours,(int)allTime%60]];
    //close the loading screen
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)initTallyView
{
    NSString* monthRangeKey = [DateRange keyFromDateRange:[DateRange currentMonth]]; // Used to determine which goal and weight values to display
    NSString* weekRangeKey = [DateRange keyFromDateRange:[DateRange currentWeek]]; // Used to determine which goal and weight 
    [self.addMonthValueButton setTitle:[NSString stringWithFormat:@"Actual: %d",(int)[self.indicatorDoc periodValueWithKey:monthRangeKey]] forState:UIControlStateNormal];
    [self.addWeekValueButton setTitle:[NSString stringWithFormat:@"Actual: %d",(int)[self.indicatorDoc periodValueWithKey:weekRangeKey]] forState:UIControlStateNormal];
    [self.widgetButton setTitle:@"+1" forState:UIControlStateNormal];
    
    //Set up the goal views
    if (self.indicatorDoc.data.periodGoals == nil) { //init if needed and set the goal to 0
        self.indicatorDoc.data.periodGoals = [NSMutableDictionary dictionaryWithCapacity:2];
        [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:0.0f] forKey:monthRangeKey];
        [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:0.0f] forKey:weekRangeKey];
    }
    //set up the priority button view
    if (fabsf(self.indicatorDoc.data.weightBase - .9) < .001) {
        [self.priorityButton setTitle:@"Priority: Very High" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .7) < .001) {
        [self.priorityButton setTitle:@"Priority: High" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .5) < .001) {
        [self.priorityButton setTitle:@"Priority: Average" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .3) < .001) {
        [self.priorityButton setTitle:@"Priority: Low" forState:UIControlStateNormal];
    }
    else if (fabsf(self.indicatorDoc.data.weightBase - .1) < .001) {
        [self.priorityButton setTitle:@"Priority: Very Low" forState:UIControlStateNormal];
    }
    else
    {
        //NSLog(@"no priority set, weight is: %1.2f",self.indicatorDoc.data.weightBase);
        //NSLog(@"Setting priority to average");
        self.indicatorDoc.data.weightBase = 0.5f;
        [self.indicatorDoc saveData];
    }
    //Set up the progress bars
    if (self.indicatorDoc.data.isInverseGoal)
    {
        //NSLog(@"Is inverse goal, setting up progress bar");
        self.monthProgressView.progress = (1-(1/([[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue])*[self.indicatorDoc periodValueWithKey:monthRangeKey])); //Drain the bar, intsead of filling it: 1-(1/goal)*actual
        self.weekProgressView.progress = (1-(1/([[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue])*[self.indicatorDoc periodValueWithKey:weekRangeKey])); //Drain the bar, intsead of filling it: 1-(1/goal)*actual
    }
    else if (!self.indicatorDoc.data.isInverseGoal)
    {
        //NSLog(@"Is not inverse goal, setting up progress bar");
        self.monthProgressView.progress = ([self.indicatorDoc periodValueWithKey:monthRangeKey]/[[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue]);
        self.weekProgressView.progress = ([self.indicatorDoc periodValueWithKey:weekRangeKey]/[[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue]);
    }
    //These following assignments are here to tell the progress bars to be full and red if and only if the goals are 0
    self.monthProgressView.goal = [[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] floatValue];
    self.weekProgressView.goal = [[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] floatValue];
    [self.monthProgressView setNeedsDisplay];
    [self.weekProgressView setNeedsDisplay];
    [self.goalWeekButton setTitle:[NSString stringWithFormat:@"Goal: %d",[[self.indicatorDoc.data.periodGoals objectForKey:weekRangeKey] intValue]] forState:UIControlStateNormal];
    [self.goalMonthButton setTitle:[NSString stringWithFormat:@"Goal: %d",[[self.indicatorDoc.data.periodGoals objectForKey:monthRangeKey] intValue]] forState:UIControlStateNormal];
    //setup the undo/redo buttons
    //Make them all hidden initially
    [self.undoButton setHidden:YES];
    [self.undoButton setEnabled:NO];
    [self.redoButton setHidden:YES];
    [self.redoButton setEnabled:NO];
    [self.redoLabel setHidden:YES];
    [self.undoLabel setHidden:YES];
    if (lastValueAdded != 0) {
        [self.undoButton setHidden:NO];
        [self.undoButton setEnabled:YES];
        [self.redoButton setHidden:YES];
        [self.redoButton setEnabled:NO];
        [self.redoLabel setHidden:YES];
        [self.undoLabel setHidden:NO];
        //set up the label
        [self.undoLabel setText:[NSString stringWithFormat:@"Undo: %d",lastValueAdded]];
    }
    else if (lastValueRemoved != 0) {
        [self.undoButton setHidden:YES];
        [self.undoButton setEnabled:NO];
        [self.redoButton setHidden:NO];
        [self.redoButton setEnabled:YES];
        [self.redoLabel setHidden:NO];
        [self.undoLabel setHidden:YES];
        //set up the label
        [self.redoLabel setText:[NSString stringWithFormat:@"Redo: %d",lastValueRemoved]];
    }
    
    // Set the All Time Label
    int allTime = 0;
    for (NSString* key in self.indicatorDoc.data.periodValues)
    {
        if ([DateRange isWeekKey:key])
        {
            allTime += [[self.indicatorDoc.data.periodValues objectForKey:key] intValue];
        }
    }
    [self.allTimeLabel setText:[NSString stringWithFormat:@"%d",allTime]];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark  - Interface Actions
/*
 * This method called evertime the undoButton is tapped. Only can undo the last entry
 */
-(IBAction)undoButtonTapped:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //remove the last value added, by adding it's additive inverse
    float valueToRemove;
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) {
        valueToRemove = lastValueAdded/60.0f*-1.0f;
        //set the redo value to the value undone
        lastValueRemoved = valueToRemove*60.0*-1.0f;
    }
    else {
        valueToRemove = lastValueAdded*-1.0f;
        lastValueRemoved = valueToRemove*-1.0f;
    }

    NSString* dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //check for an entry that already exists
    if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = curVal + valueToRemove;
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else //THIS SHOULD NEVER OCCUR, because by nature, undoing means something should be there... edge cases like overnight on saturday or the last day of month could cause logic bugs here.
    {
        //make sure that the dictionary is initalized
        if (self.indicatorDoc.data.dailyActuals == nil) {
            self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        //make a new entry for the day
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:valueToRemove] forKey:dateKey];
    }
    
    //set the undo value to 0
    lastValueAdded = 0;
    //save everything
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
}
/*
 * This method called evertime the redoButton is tapped. Only can redo the recently undone entry
 */
-(IBAction)redoButtonTapped:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //remove the last value added, by adding it's additive inverse
    float valueToRedo;
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) {
        valueToRedo = lastValueRemoved/60.0f;
        //set the redo value to the value undone
        lastValueAdded = valueToRedo*60;
    }
    else {
        valueToRedo = lastValueRemoved;
        //set the redo value to the value undone
        lastValueAdded = valueToRedo;
    }

    NSString* dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //check for an entry that already exists
    if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = curVal + valueToRedo;
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else //THIS SHOULD NEVER OCCUR, because by nature, undoing means something should be there... edge cases like overnight on saturday or the last day of month could cause logic bugs here.
    {
        //make sure that the dictionary is initalized
        if (self.indicatorDoc.data.dailyActuals == nil) {
            self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        //make a new entry for the day
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:lastValueRemoved] forKey:dateKey];
    }
   
    //set the undo value to 0
    lastValueRemoved = 0;
    //save everything
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
}

/*
 * This method is called only when an indicator that has been deactivated has it's reactivate button pressed
 */
-(IBAction)reactivateTapped:(id)sender
{
    //put up the loading screen
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //reactivate the indicator
    self.indicatorDoc.data.isActive = YES;
    //save the data with a saving screen
    //Save indicator data
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    [self.indicatorDoc saveData];
    [[IndicatorDatabase sharedDatabase] update];
    //pop back out to the inidcatorlistview
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 * The options menu is a alertview with several buttons allowing users to perform operations
 * Generally these ooptions will be: Rename, Invert Goal, Deactivate.
 * This is called only when the user presses the edit button at the top right of the indicatorDetailView
 * TO ADD: Remove Hours/Tallies?
 */
-(void)showOptionsMenu
{
    if (_indicatorDoc.data.isInverseGoal) {
        UIAlertView* optionsAlertView = [[UIAlertView alloc] initWithTitle:@"Indicator Edit Options" 
                                                                   message:@"Choose an action" 
                                                                  delegate:self 
                                                         cancelButtonTitle:@"Cancel" 
                                                         otherButtonTitles:@"Rename Indicator", @"Make Standard",@"Deactivate", nil];
        optionsAlertView.tag = kOptionsAlertView;
        [optionsAlertView show];
        [optionsAlertView release];
    }
    else
    {
        //make a new UI Alert View with all of the necessary buttons for a standard indicator
        UIAlertView* optionsAlertView = [[UIAlertView alloc] initWithTitle:@"Indicator Edit Options" 
                                                                   message:@"Choose an action" 
                                                                  delegate:self 
                                                         cancelButtonTitle:@"Cancel" 
                                                         otherButtonTitles:@"Rename Indicator", @"Make Inverse",@"Deactivate", nil];
        optionsAlertView.tag = kOptionsAlertView;
        [optionsAlertView show];
        [optionsAlertView release];
    }
}


/*
 * Called when the priority selection button is tapped, no duh comment
 */
- (IBAction)priorityButtonTapped:(id)sender
{
    //Code adapted from StackOverflow: http://stackoverflow.com/questions/1262574/add-uipickerview-a-button-in-action-sheet-how
    //
    _priorityPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Priority" 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [_priorityPickerActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.tag = kPriorityPickerView;
    //select the correct row for default
    if ([self.priorityButton.titleLabel.text isEqualToString:@"Priority: Very High"]) {
        [pickerView selectRow:0 inComponent:0 animated:NO];
    }
    else if ([self.priorityButton.titleLabel.text isEqualToString:@"Priority: High"]) {
        [pickerView selectRow:1 inComponent:0 animated:NO];
    }
    else if ([self.priorityButton.titleLabel.text isEqualToString:@"Priority: Average"]) {
        [pickerView selectRow:2 inComponent:0 animated:NO];
    }
    else if ([self.priorityButton.titleLabel.text isEqualToString:@"Priority: Low"]) {
        [pickerView selectRow:3 inComponent:0 animated:NO];
    }
    else {
        [pickerView selectRow:4 inComponent:0 animated:NO];
    }
    
    [_priorityPickerActionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor darkGrayColor];
    [closeButton addTarget:self action:@selector(dismissPriorityActionSheet) forControlEvents:UIControlEventValueChanged];
    [_priorityPickerActionSheet addSubview:closeButton];
    [closeButton release];
    
    [_priorityPickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [_priorityPickerActionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    //
}

/* OLD, kept for reference
- (IBAction)periodGoalFieldValueChanged:(id)sender
{
	//get the changed value
	float inputValue;
	//put it back out correctly
    if([_indicatorDoc.data.type isEqualToString:@"Tally"])
    {
        inputValue = [_periodGoalField.text intValue];
        _periodGoalField.text = [NSString stringWithFormat:@"%1.0f",inputValue];
    }
	if([_indicatorDoc.data.type isEqualToString:@"Timer"])
    {
        inputValue = [_periodGoalField.text floatValue];
        _periodGoalField.text = [NSString stringWithFormat:@"%1.2f",inputValue];
        
    }
    //init the dictionary if needed
    BOOL inited = NO; //use this to determine if the dict should be released or not
	if (_indicatorDoc.data.periodGoals == nil) {
		_indicatorDoc.data.periodGoals = [[NSMutableDictionary alloc] initWithCapacity:1];
        inited = YES;
	}
    NSString* rangeKey; 
    //save the goal to the dictionary based on what the week/month setting is
    if (_indicatorDoc.data.isMonthIndicator)
    {
       rangeKey = [DateRange keyFromDateRange:[DateRange currentMonth]];
    }
    else
    {
        rangeKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
	}
    [_indicatorDoc.data.periodGoals setObject:[NSNumber numberWithFloat:inputValue] forKey:rangeKey];
	[_indicatorDoc saveData];
    if (inited) {
        [_indicatorDoc.data.periodGoals release]; //release the allocated periodGoals
    }
    //recalculate scores
    [_indicatorDoc updateScoreForKey:rangeKey];
	//update the progress bar
    //Recalc the total score
    [[IndicatorDatabase sharedDatabase] updateLifetimeScore];
    [self viewWillAppear:NO];
}	
*/
- (IBAction)widgetButtonTapped:(id)sender
{
	if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) {
		
		if (self.indicatorDoc.data.isTrackingTime) 
        {
			//record the end time and calculate the elapsed hours
			int minutes = [self getInterval];
            //Find out how many hours:minutes were tracked
			int hours = ((minutes - (minutes%60))/60);
			//set the tracking time bool to false and clear the startDate,
			self.indicatorDoc.data.isTrackingTime = NO;
			self.indicatorDoc.data.startDate = nil;

			//make the alert view
            UIAlertView* saveAlertView = [[UIAlertView alloc] initWithTitle:@"Save Tracked Time" 
                                                                    message:[NSString stringWithFormat:@"Save %d:%02d to the %@ indicator?",hours,minutes%60,self.indicatorDoc.data.title] 
                                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
            //set the hours to the value to be added
            self.indicatorDoc.hoursToBeAdded = (float)minutes/60.0f;
            // Tag and show the alert view
            saveAlertView.tag = kSaveTimeAlertView;
            [saveAlertView show];
            [saveAlertView release];
		}
		else { // If the indicator is not currently trackin time
			//record the start time
			self.indicatorDoc.data.startDate = [NSDate date];
			//set the tracking time bool to true
			self.indicatorDoc.data.isTrackingTime = YES;	
            //save the data.. POTENTIAL LAG HERE
            [self.indicatorDoc saveData];
            [[IndicatorDatabase sharedDatabase] update];
            [self viewWillAppear:YES];
		}
	}//End Timer Widget Logic
	
	if ([self.indicatorDoc.data.type isEqualToString:@"Tally"])//Begin Tally widget logic
	{
        //put up the loading screen
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self performSelector:@selector(addOneTally) withObject:nil afterDelay:0];
        //set the undo/redo values appropriately
        lastValueAdded = 1;
        lastValueRemoved = 0;
	}//End Tally Widget Logic   
}//end Widget touched logic

- (IBAction)addValueButtonTapped:(id)sender
{
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"])
    { //NEED TO CONSIDER REMOVAL OF VALUE HERE
        //Make a UIActionSheet for adding hours
        self.addHoursPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Time" 
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        [self.addHoursPickerActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        postDate = NO;
        if (self.datePicker != nil) {
            [self.datePicker release];
            self.datePicker = nil;
        }
        self.datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
        
        //Reset value to be added
        self.indicatorDoc.hoursToBeAdded = 0.0f;
        self.indicatorDoc.minutesToBeAdded = 0.0f;
        
        //add the pickerview as a subview to the actionsheet
        [self.addHoursPickerActionSheet addSubview:_datePicker];
        // Set Up the Save Button
        UISegmentedControl *saveButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
        saveButton.momentary = YES; 
        saveButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        saveButton.segmentedControlStyle = UISegmentedControlStyleBar;
        saveButton.tintColor = [UIColor darkGrayColor];
        [saveButton addTarget:self action:@selector(dismissAddHoursActionSheetWithSave) forControlEvents:UIControlEventValueChanged];
        [self.addHoursPickerActionSheet addSubview:saveButton];
        [saveButton release];
        
        // Set Up the Cancel Button
        UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
        cancelButton.momentary = YES; 
        cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancelButton.tintColor = [UIColor redColor];
        [cancelButton addTarget:self action:@selector(dismissAddHoursActionSheet) forControlEvents:UIControlEventValueChanged];
        [self.addHoursPickerActionSheet addSubview:cancelButton];
        [cancelButton release];
        
        // Set up the date button REMOVE AFTER TESTING!!?
        /*
        UISegmentedControl *dateButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Date"]];
        dateButton.momentary = YES;
        dateButton.frame = CGRectMake(160, 7.0f, 50.0f, 30.0f);
        dateButton.segmentedControlStyle = UISegmentedControlStyleBar;
        dateButton.tintColor = [UIColor darkGrayColor];
        [dateButton addTarget:self action:@selector(showPostDateSelector) forControlEvents:UIControlEventValueChanged];
        [_addHoursPickerActionSheet addSubview:dateButton];
        [dateButton release];
        */
        [self.addHoursPickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
        [self.addHoursPickerActionSheet setBounds:CGRectMake(0, 0, 320, 485)];
    }
    else if ([self.indicatorDoc.data.type isEqualToString:@"Tally"])
    {
        // NEED TO IMPLEMENT - AlertView with date edit button and text field
        UIAlertView* addTalliesAlertView = [[UIAlertView alloc] initWithTitle:@"Add Tallies" 
                                                                      message:@"Enter a number to add" 
                                                                     delegate:self 
                                                            cancelButtonTitle:@"Cancel" 
                                                            otherButtonTitles:@"Save", nil];
        addTalliesAlertView.tag = kAddTalliesAlertView;
        addTalliesAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField* textField = [addTalliesAlertView textFieldAtIndex:0];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [addTalliesAlertView show];
        [addTalliesAlertView release];
    }
}

-(IBAction)categorySelectorButtonTapped:(id)sender
{
    self.categoryPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Category" 
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    [self.categoryPickerActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.tag = kCategoryPickerView;
    //select the correct row for default
    int row = [[IndicatorDatabase sharedDatabase].categories indexOfObject:self.indicatorDoc.data.category];
    [pickerView selectRow:row inComponent:0 animated:NO];
    
    [self.categoryPickerActionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissCategoryActionSheet) forControlEvents:UIControlEventValueChanged];
    [self.categoryPickerActionSheet addSubview:closeButton];
    [closeButton release];
    
    UISegmentedControl *addButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Add Category"]];
    addButton.momentary = YES; 
    addButton.frame = CGRectMake(10, 7.0f, 95.0f, 30.0f);
    addButton.segmentedControlStyle = UISegmentedControlStyleBar;
    addButton.tintColor = [UIColor blackColor];
    [addButton addTarget:self action:@selector(addCategory) forControlEvents:UIControlEventValueChanged];
    [self.categoryPickerActionSheet addSubview:addButton];
    [addButton release];
    
    [self.categoryPickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [self.categoryPickerActionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

-(IBAction)goalWeekButtonTapped:(id)sender
{
    //Reset the goalToSet variable
    goalToSet = 0.0f;
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) 
    {
        //Create the UIAction sheet that will handle goal setting
        //The actionsheet will have a UIPickerView with and hours and minutes column
        self.goalPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Week Goal" 
                                                             delegate:nil 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:nil];
        [self.goalPickerActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(20, 40, 280, 0);
        
        //Create and setup the picker view, the rows and components of the picker view are setup elsewhere (other methods)
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.tag = kWeekGoalPickerView;
        
        //add the view to the action sheet
        [self.goalPickerActionSheet addSubview:pickerView];
        [pickerView release];
        
        //Set up the save/close button
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
        closeButton.momentary = YES; 
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissWeekGoalActionSheetWithSave) forControlEvents:UIControlEventValueChanged];
        [self.goalPickerActionSheet addSubview:closeButton];
        [closeButton release];
        // Set Up the Cancel Button
        UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
        cancelButton.momentary = YES; 
        cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancelButton.tintColor = [UIColor redColor];
        [cancelButton addTarget:self action:@selector(dismissGoalActionSheet) forControlEvents:UIControlEventValueChanged];
        [self.goalPickerActionSheet addSubview:cancelButton];
        [cancelButton release];
        
        //Insert the labels
        //Hours
        UILabel *hoursLabel = [[[UILabel alloc] initWithFrame:CGRectMake(75, 133, 80, 30)] autorelease];
        hoursLabel.text = @"Hours";
        hoursLabel.font = [UIFont boldSystemFontOfSize:20];
        hoursLabel.backgroundColor = [UIColor clearColor];
        hoursLabel.textColor = [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.9f];
        hoursLabel.shadowColor = [UIColor lightGrayColor];
        hoursLabel.shadowOffset = CGSizeMake (0,1);
        [self.goalPickerActionSheet insertSubview:hoursLabel aboveSubview:[_goalPickerActionSheet.subviews objectAtIndex:[_goalPickerActionSheet.subviews count]-1]];
        //Minutes
        UILabel *minsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(198, 133, 80, 30)] autorelease];
        minsLabel.text = @"Mins";
        minsLabel.font = [UIFont boldSystemFontOfSize:20];
        minsLabel.backgroundColor = [UIColor clearColor];
        minsLabel.textColor = [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.9f];
        minsLabel.shadowColor = [UIColor lightGrayColor];
        minsLabel.shadowOffset = CGSizeMake (0,1);
        [self.goalPickerActionSheet insertSubview:minsLabel aboveSubview:[_goalPickerActionSheet.subviews objectAtIndex:[_goalPickerActionSheet.subviews count]-1]];
        
        
        [self.goalPickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        [self.goalPickerActionSheet setBounds:CGRectMake(0,0, 320, 485)];
    }//End Timer logic
    else //BEGIN TALLY LOGIC
    {
        //Make a UIAlertView that has a number pad and a text field
        UIAlertView* setWeekGoalView = [[UIAlertView alloc] initWithTitle:@"Set Week Goal" message:@"Enter a number for this week's Goal" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        setWeekGoalView.alertViewStyle = UIAlertViewStylePlainTextInput; //set it up as a plain alert view style
        UITextField* alertTextField = [setWeekGoalView textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        setWeekGoalView.tag = kWeekGoalTallyAlertView;
        [setWeekGoalView show];
        [setWeekGoalView release];
    }
}

-(IBAction)goalMonthButtonTapped:(id)sender
{
    //Reset the goalToSet variable
    goalToSet = 0.0f;
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"]) 
    {
        //Create the UIAction sheet that will handle goal setting
        //The actionsheet will have a UIPickerView with and hours and minutes column
        self.goalPickerActionSheet = [[UIActionSheet alloc] initWithTitle:@"Set Month Goal" 
                                                             delegate:nil 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:nil];
        [self.goalPickerActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        
        //Create and setup the picker view, the rows and components of the picker view are setup elsewhere (other methods)
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        pickerView.tag = kMonthGoalPickerView;
        //add the view to the action sheet
        [self.goalPickerActionSheet addSubview:pickerView];
        [pickerView release];
        
        ///Set up the save/close button
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]];
        closeButton.momentary = YES; 
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissMonthGoalActionSheetWithSave) forControlEvents:UIControlEventValueChanged];
        [self.goalPickerActionSheet addSubview:closeButton];
        [closeButton release];
        // Set Up the Cancel Button
        UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
        cancelButton.momentary = YES; 
        cancelButton.frame = CGRectMake(10, 7.0f, 50.0f, 30.0f);
        cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
        cancelButton.tintColor = [UIColor redColor];
        [cancelButton addTarget:self action:@selector(dismissGoalActionSheet) forControlEvents:UIControlEventValueChanged];
        [self.goalPickerActionSheet addSubview:cancelButton];
        [cancelButton release];
        
        //Insert the labels
        //Hours
        UILabel *hoursLabel = [[[UILabel alloc] initWithFrame:CGRectMake(75, 133, 80, 30)] autorelease];
        hoursLabel.text = @"Hours";
        hoursLabel.font = [UIFont boldSystemFontOfSize:20];
        hoursLabel.backgroundColor = [UIColor clearColor];
        hoursLabel.textColor = [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.9f];
        hoursLabel.shadowColor = [UIColor lightGrayColor];
        hoursLabel.shadowOffset = CGSizeMake (0,1);
        [self.goalPickerActionSheet insertSubview:hoursLabel aboveSubview:[self.goalPickerActionSheet.subviews objectAtIndex:[self.goalPickerActionSheet.subviews count]-1]];
        //Minutes
        UILabel *minsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(198, 133, 80, 30)] autorelease];
        minsLabel.text = @"Mins";
        minsLabel.font = [UIFont boldSystemFontOfSize:20];
        minsLabel.backgroundColor = [UIColor clearColor];
        minsLabel.textColor = [UIColor colorWithRed:.1f green:.1f blue:.1f alpha:0.9f];
        minsLabel.shadowColor = [UIColor lightGrayColor];
        minsLabel.shadowOffset = CGSizeMake (0,1);
        [self.goalPickerActionSheet insertSubview:minsLabel aboveSubview:[self.goalPickerActionSheet.subviews objectAtIndex:[self.goalPickerActionSheet.subviews count]-1]];
        
        [self.goalPickerActionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        [self.goalPickerActionSheet setBounds:CGRectMake(0,0, 320, 485)];
    } //End Timer Logic
    else //BEGIN TALLY LOGIC
    {
        //Make a UIAlertView that has a number pad and a text field
        UIAlertView* setMonthGoalView = [[UIAlertView alloc] initWithTitle:@"Set Month Goal" message:@"Enter a number for this month's Goal" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        setMonthGoalView.alertViewStyle = UIAlertViewStylePlainTextInput; //set it up as a plain alert view style
        UITextField* alertTextField = [setMonthGoalView textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeNumberPad;
        setMonthGoalView.tag = kMonthGoalTallyAlertView;
        [setMonthGoalView show];
        [setMonthGoalView release];
    }

}
/*
-(IBAction)inversionSwitchFlipped:(id)sender
{
    if (_inversionSwitch.isOn) {
        _indicatorDoc.data.isInverseGoal = YES;
    }
    else {
        _indicatorDoc.data.isInverseGoal = NO;
    }
    //Save the change
    [_indicatorDoc saveData];
    //Reinitialize the view
    [self viewWillAppear:NO];
    
}
*/


/*
 *If a Doc is currently active, then it allows the user to deactivate it, and if the Doc is already deactivated, it allows the user to delete it.
 * IS THIS CODE SUPERFLUOUS?
 */
- (IBAction)showDeleteConfirm:(id)sender
{
    UIAlertView* deleteConfirm; 
    if ([self.indicatorDoc.data.type isEqualToString:@"Category"])
    {
        if (self.indicatorDoc.data.isActive) 
        {
            deleteConfirm = [[UIAlertView alloc] initWithTitle:@"Deactivate Category" 
                                                                    message:@"Would you like to deactivate this category?"
                                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Deactivate", nil];
        }
        else
        {
            deleteConfirm = [[UIAlertView alloc] initWithTitle:@"Delete Category" 
                                                                        message:@"Are you sure you would like to delete this category?"
                                                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        }
    }
    else // If the doc type is Indicator
    {
        if (self.indicatorDoc.data.isActive) 
        {
            deleteConfirm = [[UIAlertView alloc] initWithTitle:@"Deactivate Indicator" 
                                                                    message:@"Would you like to deactivate this indicator?"
                                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Deactivate", nil];

        }
        else
        {
            deleteConfirm = [[UIAlertView alloc] initWithTitle:@"Delete Indicator" 
                                                                    message:@"Are you sure you would like to delete this indicator?"
                                                                   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        }
    }    
    deleteConfirm.tag = kTrashAlertVeiw;
    [deleteConfirm show];
    [deleteConfirm release];
    
}

#pragma mark - AlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Handle the Delete/Deactivate alert view
    if (alertView.tag == kTrashAlertVeiw) 
    {
        if (buttonIndex == 1) 
        {
            if (self.indicatorDoc.data.isActive) 
            {
                //deactivate the the doc
                self.indicatorDoc.data.isActive = NO;
                // if the time was tracking, stop tracking, 
                if (self.indicatorDoc.data.isTrackingTime)
                {
                    self.indicatorDoc.data.isTrackingTime = NO;
                    self.indicatorDoc.data.startDate = nil;
                }
                //save the changes
                 [self.indicatorDoc saveData];
                [[IndicatorDatabase sharedDatabase] update];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                //delete the category --- 
                [self.indicatorDoc deleteDoc];
                [[IndicatorDatabase sharedDatabase] update];
                [[IndicatorDatabase sharedDatabase] updateLifetimeScore];
                [[IndicatorDatabase sharedDatabase] update];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    //Handle the add category alert view
    else if (alertView.tag == kAddCategoryAlertView) 
    {
        if(buttonIndex == 1)
        {
            //save the category
            self.indicatorDoc.data.category = [alertView textFieldAtIndex:0].text;
            //NSLog(@"New category: %@",_indicatorDoc.data.category);
            [self.indicatorDoc saveData]; //save the changes
            [self viewWillAppear:NO]; //refresh the view
        }
    }
    else if (alertView.tag == kSaveTimeAlertView)
    {
        if (buttonIndex == 0) { //CANCEL button
            //cancel the tracking time
            self.indicatorDoc.data.isTrackingTime = NO;
            self.indicatorDoc.data.startDate = nil;
            [self.indicatorDoc saveData];
            [[IndicatorDatabase sharedDatabase] update];
            [self viewWillAppear:YES];
        }
        if (buttonIndex == 1) //save the time
        {
            //put up the loading screen
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //NSLog(@"Loading Screen On");
            //callback to the saveTrackedTime method
            //[progressHUD showWhileExecuting:@selector(saveTrackedTime) onTarget:self withObject:nil animated:YES];
            [self performSelector:@selector(saveTrackedTime) withObject:nil afterDelay:0.001];
            //refresh the view
            //NSLog(@"Loading screen off");
        }
    }
    else if (alertView.tag == kWeekGoalTallyAlertView)
    {
        if (buttonIndex == 1) {
            //put up the loading screen
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //save the value entered as the goal
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            //get the number from the entered string... hopefully they dont paste some garbage in there.
            NSNumber* goal = [f numberFromString:[alertView textFieldAtIndex:0].text];
            [self.indicatorDoc.data.periodGoals setValue:goal forKey:[DateRange keyFromDateRange:[DateRange currentWeek]]];
            [f release];
            //Save the data
            [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
            //Remove the undo and redo buttons, to avoid confusion
            lastValueAdded = 0;
            lastValueRemoved = 0;
        }
    }
    else if (alertView.tag == kMonthGoalTallyAlertView)
    {
        if (buttonIndex == 1) {
            //put up the loading screen
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //save the value entered as the goal
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            //get the number from the entered string... hopefully they dont paste some garbage in there.
            NSNumber* goal = [f numberFromString:[alertView textFieldAtIndex:0].text];
            [self.indicatorDoc.data.periodGoals setValue:goal forKey:[DateRange keyFromDateRange:[DateRange currentMonth]]];
            [f release];
            //Save indicator data
            [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
            //Remove the undo and redo buttons, to avoid confusion
            lastValueAdded = 0;
            lastValueRemoved = 0;
        }
    }
    else if (alertView.tag == kRenameAlertView)
    {
        if (buttonIndex == 1) {            
            //get the text from the text field and save it as the title of the indicator
            self.indicatorDoc.data.title = [alertView textFieldAtIndex:0].text;
            //save the data
            [self.indicatorDoc saveData];
            [[IndicatorDatabase sharedDatabase] update];
            //refresh the view
            [self viewWillAppear:YES];
        }
    }
    else if (alertView.tag == kOptionsAlertView)
    {
        if (buttonIndex == 1) //The rename button
        {
            //bring up the rename dialogue
            //Create the UIAlertView and make it accept a user input string for an indicator name
            UIAlertView* renameAlertView = [[UIAlertView alloc] initWithTitle:@"Indicator Name" 
                                                                      message:@"Enter a name for your new indicator" 
                                                                     delegate:self 
                                                            cancelButtonTitle:@"Cancel"
                                                            otherButtonTitles:@"Save", nil];
            renameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            renameAlertView.tag = kRenameAlertView;
            [renameAlertView show];
            [renameAlertView release];
        }
        else if (buttonIndex == 2) //Inverse/Standard goal flipflop
        {
            //make the goal inverse if it isn't already an inverse goal
            if (self.indicatorDoc.data.isInverseGoal) {
                self.indicatorDoc.data.isInverseGoal = NO;
            }
            else
                self.indicatorDoc.data.isInverseGoal = YES;
            [self.indicatorDoc saveData];
            [[IndicatorDatabase sharedDatabase] update];
            [self viewWillAppear:YES];
        }
        else if (buttonIndex == 3) //deactivate button
        {
            self.indicatorDoc.data.isActive = NO;
            [self.indicatorDoc saveData];
            [[IndicatorDatabase sharedDatabase] update];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == kAddTalliesAlertView)
    {
        if (buttonIndex == 1) //save the value
        {
            //put up the loading screen
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //get the value to add
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            //get the number from the entered string... hopefully they dont paste some garbage in there.
            NSNumber* tallies = [f numberFromString:[alertView textFieldAtIndex:0].text];
            [f release];
            
            //add the tallies with todays date
            NSString* dateKey = [IndicatorDatabase dateKey];
            //check for an entry that already exists
            if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
            {
                //update the entry
                float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
                float newVal = [tallies floatValue] + curVal;
                [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
            }
            else
            {
                //make sure the dict is inited
                if (self.indicatorDoc.data.dailyActuals == nil) {
                    self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
                }
                [self.indicatorDoc.data.dailyActuals setObject:tallies forKey:dateKey];
            }
            
            //Save indicator data
            [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
            //update the undo/redo button values
            lastValueAdded = [tallies intValue];
            lastValueRemoved = 0;
            //end loading screen/refresh the screen
            if ([self.indicatorDoc.data.type isEqualToString:@"Timer"])
            {
                [self initTimerView];
            }
            else
            {
                [self initTallyView];
            }
        }
    }
}

#pragma mark - Picker View Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == kMonthGoalPickerView || pickerView.tag == kWeekGoalPickerView) {
        return 2; //The goal pickers need 2 components, one for hours and one for minutes
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == kPriorityPickerView) {
        return [self.priorityPickerArray count];
    }
    else if (pickerView.tag == kCategoryPickerView) {
        return [[IndicatorDatabase sharedDatabase].categories count];
    }
    else if (pickerView.tag == kMonthGoalPickerView || pickerView.tag == kWeekGoalPickerView) {
        if (component == 0) {
            return 1000; // Return 1000 rows for the first component in the goal setting picker views, so that users can set an hours goal anywhere from 0 to 999
        }
        else
            return 12; // 12 rows for 0-55 counting by 5s
    }
    else
    {
        //NSLog(@"Error in pickerView:numberOfRowsInComp... IndicatorDetailView.m");
        return 0;
    }
    
}


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == kPriorityPickerView) {
        return [self.priorityPickerArray objectAtIndex:row];
    }
    else if (pickerView.tag == kCategoryPickerView) {
        return [[IndicatorDatabase sharedDatabase].categories objectAtIndex:row];
    }
    else if (pickerView.tag == kWeekGoalPickerView || pickerView.tag == kMonthGoalPickerView) {
        if (component == 0)
            return [NSString stringWithFormat:@"%d",row]; //The row is the number for hours, so 0-999
        else
            return [NSString stringWithFormat:@"%d",row*5]; //The row multiplied by 5 is the number for minutes, so 0-55
    }
    else
    {
        //NSLog(@"Error in pickerView:numberOfRowsInComp... IndicatorDetailView.m");
        return 0;
    }
}



/*
 * Very High = .9, High = .7, Average = .5, Low = .3, Very Low = .1
 *
 *
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == kPriorityPickerView)
    {
        if (row==0) { //Very High
            tempBaseWeight = .9;
            //NSLog(@"Very High");
        }
        if (row==1) { //High
            tempBaseWeight = .7;
        }
        if (row==2) { //Average
            tempBaseWeight = .5;
        }
        if (row==3) { //Low
            tempBaseWeight = .3;
        }
        if (row==4) { //Very Low
            tempBaseWeight = .1;
        }

    }
    else if (pickerView.tag == kCategoryPickerView)
    {
        self.indicatorDoc.data.category = [[IndicatorDatabase sharedDatabase].categories objectAtIndex:row]; //assign the category
    }
    else if (pickerView.tag == kMonthGoalPickerView || pickerView.tag == kWeekGoalPickerView)
    {
        //Translate the selected data into a goal value, make sure that the double spin concept is safe
        int hours = [pickerView selectedRowInComponent:0];
        float minutes = [pickerView selectedRowInComponent:1]*5; //here we get the minutes and hours regardless of what component triggered the method call
        goalToSet = hours + (minutes/60.0f); //set the goalToSetVariable to the decimal number of hours for the goal.
    }
}

#pragma mark - Helper Methods
-(void)save
{
    NSString* monthKey = [DateRange keyFromDateRange:[DateRange currentMonth]];
    NSString* weekKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
    //update the periodValues
    [self.indicatorDoc.data.periodValues setObject:[NSNumber numberWithFloat:[self.indicatorDoc periodValueWithKey:weekKey]] forKey:weekKey];
    [self.indicatorDoc.data.periodValues setObject:[NSNumber numberWithFloat:[self.indicatorDoc periodValueWithKey:monthKey]] forKey:monthKey];
    //Save indicator data
    [self.indicatorDoc saveData];
    //update scores
    [self.indicatorDoc updateScoreForKey:monthKey];
    [self.indicatorDoc updateScoreForKey:weekKey];
    [[IndicatorDatabase sharedDatabase] updateLifetimeScore];
    [[IndicatorDatabase sharedDatabase] update];
    if ([self.indicatorDoc.data.type isEqualToString:@"Timer"])
    {
        [self initTimerView];
    }
    else
    {
        [self initTallyView];
    }
}

-(void)saveTrackedTime
{
    //NSLog(@"savetrackedtime");
    NSString* dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //check for an entry that already exists
    if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = curVal + self.indicatorDoc.hoursToBeAdded;
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else
    {
        //make sure that the dictionary is initalized
        if (self.indicatorDoc.data.dailyActuals == nil) {
            self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        //make a new entry for the day
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:self.indicatorDoc.hoursToBeAdded] forKey:dateKey];
    }
    //setup the undo/redo values
    lastValueAdded = self.indicatorDoc.hoursToBeAdded*60;
    lastValueRemoved = 0;
    //reset the temp variable
    self.indicatorDoc.hoursToBeAdded = 0.0f;
    //make sure the period values are inited... NOTE, this should be moved to the save method
    if (self.indicatorDoc.data.periodValues == nil) {
        //NSLog(@"was nil");
        self.indicatorDoc.data.periodValues = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
}

//Called when the widget is tapped in a tally indicator
-(void)addOneTally
{
    //Initialize the entries and entryTimes arrays if they haven't been already
    if (self.indicatorDoc.data.dailyActuals == nil) {
        //NSLog(@"Initing Daily Actuals dictionary in Indicator detail view");
        self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    //Add 1 to the daily actual
    //determine the correct key
    NSString* dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //check for an entry that already exists
    if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = curVal + 1;
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else
    {
        //make a new entry for the day
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:1] forKey:dateKey];
    }
    //make sure they are inited
    if (self.indicatorDoc.data.periodValues == nil) {
        //NSLog(@"was nil");
        self.indicatorDoc.data.periodValues = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
}

//Called every second to make sure that the widget button
-(void)refresh
{
    //At this point the only thing that needs to be refreshed is the widget
    if(self.indicatorDoc.data.isTrackingTime)
    {
        int trackedMinutes = [self getInterval];
        int trackedHours = ((trackedMinutes - (trackedMinutes%60))/60);
        [self.widgetButton setTitle:[NSString stringWithFormat:@"Save Time: %d:%02d",trackedHours,trackedMinutes%60] forState:UIControlStateNormal];
    }
}

/*
 * Returns the time elapsed in minutes, used for the time tracking widget
 */
-(float)getInterval
{
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.indicatorDoc.data.startDate];
	float minutes = interval/60.0f;
    if (minutes > 0) {
        return minutes;
    }
	else { 
        return 0.00;
        //this should never happen
    }
}

#pragma mark - ActionSheet methods
//TESTING PURPOSES ONLY
-(void)showPostDateSelector
{
    //save the date in countdown date picker
    postDate = YES;
    valueToAdd = _datePicker.countDownDuration;
    //NSLog(@"Postdate to add: %1.2f",valueToAdd);
    //release the old datepicker
    [_datePicker removeFromSuperview];
    [_datePicker release];
    _datePicker = nil;
    //remove the old picker from the view
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    //Make a new date picker
    _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
    [_addHoursPickerActionSheet addSubview:_datePicker];
}

-(void)dismissGoalActionSheet
{
    [self.goalPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)dismissWeekGoalActionSheetWithSave
{
    //put up the loading screen
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //Set the goal in the data, and then save the data.
    //NOTE: there has been mental debate whether to present a user with an overwrite date querry here.
    NSString* key = [DateRange keyFromDateRange:[DateRange currentWeek]];
    [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:goalToSet] forKey:key];
    //Remove the undo and redo buttons, to avoid confusion
    lastValueAdded = 0;
    lastValueRemoved = 0;
    //Save indicator data
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    //Dismiss the view
    [self.goalPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    //NSLog(@"dismissWeekGoalActionSheetWithSaveCompleted, goalToSet: %1.2f",goalToSet);
}

-(void)dismissMonthGoalActionSheetWithSave
{
    //put up the loading screen
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //Set the goal in the data, and then save the data.
    //NOTE: there has been mental debate whether to present a user with a overwrite date querry here.
    NSString* key = [DateRange keyFromDateRange:[DateRange currentMonth]];
    [self.indicatorDoc.data.periodGoals setValue:[NSNumber numberWithFloat:goalToSet] forKey:key];
    //Remove the undo and redo buttons, to avoid confusion
    lastValueAdded = 0;
    lastValueRemoved = 0;
    //Save the changes
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    //Dismiss the view
    [self.goalPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    //NSLog(@"dismissMonthGoalActionSheetWithSaveCompleted, goalToSet: %1.2f",goalToSet);
}

-(void)dismissAddHoursActionSheetWithSave
{
    [self.addHoursPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    // SAVING CODE COMPLETE
    [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    //calc the value to be added
    NSString* dateKey; 
    //TESTING ONLY
    /*
    if (postDate) 
    {
        dateKey = [IndicatorDatabase dateKeyWithDate:self.datePicker.date];
        valueToAdd = valueToAdd/3600;
        // add a goal there as well
        monthKey = [DateRange keyFromDateRange:[DateRange monthContainingDate:_datePicker.date]];
        weekKey = [DateRange keyFromDateRange:[DateRange weekContainingDate:_datePicker.date]];
        NSLog(@"KEYS: %@, %@",monthKey, weekKey);
        if(_indicatorDoc.data.periodGoals == nil)
        {
            //NSLog(@"Had to init goals dict");
            self.indicatorDoc.data.periodGoals = [NSMutableDictionary dictionaryWithCapacity:1];
        }
    }
    else
    {
        valueToAdd = self.datePicker.countDownDuration/3600;
        dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
        monthKey = [DateRange keyFromDateRange:[DateRange currentMonth]];
        weekKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
    }
     */
    valueToAdd = (self.datePicker.countDownDuration/3600);
    dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //NSLog(@"Value to add is: %1.2f",valueToAdd);
    //NSLog(@"datekey is %@",dateKey);
    //add it

    //check for an entry that already exists
    if ([self.indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[self.indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = valueToAdd + curVal;
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else
    {
        //make sure the dict is inited
        if (self.indicatorDoc.data.dailyActuals == nil) {
            self.indicatorDoc.data.dailyActuals = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        [self.indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:valueToAdd] forKey:dateKey];
    }
   
    //update values
    //make sure they have been init'd
    if (self.indicatorDoc.data.periodValues == nil) {
        //NSLog(@"was nil");
        self.indicatorDoc.data.periodValues = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    //[self save];
   //set the undo/redo values
    lastValueAdded = valueToAdd*60;
    lastValueRemoved = 0;
}
-(void)dismissAddHoursActionSheet
{
    self.indicatorDoc.hoursToBeAdded = 0.0f;
    self.indicatorDoc.minutesToBeAdded = 0.0f;
     [self.addHoursPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)dismissPriorityActionSheet
{
    [self.priorityPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    //SAVE DATA
    //put up the loading screen
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //set the base weight value
    self.indicatorDoc.data.weightBase = tempBaseWeight;
    tempBaseWeight = 0.0f; //reset the baseweight
    //Save indicator data
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    //refresh the view
}
-(void)dismissCategoryActionSheet
{
    [self.categoryPickerActionSheet dismissWithClickedButtonIndex:0 animated:YES];
    //Save Data
    //SAVE DATA
    //Save indicator data
    [self performSelector:@selector(save) withObject:nil afterDelay:0.001];
    //end loading screen/refresh
    [self viewWillAppear:YES];
}

-(void)addCategory
{
    //NSLog(@"Add category Tapped");
    //pop up a new action sheet that gets a string from user
    UIAlertView* addCategoryAlertView = [[UIAlertView alloc] initWithTitle:@"New Category" message:@"Enter a name for the category!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    addCategoryAlertView.alertViewStyle = UIAlertViewStylePlainTextInput; //set it up as a plain alert view style
    //Hide the categoryPickerView
    [self dismissCategoryActionSheet];
    addCategoryAlertView.tag = kAddCategoryAlertView; //Tag the Category Alert view
    [addCategoryAlertView show];
    [addCategoryAlertView release];
}

#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	self.priorityButton = nil;
	self.widgetButton = nil;
	self.addWeekValueButton = nil;
    self.addMonthValueButton = nil;
    self.monthProgressView = nil;
    self.weekProgressView = nil;
	self.categorySelectorButton = nil;
    self.priorityPickerActionSheet = nil;
    self.goalWeekButton = nil;
    self.goalMonthButton = nil;
}


- (void)dealloc {
    [super dealloc];
	[self.addWeekValueButton release];
	self.addWeekValueButton = nil;
    [self.addMonthValueButton release];
    self.addMonthValueButton = nil;
	[self.indicatorDoc release];
	self.indicatorDoc = nil;
	[self.monthProgressView release];
	self.monthProgressView = nil;
	[self.widgetButton release];
	self.widgetButton = nil;
	[self.categorySelectorButton release];
	self.categorySelectorButton = nil;
    [self.priorityButton release];
    self.priorityButton = nil;
    [self.priorityPickerArray release];
    self.priorityPickerArray = nil;
	[self.priorityPickerActionSheet release];
    self.priorityPickerActionSheet = nil;
    [self.categoryPickerActionSheet release];
    self.categoryPickerActionSheet = nil;
    [self.monthProgressView release];
    [self.weekProgressView release];
    self.monthProgressView = nil;
    self.weekProgressView = nil;
    [self.addHoursPickerActionSheet release];
    self.addHoursPickerActionSheet = nil;
	[self.datePicker release];
    self.datePicker = nil;
    [self.goalMonthButton release];
    [self.goalWeekButton release];
    self.goalWeekButton = nil;
    self.goalMonthButton = nil;
}


@end
