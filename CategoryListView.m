//
//  CategoryListView.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoryListView.h"

// THIS FILE IS DEPRECATED< AND SHOULD BE REMOVED SOON
@implementation CategoryListView

@synthesize categoryDetailView = _categoryDetailView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.categoryDetailView = nil;
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
											   target:self action:@selector(showActionSheet:)] autorelease];
	self.title = @"Categories";

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[IndicatorDatabase sharedDatabase].categoryDocs count];
}

//customize the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get the Category IndicatorDoc for the current row
	NSArray *keyArray =  [[IndicatorDatabase sharedDatabase].categoryDocs allKeys];
    IndicatorDoc *doc = [[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:[keyArray objectAtIndex:indexPath.row]];
    
    //Do some cool stuff that I don't understand, but it appears to be the correct way to do things
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
    
    // Configure the cell...
    //Set the Label Text
    cell.categoryLabel.text = doc.data.title;
    
    //INSERT ICON LOGIC HERE
    
    //Fill the progress bars
    //TODO: Consider a solution for implementing inverse goals into this equation. 
    //NOTE: Category views are all under reconstruction
    //Timer
    //cell.timeProgressView.progress = ([doc childrenPeriodHours]/[doc childrenWeekHoursGoal]);
    //Tally
    //cell.tallyProgressView.progress = ([doc childrenWeekTallies]/[doc childrenWeekTalliesGoal]);
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get the Indicator Doc associated with the tapped row
	NSArray *keyArray =  [[IndicatorDatabase sharedDatabase].categoryDocs allKeys];
    IndicatorDoc *doc = [[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:[keyArray objectAtIndex:indexPath.row]];
	//initialize the Category Detail View
    if (_categoryDetailView == nil) {
        self.categoryDetailView = [[CategoryDetailView alloc] initWithNibName:@"CategoryDetailView" bundle:[NSBundle mainBundle]];
    }
    //send the indicator to the detail view
    self.categoryDetailView.indicatorDoc = doc;
    [self.navigationController pushViewController:_categoryDetailView animated:YES];
}

#pragma mark - interface actions

-(IBAction)showActionSheet:(id)sender
{
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] 
                                 initWithTitle:@"New Category" delegate:self 
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Category", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
    [popupQuery showInView:self.parentViewController.tabBarController.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {//Category
		IndicatorData* defaultData =[IndicatorData defaultDataWithType:@"Category"];
		IndicatorDoc* newDoc = [[IndicatorDoc alloc] initWithIndicatorData:defaultData];
		[[IndicatorDatabase sharedDatabase].indicatorDocs setObject:newDoc forKey:newDoc.data.key];
		[newDoc saveData];
        if (_categoryDetailView == nil) {
            self.categoryDetailView = [[CategoryDetailView alloc] initWithNibName:@"CategoryDetailView" bundle:[NSBundle mainBundle]];
        }
        self.categoryDetailView.indicatorDoc = newDoc;
        [self.navigationController pushViewController:_categoryDetailView animated:YES];
        
	}

}

@end
