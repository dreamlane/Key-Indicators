//
//  ReviewView.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 11/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
// NOTE: This view makes a lot of calculations, so a loading screen may be necessary

#import "ReviewListView.h"

@implementation ReviewListView

@synthesize graphDetailView = _graphDetailView;
@synthesize chartDetailView;
@synthesize indicators = _indicators;
@synthesize categories = _categories;
@synthesize categoryKeys = _categoryKeys;
@synthesize currentMonth = _currentMonth;
@synthesize currentWeek = _currentWeek;
@synthesize lastWeekKey = _lastWeekKey;
@synthesize lastMonthKey = _lastMonthKey;

#define kCurrentlyTrackingKey @"Currently Tracking"
#define kDeactivatedIndicatorKey @"Deactivated Indicators"
#define kScoresKey @"Scores"
#define allCategoriesKey @"AllCategoriesBreakdown"

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Review";
}

- (void)viewWillAppear:(BOOL)animated 
{	
    //NSLog(@"ViewWillAppear");
    [super viewWillAppear:animated];
    
    [[IndicatorDatabase sharedDatabase] update];
    self.indicators = [IndicatorDatabase sharedDatabase].indicatorDocs;
    
    /* Make the categorized data structure */
    self.categories = [NSMutableDictionary dictionaryWithCapacity:1];
    
    for (NSString* category in [IndicatorDatabase sharedDatabase].categories) {
        //NSLog(@"Category is: %@",category);
        [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:category];
    }
    // Add the scores section
    [self.categories setValue:[NSMutableArray arrayWithCapacity:1] forKey:kScoresKey];
    for (NSString* key in self.indicators) {
        IndicatorDoc* doc = [self.indicators objectForKey:key];
        if (doc.data.isActive) //make sure the indicator is not deactivated
        {
            [[self.categories objectForKey:doc.data.category] addObject:doc];
            //NSLog(@"doc added");
        }
    }
    [self sortCategories];
    //Range Keys
    self.currentWeek = [DateRange keyFromDateRange:[DateRange currentWeek]];
    self.currentMonth = [DateRange keyFromDateRange:[DateRange currentMonth]];
    self.lastMonthKey = [DateRange keyForPeriodPriorToKey:self.currentMonth];
    self.lastWeekKey = [DateRange keyForPeriodPriorToKey:self.currentWeek];
    [self.tableView reloadData];
    
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

#pragma mark - Cell Creators
-(LifetimeSummaryCell*)createLifetimeCellForTableView:(UITableView*)tableView
{
    //set up the cell
    LifetimeSummaryCell* cell = (LifetimeSummaryCell*) [tableView dequeueReusableCellWithIdentifier:@"LifetimeSummaryCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LifetimeSummaryCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (LifetimeSummaryCell*) currentObject;
                break;
            }
        }
    }
    //Customize it
    //set the score label
    [cell.scoreLabel setText:[NSString stringWithFormat:@"%1.0f",[IndicatorDatabase sharedDatabase].lifetimeTotal]];
    //return the cell
    return cell;
}

-(AvgPrevScoreSummaryCell*)createAvgPrevScoreSummaryCellForTableView:(UITableView*)tableView
{
    // Get the correct values
    float lastMonthTotal = 0.0f;
    float lastWeekTotal = 0.0f;
    // Add up the totals for the previous week
    for (NSString* key in [self.indicators allKeys]){
        IndicatorDoc* doc = [self.indicators objectForKey:key];
        lastMonthTotal += [[doc.data.periodScores  objectForKey:self.lastMonthKey] floatValue];
        lastWeekTotal += [[doc.data.periodScores  objectForKey:self.lastWeekKey] floatValue];
    }
    // Set up and Customize the Cell
    AvgPrevScoreSummaryCell* cell = (AvgPrevScoreSummaryCell*) [tableView dequeueReusableCellWithIdentifier:@"AvgPrevScoreSummaryCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AvgPrevScoreSummaryCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (AvgPrevScoreSummaryCell*) currentObject;
                break;
            }
        }
    }
    [cell.previousMonthScoreLabel setText:[NSString stringWithFormat:@"%1.0f",lastMonthTotal]];
    [cell.previousWeekScoreLabel setText:[NSString stringWithFormat:@"%1.0f",lastWeekTotal]];
    [cell.averageMonthScoreLabel setText:[NSString stringWithFormat:@"%1.0f",[IndicatorDatabase sharedDatabase].monthAverageScore]];
    [cell.averageWeekScoreLabel setText:[NSString stringWithFormat:@"%1.0f",[IndicatorDatabase sharedDatabase].weekAverageScore]];
    return cell;
}

