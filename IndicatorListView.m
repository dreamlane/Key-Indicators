//
//  IndicatorListView.m
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Eventually use custom cells that show an Icon, text, and progress bar

#import "IndicatorListView.h"


@implementation IndicatorListView

@synthesize indicatorDetailView = _indicatorDetailView;
@synthesize indicators = _indicators;
@synthesize categories = _categories;
@synthesize categoryKeys = _categoryKeys;
@synthesize thisWeek;
@synthesize thisMonth;

#define kCurrentlyTrackingKey @"Currently Tracking"
#define kDeactivatedIndicatorKey @"Deactivated Indicators"

//UIAlertView tags
#define kNewTimer 1 //Used when creating a new timer indicator
#define kNewTally 2 //Used when creating a new tally indicator
//ImageView tags
#define kTutorialImageView 1

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    //NSLog(@"ViewDidLoad");
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
											   target:self action:@selector(showNewIndicatorActionSheet:)] autorelease];
	self.title = @"Indicators";
    self.indicators = [IndicatorDatabase sharedDatabase].indicatorDocs;
    
    /* Make the categorized data structure */
    self.categories = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSString* category in [IndicatorDatabase sharedDatabase].categories) {
        //NSLog(@"Category is: %@",category);
        [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:category];
    }
    
    for (NSString* key in self.indicators) {
        IndicatorDoc* doc = [self.indicators objectForKey:key];
        if (doc.data.isActive) //make sure the indicator is not deactivated
        {
            if (doc.data.isTrackingTime)
            { //check for activated timers
                if ([self.categories objectForKey:kCurrentlyTrackingKey] == nil) {
                    [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:kCurrentlyTrackingKey];
                }
                [[self.categories objectForKey:kCurrentlyTrackingKey] addObject:doc]; //Add the indicator to the currently tracking time section, as well as the normal section
            }
            [[self.categories objectForKey:doc.data.category] addObject:doc];
            //NSLog(@"doc added");
        }
        else //add to the deactivated section
        {
            if ([self.categories objectForKey:kDeactivatedIndicatorKey] == nil) {
                [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:kDeactivatedIndicatorKey];
            }
            [[self.categories objectForKey:kDeactivatedIndicatorKey] addObject:doc];
        }
    }
    [self sortCategories];
    [self.tableView reloadData];
}



- (void)viewWillAppear:(BOOL)animated 
{	
    //NSLog(@"ViewWillAppear");
    [super viewWillAppear:animated];
    //[[IndicatorDatabase sharedDatabase] update]; //Superfluous?
    self.indicators = [IndicatorDatabase sharedDatabase].indicatorDocs;
    
    /* Make the categorized data structure */
    self.categories = [NSMutableDictionary dictionaryWithCapacity:1];

    self.thisWeek = [DateRange keyFromDateRange:[DateRange currentWeek]];
    self.thisMonth = [DateRange keyFromDateRange:[DateRange currentMonth]];
    
    for (NSString* category in [IndicatorDatabase sharedDatabase].categories) {
        //NSLog(@"Category is: %@",category);
        [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:category];
    }
    
    for (NSString* key in self.indicators) {
        IndicatorDoc* doc = [self.indicators objectForKey:key];
        if (doc.data.isActive) //make sure the indicator is not deactivated
        {
            if (doc.data.isTrackingTime)
            { //check for activated timers
                if ([self.categories objectForKey:kCurrentlyTrackingKey] == nil) {
                    [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:kCurrentlyTrackingKey];
                }
                [[self.categories objectForKey:kCurrentlyTrackingKey] addObject:doc]; //Add the indicator to the currently tracking time section, as well as the normal section
            }
            [[self.categories objectForKey:doc.data.category] addObject:doc];
            //NSLog(@"doc added");
        }
        else //add to the deactivated section
        {
            if ([self.categories objectForKey:kDeactivatedIndicatorKey] == nil) {
                [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:kDeactivatedIndicatorKey];
            }
            [[self.categories objectForKey:kDeactivatedIndicatorKey] addObject:doc];
        }
    }
    [self sortCategories];
    [self.tableView reloadData];
    //If there are no indicators put up a tutorial screen
    if ([self.indicators count] == 0) {
        //NSLog(@"0 indicators");
        UIImage* indicatorCreationTutorialImage = [UIImage imageNamed:@"EmptyIndicatorsScreen.png"];
        UIImageView* tutorialImageView = [[UIImageView alloc] initWithImage:indicatorCreationTutorialImage];
        tutorialImageView.frame = CGRectMake(55, -5, indicatorCreationTutorialImage.size.width, indicatorCreationTutorialImage.size.height);
        tutorialImageView.tag = kTutorialImageView;
        [self.view addSubview:tutorialImageView];
        [tutorialImageView release];
    }
    else {
        //find and remove the view
        NSArray* subviewsArray = [self.view subviews];
        for (UIView* view in subviewsArray)
        {
            if (view.tag == kTutorialImageView)
            {
                [view removeFromSuperview];
            }
        }
    }
}

