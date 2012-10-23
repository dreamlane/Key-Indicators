//
//  DashboardViewController.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewController.h"

@implementation DashboardViewController

@synthesize tmpTableView = _tmpTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - TableViewMethods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"IndicatorSummaryCell";
    IndicatorSummaryCell* cell = (IndicatorSummaryCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"IndicatorSummaryCell" 
                                                                 owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (IndicatorSummaryCell*) currentObject;
                break;
            }
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