-(CurrentScoreSummaryCell*)createCurrentScoreSummaryCellForTableView:(UITableView*)tableView
{
    float monthCurrentScore = 0.0f;
    float weekCurrentScore = 0.0f;
    float monthMaximumScore = 0.0f;
    float weekMaximumScore = 0.0f;
    //Get the current and max scores and add em up
    for (NSString* key in [self.indicators allKeys])
    {
        IndicatorDoc* doc = [self.indicators objectForKey:key];
        if ([doc.data.periodScores objectForKey:self.currentMonth] != nil)
            monthCurrentScore += [[doc.data.periodScores objectForKey:self.currentMonth] floatValue];
        else
            monthCurrentScore += 0.0f;
        if ([doc.data.periodScores objectForKey:self.currentWeek] != nil)
            weekCurrentScore += [[doc.data.periodScores objectForKey:self.currentWeek] floatValue];
        else
            weekCurrentScore += 0.0f;
        
        monthMaximumScore += [doc maximumScoreWithKey:self.currentMonth];
        weekMaximumScore += [doc maximumScoreWithKey:self.currentWeek];
    }
    
    // Set up and Customize the Cell
    CurrentScoreSummaryCell* cell = (CurrentScoreSummaryCell*) [tableView dequeueReusableCellWithIdentifier:@"CurrentScoreSummaryCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CurrentScoreSummaryCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (CurrentScoreSummaryCell*) currentObject;
                break;
            }
        }
    }
    [cell.currentMonthScoreLabel setText:[NSString stringWithFormat:@"%1.0f",monthCurrentScore]];
    [cell.currentWeekScoreLabel setText:[NSString stringWithFormat:@"%1.0f",weekCurrentScore]];
    [cell.currentMonthMaxLabel setText:[NSString stringWithFormat:@"%1.0f",monthMaximumScore]];
    [cell.currentWeekMaxLabel setText:[NSString stringWithFormat:@"%1.0f",weekMaximumScore]];
    //Setup the progress bars
    cell.monthGoalProgressView.goal = .01f; //Activate the bar... if the goal is 0.0 the bar is inactive
    cell.weekGoalProgressView.goal = .01f;
    cell.monthGoalProgressView.progress = monthCurrentScore/monthMaximumScore;
    cell.weekGoalProgressView.progress = weekCurrentScore/weekMaximumScore;
    //Disable interaction
    [cell setUserInteractionEnabled:NO];
    return cell;
}

-(CategoryReviewCell*)createCategoryReviewCellForTableView:(UITableView*)tableView withIndexPath:(NSIndexPath*)indexPath
{
    // Set up and customize the cell
    CategoryReviewCell* cell = (CategoryReviewCell*) [tableView dequeueReusableCellWithIdentifier:@"CategoryReviewCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryReviewCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (CategoryReviewCell*) currentObject;
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
    float lastMonthHours = 0.0f;
    float lastWeekHours = 0.0f;
    NSArray* docsInCategory = [self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]];
    for (IndicatorDoc* doc in docsInCategory)
    {
        if ([doc.data.type isEqualToString:@"Timer"]) {
            //add up the hours
            lastMonthHours += [[doc.data.periodValues objectForKey:self.lastMonthKey]floatValue];
            lastWeekHours += [[doc.data.periodValues objectForKey:self.lastWeekKey]floatValue];
        }
    }
    //After this loop has run, the variables lastMonthHours and lastWeekHours should have the total hours from this category as a float
    //Now calc the number of minutes for simpler display formatting
    int monthMinutes = lastMonthHours*60;
    int weekMinutes = lastWeekHours*60;
    //And edit hours to be integers
    int monthHours = ((monthMinutes - (monthMinutes%60))/60);
    int weekHours = ((weekMinutes - (weekMinutes%60)) / 60);
    [cell.lastMonth setText:[NSString stringWithFormat:@"%d:%02d",monthHours,monthMinutes%60]];
    [cell.lastWeek setText:[NSString stringWithFormat:@"%d:%02d",weekHours,weekMinutes%60]];
    return cell;
}

