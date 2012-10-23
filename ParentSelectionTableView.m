//
//  ParentSelectionTableView.m
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParentSelectionTableView.h"

@implementation ParentSelectionTableView

//@synthesize indicators = _indicators;
@synthesize indicatorDoc = _indicatorDoc;
@synthesize legalParents = _legalParents;

#pragma mark -
#pragma mark Helpers

-(NSMutableArray*)legalParentsMethod
{
	//init the array of legal parents
	NSMutableArray* legals = [[NSMutableArray alloc] initWithCapacity:1];
	//iterate through possible indicators and make comparisons
	for (int i = 0; i < [IndicatorDatabase sharedDatabase].categoryDocs.count; i++) 
	{
		NSArray *keyArray =  [[IndicatorDatabase sharedDatabase].categoryDocs allKeys];
		IndicatorDoc *doc = [[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:[keyArray objectAtIndex:i]];
        
		if ([doc.data.type isEqualToString:@"Category"]) 
		{
			//If the doc is of type category, then it is a legal parent
			[legals addObject:[[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:[keyArray objectAtIndex:i]]];
		}
		
	}
	return legals;
	
}		

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//get legal parents list
	/*
    if (_legalParents == nil) {
        NSLog(@"init legal parents");
		self.legalParents = [[NSMutableArray alloc] initWithCapacity:1];
	}
     */
	_legalParents = [self legalParentsMethod];
	self.title = @"Select Parent";
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _legalParents.count + 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.row == 0) {
		cell.textLabel.text = @"None";
	}
	else {
        
        int activeRow = indexPath.row - 1;
        IndicatorDoc *doc = [_legalParents objectAtIndex:activeRow];
        cell.textLabel.text = doc.data.title;
        if ([_indicatorDoc.data.childOf isEqualToNumber:doc.data.key]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
	}
	
	
    return cell;
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Navigation logic may go here. Create and push another view controller.
	
	//--- if the first cell is selected, clear the hierarchy
	if (indexPath.row == 0) {
		//check for a relationship
		if (_indicatorDoc.data.childOf == nil) {
			// do nothing
		}
		else {
			//remove from parent's children array
            //NSLog(@"removing Child with key: %@", [_indicatorDoc.data.key description]);
			IndicatorDoc* parentDoc = [[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:_indicatorDoc.data.childOf];
            //NSLog(@"Parent: %@",parentDoc.data.title);
			int indexOfChild = [parentDoc.data.children indexOfObject:_indicatorDoc.data.key];
            //NSLog(@"Children Array Contains: %@", [parentDoc.data.children description]);
            //NSLog(@"indexofChild: %i", indexOfChild );
            //NSLog(@"key at that index: %@",[[parentDoc.data.children objectAtIndex:indexOfChild] description]);
			[parentDoc.data.children removeObjectAtIndex:indexOfChild];
            //NSLog(@"keys left in the array after removal: %@",[parentDoc.data.children description]);
            //remove parent from child's childOf property
            _indicatorDoc.data.childOf = nil;
            //save the data
			[_indicatorDoc saveData];
            [parentDoc saveData];
		}
		//pop the view
		[self.navigationController popViewControllerAnimated:YES];
	}//end, if None selected
	
    else 
	{
        
		//get the parent
		IndicatorDoc* parentDoc = [_legalParents objectAtIndex:indexPath.row-1];
		
		//check to see if already child, if not then add the child to parent, and the parent to the child
		if (![_indicatorDoc.data.childOf isEqualToNumber:parentDoc.data.key]) 
		{
			//remove the child from it's old parent if it had one
            if (_indicatorDoc.data.childOf != nil) {
                IndicatorDoc* parentDoc = [[IndicatorDatabase sharedDatabase].categoryDocs objectForKey:_indicatorDoc.data.childOf];
                int indexOfChild = [parentDoc.data.children indexOfObject:_indicatorDoc.data.key];
                [parentDoc.data.children removeObjectAtIndex:indexOfChild];
                [parentDoc saveData];
                
            }
            
			//----add the child to the parent----
			if (parentDoc.data.children == nil)
			{
				parentDoc.data.children = [[NSMutableArray alloc] initWithCapacity:1];
			}
			[parentDoc.data.children addObject:_indicatorDoc.data.key];

			//----add the parent to the child----
			_indicatorDoc.data.childOf = parentDoc.data.key;
            
			//save data
			[_indicatorDoc saveData];
			[parentDoc saveData];
		}//end, If not already child
        
        //save data again and pop view
        [_indicatorDoc saveData];
		[self.navigationController popViewControllerAnimated:YES];
		
	}
	
	
}
	
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	//self.legalParents = nil;
	
	
}


- (void)dealloc {
	[_indicatorDoc release];
	_indicatorDoc = nil;
	[_legalParents release];
	_legalParents = nil;
    [super dealloc];
}


@end