#pragma mark -
#pragma mark Table view data source

-(void)sortCategories
{
    NSMutableArray* keys = [NSMutableArray arrayWithArray:[self.categories allKeys]];
    if ([keys indexOfObject:@"Uncategorized"] != NSNotFound)
    {
        if ([self.categories valueForKey:kDeactivatedIndicatorKey] == nil) {
            int uncat = [keys indexOfObject:@"Uncategorized"];
            int lastcat = [keys count] -1;
            NSString* temp = [keys objectAtIndex:lastcat];
            [keys replaceObjectAtIndex:lastcat withObject:@"Uncategorized"];
            [keys replaceObjectAtIndex:uncat withObject:temp];
        }
        else
        {
            //Put the Deactivated category at the very end
            int deactivatedIndex = [keys indexOfObject:kDeactivatedIndicatorKey];
            int lastIndex = [keys count] -1;
            NSString* templast = [keys objectAtIndex:lastIndex];
            [keys replaceObjectAtIndex:lastIndex withObject:kDeactivatedIndicatorKey];
            [keys replaceObjectAtIndex:deactivatedIndex withObject:templast];
            //Put the Uncategorized category at the penultimate position
            int penultimate = [keys count] -2;
            NSString* penlast = [keys objectAtIndex:penultimate];
            int uncategorizedIndex = [keys indexOfObject:@"Uncategorized"];
            [keys replaceObjectAtIndex:penultimate withObject:@"Uncategorized"];
            [keys replaceObjectAtIndex:uncategorizedIndex withObject:penlast];
        }
    }
    else if ([self.categories valueForKey:kDeactivatedIndicatorKey] != nil)
    {
        int uncat = [keys indexOfObject:kDeactivatedIndicatorKey];
        int lastcat = [keys count] -1;
        NSString* temp = [keys objectAtIndex:lastcat];
        [keys replaceObjectAtIndex:lastcat withObject:kDeactivatedIndicatorKey];
        [keys replaceObjectAtIndex:uncat withObject:temp];
    }
    //check for tracking indicators and place them at the top of the list
    if ([self.categories valueForKey:kCurrentlyTrackingKey] != nil) {
        int trackingIndex = [keys indexOfObject:kCurrentlyTrackingKey];
        NSString* temp = [keys objectAtIndex:0]; //grab the first key temporarily
        [keys replaceObjectAtIndex:0 withObject:kCurrentlyTrackingKey];
        [keys replaceObjectAtIndex:trackingIndex withObject:temp];
    }
    self.categoryKeys = keys;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"cats = %d",[self.categories count]);
    return [[self.categories allKeys] count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Make sure that the Uncategorized sections goes to the end, directly before deactivated indicators
        return [self.categoryKeys objectAtIndex:section];
}
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger count = [[self.categories valueForKey:[self.categoryKeys objectAtIndex:section]] count];
    // If the section is not the "Currently Tracking" or "deactivated" section, return an extra row for the section
    if (![[self.categoryKeys objectAtIndex:section] isEqualToString:kCurrentlyTrackingKey] && 
        ![[self.categoryKeys objectAtIndex:section] isEqualToString:kDeactivatedIndicatorKey])
        count++;
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    //NSLog(@"cellForRow section: %d, row: %d",indexPath.section,indexPath.row);
    
    // If it's the first row in the section, make a CategorySummaryCell, but make sure it's not the "currently tracking" or "deactivated" section
    if (indexPath.row == 0 && ![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kCurrentlyTrackingKey] &&
        ![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kDeactivatedIndicatorKey]) 
    {
        static NSString* CellIdentifier = @"CategorySummaryCell";
        CategorySummaryCell* cell = (CategorySummaryCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategorySummaryCell" 
                                                                     owner:nil options:nil];
            for (id currentObject in topLevelObjects) 
            {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) 
                {
                    cell = (CategorySummaryCell*) currentObject;
                    break;
                }
            }
        }
        //Title Label
        NSString* categoryKey = [self.categoryKeys objectAtIndex:indexPath.section];
        [cell.titleLabel setText:categoryKey];
        
        //Get the data
        /*
         * Iterate through all of the indicators in this category, check to see if they are timers, and then add up their values for last month, and last week
         * Then format accordingly
         */
        float monthHours = 0.0f;
        float weekHours = 0.0f;
        NSArray* docsInCategory = [self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]];
        for (IndicatorDoc* doc in docsInCategory)
        {
            if ([doc.data.type isEqualToString:@"Timer"]) {
                //add up the hours
                monthHours += [[doc.data.periodValues objectForKey:self.thisMonth]floatValue];
                weekHours += [[doc.data.periodValues objectForKey:self.thisWeek]floatValue];
            }
        }
        //After this loop has run, the variables lastMonthHours and lastWeekHours should have the total hours from this category as a float
        //Now calc the number of minutes for simpler display formatting
        int monthMinutes = monthHours*60;
        int weekMinutes = weekHours*60;
        //And edit hours to be integers
        int intMonthHours = ((monthMinutes - (monthMinutes%60))/60);
        int intWeekHours = ((weekMinutes - (weekMinutes%60)) / 60);
        [cell.thisMonth setText:[NSString stringWithFormat:@"%d:%02d",intMonthHours,monthMinutes%60]];
        [cell.thisWeek setText:[NSString stringWithFormat:@"%d:%02d",intWeekHours,weekMinutes%60]];
        [cell setUserInteractionEnabled:NO]; // These cells are do not currently support interaction
        return cell;
    }

    // If it's not the first row, make an IndicatorSummaryCell
    else
    {
        // If this is not the Currently Tracking Section, offset the rows by negative 1, to compensate for the CategorySummaryCell
        int row = indexPath.row;
        if (![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kCurrentlyTrackingKey] &&
            ![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kDeactivatedIndicatorKey]) {
            row = row - 1;
        }
        //Get the IndicatorDoc for the current row/section
        IndicatorDoc*doc = [[self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]] objectAtIndex:row];
        //Do some cool stuff that I don't understand, but it appears to be the correct way to do things
        static NSString* CellIdentifier = @"IndicatorSummaryCell";
        IndicatorSummaryCell* cell = (IndicatorSummaryCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IndicatorSummaryCell" 
                                                                     owner:nil options:nil];
            for (id currentObject in topLevelObjects) 
            {
                if ([currentObject isKindOfClass:[UITableViewCell class]]) 
                {
                    cell = (IndicatorSummaryCell*) currentObject;
                    break;
                }
            }
        }
        
        // Configure the cell...
        cell.titleLabel.text = doc.data.title; //Set the title of the summary cell
        if (doc.data.isActive) {
            [cell.titleLabel setTextColor:[UIColor colorWithRed:0.0f green:.5f blue:.8f alpha:1.0f]];
        }
        else
            [cell.titleLabel setTextColor:[UIColor grayColor]];
        //Check to see if the indicator is tracking
        if (doc.data.isTrackingTime) {
            //NSLog(@"cell at index %i, is tracking", indexPath.row);
            cell.indicatorBulbOn = YES;
            [cell.indicatorOnView setHidden:NO];
        }
        else {
            //NSLog(@"cell at index %i, is not tracking", indexPath.row);
            cell.indicatorBulbOn = NO;
            [cell.indicatorOnView setHidden:YES];
            //cell.indicatorOnView.image = nil;
        }
        
        //Check to see if the goals are not yet set, if not, set them to last month's or week's goal, if those are not set, set the goal to 0.00
        if ([doc.data.periodGoals objectForKey:self.thisWeek] == nil)
        {
            NSString* lastWeek = [DateRange keyForPeriodPriorToKey:self.thisWeek];
            NSNumber* lastWeekGoal = [doc.data.periodGoals objectForKey:lastWeek];
            if (lastWeekGoal != nil) {
                [doc.data.periodGoals setObject:lastWeekGoal forKey:self.thisWeek];
            }
            else
                [doc.data.periodGoals setObject:[NSNumber numberWithFloat:0.0f] forKey:self.thisWeek];
            [doc saveData];
        }
        if ([doc.data.periodGoals objectForKey:self.thisMonth] == nil)
        {
            NSString* lastMonth = [DateRange keyForPeriodPriorToKey:self.thisMonth];
            NSNumber* lastMonthGoal = [doc.data.periodGoals objectForKey:lastMonth];
            if (lastMonthGoal != nil) {
                [doc.data.periodGoals setObject:lastMonthGoal forKey:self.thisMonth];
            }
            else
                [doc.data.periodGoals setObject:[NSNumber numberWithFloat:0.0f] forKey:self.thisMonth];
            [doc saveData];
        }
        //Fill the progress bar according to user progress and goal type
        float weekGoal = [[doc.data.periodGoals objectForKey:self.thisWeek] floatValue];
        float monthGoal = [[doc.data.periodGoals objectForKey:self.thisMonth] floatValue];  
        cell.monthGoalProgressView.goal = monthGoal;
        cell.weekGoalProgressView.goal = weekGoal;
        if (doc.data.isInverseGoal)
        {
            //NSLog(@"Is Inverse Goal");
            cell.weekGoalProgressView.progress = (1-(1/(weekGoal)*[doc periodValueWithKey:self.thisWeek])); //Drain the bar, intsead of filling it: 1-(1/goal)*actual
            cell.monthGoalProgressView.progress = (1-(1/(monthGoal)*[doc periodValueWithKey:self.thisMonth])); //Drain the month bar
        }
        else
        {
            cell.weekGoalProgressView.progress = ([doc periodValueWithKey:self.thisWeek] / weekGoal);
            cell.monthGoalProgressView.progress = ([doc periodValueWithKey:self.thisMonth] / monthGoal);
        }
        
        //Change the backround/body of the cell if it's a tally cell
        if ([doc.data.type isEqualToString:@"Tally"]) {
            [cell.backingView setImage:[UIImage imageNamed:@"IndicatorOverviewCelliPhone-tally-arrow.png"]];
        }
        else
            [cell.backingView setImage:[UIImage imageNamed:@"IndicatorOverviewCelliPhone-new-arrow.png"]];
        return cell;
    }
}