-(ReviewSummaryCell*)createReviewSummaryCellForTableView:(UITableView*)tableView forIndexPath:(NSIndexPath*)indexPath
{
    //get the correct indicator doc, 
    IndicatorDoc*doc = [[self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1];
    // Set up and customize the cell
    ReviewSummaryCell* cell = (ReviewSummaryCell*) [tableView dequeueReusableCellWithIdentifier:@"ReviewSummaryCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReviewSummaryCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (ReviewSummaryCell*) currentObject;
                break;
            }
        }
    }
    //Title label
    [cell.titleLabel setText:doc.data.title];
    //Last month label
    if ([doc.data.periodValues objectForKey:self.lastMonthKey] == nil) {
        if ([doc.data.type isEqualToString:@"Timer"]) {
            [cell.lastMonth setText:@"0:00"];
        }
        else
            [cell.lastMonth setText:@"0"];
    }
    else
    {
        if ([doc.data.type isEqualToString:@"Timer"]) {
            //format the data into 0:00
            int monthMinutes = [[doc.data.periodValues objectForKey:self.lastMonthKey]floatValue]*60;
            int monthHours = ((monthMinutes - (monthMinutes%60))/60);
            [cell.lastMonth setText:[NSString stringWithFormat:@"%d:%02d",monthHours,monthMinutes%60]];
        }
        else
        {
            [cell.lastMonth setText:[[doc.data.periodValues objectForKey:self.lastMonthKey] description]];
        }
    }
    //Last week label
    if ([doc.data.periodValues objectForKey:self.lastWeekKey] == nil) {
        if ([doc.data.type isEqualToString:@"Timer"]) {
            [cell.lastWeek setText:@"0:00"];
        }
        else
            [cell.lastWeek setText:@"0"];
    }
    else
    {
        if ([doc.data.type isEqualToString:@"Timer"]) {
            //format the data into 0:00
            int weekMinutes = [[doc.data.periodValues objectForKey:self.lastWeekKey]floatValue]*60;
            int weekHours = ((weekMinutes - (weekMinutes%60)) / 60);
            [cell.lastWeek setText:[NSString stringWithFormat:@"%d:%02d",weekHours,weekMinutes%60]];
        }
        else
        {
            [cell.lastWeek setText:[[doc.data.periodValues objectForKey:self.lastWeekKey] description]];
        }
    }
    return cell;
}

-(CategoryReviewCell*)createTimeSummaryCellForTableView:(UITableView*)tableView
{
    // Set up and customize the cell
    CategoryReviewCell* cell = (CategoryReviewCell*) [tableView dequeueReusableCellWithIdentifier:@"CategoryReviewCell"];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CategoryReviewCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) 
        {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) 
            {
                cell = (CategoryReviewCell*) currentObject;
                break;
            }
        }
    }
    //Title Label
    [cell.titleLabel setText:@"Total Time"];
    
    //Get the data
    /*
     * Iterate through all of the indicators in this category, check to see if they are timers, and then add up their values for last month, and last week
     * Then format accordingly
     */
    float lastMonthHours = 0.0f;
    float lastWeekHours = 0.0f;
    NSMutableDictionary* allDocs = [[IndicatorDatabase sharedDatabase] indicatorDocs];
    for (NSString* key in allDocs)
    {
        IndicatorDoc* doc = [allDocs objectForKey:key];
        if ([doc.data.type isEqualToString:@"Timer"]) {
            //add up the hours
            lastMonthHours += [[doc.data.periodValues objectForKey:self.lastMonthKey]floatValue];
            lastWeekHours += [[doc.data.periodValues objectForKey:self.lastWeekKey]floatValue];
        }
    }
    //After this loop has run, the variables lastMonthHours and lastWeekHours should have the total hours from all docs as a float
    //Now calc the number of minutes for simpler display formatting
    int monthMinutes = lastMonthHours*60;
    int weekMinutes = lastWeekHours*60;
    //And edit hours to be integers
    int monthHours = ((monthMinutes - (monthMinutes%60))/60);
    int weekHours = ((weekMinutes - (weekMinutes%60)) / 60);
    [cell.lastMonth setText:[NSString stringWithFormat:@"%d:%02d",monthHours,monthMinutes%60]];
    [cell.lastWeek setText:[NSString stringWithFormat:@"%d:%02d",weekHours,weekMinutes%60]];
    return cell;

}
#pragma mark -
#pragma mark Table view data source

