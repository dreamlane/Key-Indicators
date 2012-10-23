//
//  AddValueView.m
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddValueView.h"



@implementation AddValueView

//@synthesize titleLabel = _titleLabel;//Maybe remove
@synthesize valueLabel = _valueLabel;
@synthesize	valueToBeAddedField = _valueToBeAddedField;
@synthesize indicatorDoc = _indicatorDoc;

-(void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
											  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
											  target:self action:@selector(cancelButtonPressed:)] autorelease];
	if ([_indicatorDoc.data.type isEqualToString:@"Timer"]) {
		_valueLabel.text = @"Hours:";
		self.title = @"Add Hours";
		_valueToBeAddedField.text = [NSString stringWithFormat:@"%1.2f",_indicatorDoc.hoursToBeAdded];
        //NSLog(@"Hours to be added = %1.2f",_indicatorDoc.hoursToBeAdded);
	}
	else {
		_valueLabel.text = @"Tallies:"; 
		self.title = @"Add Tallies:";
		_valueToBeAddedField.text = @"0";
	}
	[super viewWillAppear:animated];
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark Interface Actions
-(IBAction)saveButtonPressed:(id)sender
{
	//save the values and pop the screen---
	//get float from text value
	float valueToAdd = [_valueToBeAddedField.text floatValue];
	
	//----make an entry----
	//init the entry arrays if nesc.
	if (_indicatorDoc.data.dailyActuals == nil) {
        //NSLog(@"Initing Daily Actuals dictionary in add value view");
		self.indicatorDoc.data.dailyActuals = [[NSMutableDictionary alloc] initWithCapacity:1];
	}
    //determine the correct key
    NSString* dateKey = [IndicatorDatabase dateKey]; //Get the date key for the current date
    //check for an entry that already exists
    if ([_indicatorDoc.data.dailyActuals objectForKey:dateKey]) 	
    {
        //update the entry
        float curVal = [[_indicatorDoc.data.dailyActuals objectForKey:dateKey] floatValue];
        float newVal = valueToAdd + curVal;
        [_indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:newVal] forKey:dateKey];
    }
    else
    {
        //make a new entry for the day
        [_indicatorDoc.data.dailyActuals setObject:[NSNumber numberWithFloat:valueToAdd] forKey:dateKey];
    }
	valueToAdd = 0.0;
	_indicatorDoc.hoursToBeAdded = 0.0;
	[_valueToBeAddedField resignFirstResponder];
    //Recalculate the scores
    [_indicatorDoc updateScoreForKey:[DateRange keyFromDateRange:[DateRange currentWeek]]];
    [_indicatorDoc updateScoreForKey:[DateRange keyFromDateRange:[DateRange currentMonth]]];
	//Save the data
	[_indicatorDoc saveData];
    //Recalc the total score
    [[IndicatorDatabase sharedDatabase] updateLifetimeScore];
	//pop the screen
	[self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)cancelButtonPressed:(id)sender
{
	//cancel logic
	//clear value to be added
	_indicatorDoc.hoursToBeAdded = 0;
	//clear the start date
	_indicatorDoc.data.startDate = nil;
	//pop the view
	[self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)valueToBeAddedFieldSelected:(id)sender
{
	_valueToBeAddedField.text = @"";
}
-(IBAction)valueToBeAddedChanged:(id)sender
{
	//get the changed value
	float inputValue = [_valueToBeAddedField.text floatValue];
	//put it back out correctly
    if ([_indicatorDoc.data.type isEqualToString:@"Timer"]) {
         _valueToBeAddedField.text = [NSString stringWithFormat:@"%1.2f",inputValue];
    }
    else if ([_indicatorDoc.data.type isEqualToString:@"Tally"]){
        _valueToBeAddedField.text = [NSString stringWithFormat:@"%1.0f",inputValue];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.valueLabel = nil;
	self.valueToBeAddedField = nil;
}


- (void)dealloc {
	[_valueLabel release];
	_valueLabel = nil;
	[_valueToBeAddedField release];
	_valueToBeAddedField = nil;
	//[_titleLabel release];
	//_titleLabel = nil;
    [super dealloc];
}


@end