#pragma mark -
#pragma mark Table view delegate

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 8)] autorelease];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kCurrentlyTrackingKey]) {
        return 8.0f;
    }
    else if ([self.categoryKeys indexOfObject:kDeactivatedIndicatorKey] != NSNotFound)
    {
        // If the section is the penultimate section, give it a footer
        if (section == [self.categoryKeys count]-2) {
            return 8.0f;
        }
        return 4.0f;
    }
    else return 4.0f;
}

/*
 * Documentation needed
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kCurrentlyTrackingKey] || [[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kDeactivatedIndicatorKey]) {
        return 50.0f;
    }
    else if (indexPath.row == 0)
    {
        return 44.0f;
    }
    else
        return 50.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kCurrentlyTrackingKey] || [[self.categoryKeys objectAtIndex:section] isEqualToString:kDeactivatedIndicatorKey]) {
        return 22.0f;
    }
    else
        return 0.0f;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)] autorelease];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    //Check for Deactivated or tracking
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kDeactivatedIndicatorKey])
    {
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:1.0f green:.5 blue:.5 alpha:1.0f] CGColor], (id)[[UIColor redColor] CGColor], nil];
        [headerView.layer insertSublayer:gradient atIndex:0];
    }
    else if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kCurrentlyTrackingKey])
    {
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:.5f green:.5f blue:1.0f alpha:1.0f] CGColor], (id)[[UIColor blueColor] CGColor], nil];
        [headerView.layer insertSublayer:gradient atIndex:0];
    }
    else
    {
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
        [headerView.layer insertSublayer:gradient atIndex:0];
    }
    //can use "if" to color certain sections as needed, use this for tracking and deactivated?
    //[headerView setBackgroundColor:[UIColor grayColor]];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(8, 0, tableView.bounds.size.width - 20, 20)] autorelease];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.85];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    if (![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kCurrentlyTrackingKey] &&
        ![[self.categoryKeys objectAtIndex:indexPath.section] isEqualToString:kDeactivatedIndicatorKey]) {
        row = row - 1;
    }
    // Make sure the selection is a Doc selection
    if (row >= 0)
    {
        //Get the Indicator Doc associated with the tapped row
        IndicatorDoc *doc = [[self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]] objectAtIndex:row];
        
        // ----Handle Deactivated Indicators vs Activated here ----
        if (doc.data.isActive)
        {
            //Init the IndicatorDetailView
            self.indicatorDetailView = [[IndicatorDetailView alloc] initWithNibName:@"IndicatorDetailView" bundle:[NSBundle mainBundle]];
            //send the indicator to the detail view
            self.indicatorDetailView.indicatorDoc = doc;
            [self.navigationController pushViewController:self.indicatorDetailView animated:YES];
        }
        else
        {
            self.indicatorDetailView = [[IndicatorDetailView alloc] initWithNibName:@"DeactivatedIndicatorDetailView" bundle:[NSBundle mainBundle]];
            self.indicatorDetailView.indicatorDoc = doc;
            [self.navigationController pushViewController:self.indicatorDetailView animated:YES];
        }
    }
    else
    {
        // Here we will go to the categoryDetailView
    }
}

#pragma mark - ActionSheet

//Handles touches on the pop up dialog when creating a new Indicator
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == 0) 
    { // New Timer

        UIAlertView* newTimerAlertView = [[[UIAlertView alloc] initWithTitle:@"Create New Timer" 
                                                                    message:@"Enter a name for your new indicator" 
                                                                   delegate:self 
                                                          cancelButtonTitle:@"Cancel" 
                                                          otherButtonTitles:@"Create", nil] autorelease];
        newTimerAlertView.tag = kNewTimer;
        newTimerAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [newTimerAlertView show];
        //[newTimerAlertView release];
	}//End Timer selection
	
	else if (buttonIndex == 1)
    {//New Tally
        //NSLog(@"ActionSheet button 2 tapped");
		UIAlertView* newTallyAlertView = [[[UIAlertView alloc] initWithTitle:@"Create New Tally" 
                                                                        message:@"Enter a name for your new indicator" 
                                                                    delegate:self 
                                                          cancelButtonTitle:@"Cancel" 
                                                          otherButtonTitles:@"Create", nil] autorelease];
        newTallyAlertView.tag = kNewTally;
        newTallyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [newTallyAlertView show];
        //NSLog(@"end");
        //[newTallyAlertView release];
	}//End Tally selection
}


//This method shows a popup menu with options to select a timed or tally indicator
//NOTE: it is poorly named and should be refactored
- (IBAction)showNewIndicatorActionSheet:(id)sender
{
    //NSLog(@"New indicator action sheet");
	UIActionSheet *popupQuery = [[UIActionSheet alloc] 
								 initWithTitle:@"New Indicator Type" delegate:self 
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
								 otherButtonTitles:@"Time Indicator", @"Tally Indicator", nil];
    
	popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
	//popupQuery.title = @"New Indicator Type";
	[popupQuery showInView:self.parentViewController.tabBarController.view];
    [popupQuery release];
}
#pragma mark - AlertView
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kNewTimer) 
    {
        if (buttonIndex == 1) 
        { //create new indicator
            //NSLog(@"New Timer");
            IndicatorData* defaultData =[IndicatorData defaultDataWithType:@"Timer"];
            IndicatorDoc* newDoc = [[IndicatorDoc alloc] initWithIndicatorData:defaultData];
            newDoc.data.title = [alertView textFieldAtIndex:0].text;
            [[IndicatorDatabase sharedDatabase].indicatorDocs setObject:newDoc forKey:newDoc.data.key];
            //SAVE The Data
            [newDoc saveData]; //save the changes
            [[IndicatorDatabase sharedDatabase] update];
            self.indicatorDetailView = [[IndicatorDetailView alloc] initWithNibName:@"IndicatorDetailView" bundle:[NSBundle mainBundle]];
            self.indicatorDetailView.indicatorDoc = [newDoc retain];
            self.indicatorDetailView.indicatorDoc.isNewDoc = YES;
            [self.navigationController pushViewController:self.indicatorDetailView animated:YES];
            [self viewWillAppear:YES];
            [newDoc release];
            //NSLog(@"New Timer End");
        }
    }
    if (alertView.tag == kNewTally) 
    {
        if (buttonIndex == 1)
        { //create new indicator
            //NSLog(@"New Tally");
            IndicatorData* defaultData =[IndicatorData defaultDataWithType:@"Tally"];
            IndicatorDoc* newDoc = [[IndicatorDoc alloc] initWithIndicatorData:defaultData];
            newDoc.data.title = [alertView textFieldAtIndex:0].text;
            [[IndicatorDatabase sharedDatabase].indicatorDocs setObject:newDoc forKey:newDoc.data.key];
            //SAVE The Data
            [newDoc saveData]; //save the changes
            [[IndicatorDatabase sharedDatabase] update];
            //Go to the detail view for the new indicator
            self.indicatorDetailView = [[IndicatorDetailView alloc] initWithNibName:@"IndicatorDetailView" bundle:[NSBundle mainBundle]];
            self.indicatorDetailView.indicatorDoc = [newDoc retain];
            self.indicatorDetailView.indicatorDoc.isNewDoc = YES;
            [self.navigationController pushViewController:self.indicatorDetailView animated:YES];
            [self viewWillAppear:YES];
            [newDoc release];
        }
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.indicatorDetailView = nil;
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	//[self.indicatorDetailView release];
	self.indicatorDetailView = nil;
    //[self.indicators release];
    self.indicators = nil;
    [super dealloc];
}


@end