-(void)sortCategories
{
    //put uncategorized at the end if it's found
    //NSLog(@"Sort categories: %@",[self.categories description]);
    NSMutableArray* keys = [NSMutableArray arrayWithArray:[self.categories allKeys]];
    if ([keys indexOfObject:@"Uncategorized"] != NSNotFound) {
        //NSLog(@"keys: %@",[keys description]);
        int uncat = [keys indexOfObject:@"Uncategorized"];
        //NSLog(@"Found uncategorized at index %d",uncat);
        int lastcat = [keys count] -1;
        //NSLog(@"Index of last category is: %d",lastcat);
        NSString* temp = [keys objectAtIndex:lastcat];
        [keys replaceObjectAtIndex:lastcat withObject:@"Uncategorized"];
        [keys replaceObjectAtIndex:uncat withObject:temp];
        //NSLog(@"keys: %@",[keys description]);
    }
    //put scores at the front if it's not already
    int scoresIndex = [keys indexOfObject:kScoresKey];
    if (scoresIndex != 0) {
        //NSLog(@"keys: %@",[keys description]);
        NSString* temp = [keys objectAtIndex:0]; //grab the first category key and store it temporarily
        [keys replaceObjectAtIndex:0 withObject:kScoresKey]; // put the scores key in front
        [keys replaceObjectAtIndex:scoresIndex withObject:temp]; //complete the swap
        //NSLog(@"keys: %@",[keys description]);
    }
    self.categoryKeys = [NSArray arrayWithArray:keys];
    //NSLog(@"Categories sorted: %@",self.categories);
    //NSLog(@"Category Keys: %@",[self.categoryKeys description]);
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
    if (section == 0)
        return 4; //if it's the scores section, which should always be first, return 3, for the 3 rows available
    else
        return [[self.categories valueForKey:[self.categoryKeys objectAtIndex:section]] count]+1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    //NOTE, this could possibly be sped up by bringing all necessary data up in scope to this level, and iterating through the indicators only once, performing all needed calculations then and there, but maybe not-- Tabled for now because the speed is fine
    
    /* The score cells */
    if (indexPath.section == 0) 
    {
        if (indexPath.row == 0) 
        { // The Lifetime Score cell
            return [self createLifetimeCellForTableView:tableView];
        }
        else if (indexPath.row == 1)
        { // The AvgPrevScore cell
            return [self createAvgPrevScoreSummaryCellForTableView:tableView];
        }
        else if (indexPath.row == 2)
        {// CurrentScoreSummaryCell
            return [self createCurrentScoreSummaryCellForTableView:tableView];
        }
        else
        {// Create time summary (CategorySummaryCell)
            return [self createTimeSummaryCellForTableView:tableView];
        }
    } 
    // END section 0 -- The Scores Section
    
    /*Do the first cell of the rest of the sections as CategoryReviewCells*/
    else if (indexPath.row == 0)
    {
        return [self createCategoryReviewCellForTableView:tableView withIndexPath:indexPath];
    }
    else //other sections use reviewSummaryCells
    {
        return [self createReviewSummaryCellForTableView:tableView forIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* 
     * If the indexPath points us to a header of a section other than the scores section, then we set the height
     * to the appropriate value for a categoryReviewCell: 44
     */
    if (indexPath.section != 0 && indexPath.row == 0) //Make we're not working with the scores section here
    {
        return 44.0f;
    }
    else if (indexPath.section == 0 && indexPath.row == 3) // set the Total Time cell to the correct height
        return 44.0f;
    else
        return 50.0f;
    
}

/*
 *  Returns an empty UIView that has width = (width of the table view), and height = 10 points.
 */
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)] autorelease];
    return footerView;
    // NOTE: Returning a UIView that is an empty frame ensures that the footer is a transparent gap.
    // Without this code, there will be an ugly grey bar inbetween the tableView's sections.
    // THOUGHT: The height of 10 is given, because the largest footer is 10. It wouldn't hurt to make the UIView's height a larger number.
}

/*
 *  Returns the height of the footer for the tableView's given section.
 *  This creates a small transparent gap at the end of each section.
 */
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // Create a larger footer if the section is the "Scores" section
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kScoresKey]) {
        return 10.0f;
    }
    else return 4.0f; // Make the footer small for all of the other sections.
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)] autorelease];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = headerView.bounds;
    //Check for Scores section, and make it's background Blue
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kScoresKey])
    {
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:.5f green:.5f blue:1.0f alpha:1.0f] CGColor], (id)[[UIColor blueColor] CGColor], nil];
        [headerView.layer insertSublayer:gradient atIndex:0];
    }
    else
    {
        return nil;
        /*
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
        [headerView.layer insertSublayer:gradient atIndex:0];
         */
    }
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(8, 0, tableView.bounds.size.width - 20, 20)] autorelease];
    label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.85];
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}
//Is this really delegate related? or data related
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.categoryKeys objectAtIndex:section] isEqualToString:kScoresKey]) {
        return 22.0f;
    }
    else return 0.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Determine the touch location
    if (indexPath.section == 0) { //if it's the scores section
        //Display a Lifetime Score graph if the lifetime score gets tapped
        if (indexPath.row == 0) {
            //Init the GraphDetail view and label it as a Lifetime Score graph
            self.graphDetailView = [[[GraphDetailView alloc] init] autorelease];
            self.graphDetailView.type = @"Lifetime Score";
            //send the indicator to the detail view
            [[self navigationController] pushViewController:self.graphDetailView animated:NO];
        }
        //Display a Score graph if the average score cell gets tapped
        if (indexPath.row == 1) {
            //Init the GraphDetail view and label it as a score graph
            self.graphDetailView = [[[GraphDetailView alloc] init] autorelease];
            self.graphDetailView.type = @"Score";
            //send the indicator to the detail view
            [[self navigationController] pushViewController:self.graphDetailView animated:NO];
        }
        //Go to a categorical pie chart if the Total Time cell is tapped
        if (indexPath.row == 3) {
            //Create the chartDeailView
            self.chartDetailView = [[[ChartDetailView alloc] init] autorelease];
            self.chartDetailView.category = allCategoriesKey;
            self.chartDetailView.dateKey = self.lastWeekKey;
            [MBProgressHUD showHUDAddedTo:self.chartDetailView.view animated:NO];
            [[self navigationController] pushViewController:self.chartDetailView animated:NO];
        }
        

    }
    
    /* If it's the first row of any section other than 0, go to the pie chart*/
    else if (indexPath.row == 0)
    {
        //Create the chartDeailView
        self.chartDetailView = [[[ChartDetailView alloc] init] autorelease];
        self.chartDetailView.category = [self.categoryKeys objectAtIndex:indexPath.section];
        self.chartDetailView.dateKey = self.lastWeekKey;
        [MBProgressHUD showHUDAddedTo:self.chartDetailView.view animated:NO];
        [[self navigationController] pushViewController:self.chartDetailView animated:NO];
    }
    else
    {
        //Get the Indicator Doc associated with the tapped row
        IndicatorDoc *doc = [[self.categories objectForKey:[self.categoryKeys objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row-1];
        //Init the GraphDetail view
        self.graphDetailView = [[[GraphDetailView alloc] init] autorelease];
        self.graphDetailView.indicatorDoc = doc;
        self.graphDetailView.type = @"Indicator";
        //send the indicator to the detail view
        [[self navigationController] pushViewController:self.graphDetailView animated:NO];
    }
}

@end