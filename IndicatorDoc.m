//
//  IndicatorDoc.m
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IndicatorDoc.h"

#define kDataKey		@"Data"
#define	kDataFile		@"data.plist"
#define scoreMultiplier 100
@implementation IndicatorDoc

//@synthesize indicators = _indicators;
@synthesize docPath = _docPath;
@synthesize data = _data;
@synthesize hoursToBeAdded = _hoursToBeAdded; //used for the timer widget and Add Time button
@synthesize minutesToBeAdded = _minutesToBeAdded; // ' '
@synthesize isNewDoc = _isNewDoc;

-(id) init
{
	if ((self = [super init]))
	{
		
	}
	return self;
}

-(id) initWithDocPath:(NSString*)docPath 
{
	if ((self = [super init])) 
	{
		_docPath = [docPath copy];
	}
	return self;
}

-(id) initWithIndicatorData:(IndicatorData*)data
{
	if ((self = [super init])) {
		_data = data;
	}
	return self;
}

#pragma mark -
#pragma mark Value Calculators

// THIS method would be easier if it could be assumed that the scores are all updated, so Assumption made
-(float)maximumScoreWithKey:(NSString*)key
{
    return scoreMultiplier*(self.data.weightBase+[[self.data.periodWeightModifiers objectForKey:key] floatValue]);
}

// It may be better to replace this with a stored value that is calculated only once a score has changed, and integrate it in the updateScoreForKey method, same for the average scores
-(float)totalScore
{
    float weekTotal = 0.0f;
    float monthTotal = 0.0f;
    for (NSString* key in [self.data.periodScores allKeys])
    {
        if ([DateRange isWeekKey:key]) {
            weekTotal += [[self.data.periodScores objectForKey:key] floatValue];
        }
        else
        {
            monthTotal += [[self.data.periodScores objectForKey:key] floatValue];
        }
    }
    return ((weekTotal + monthTotal)/2);
}

/* 
 * Updates the score for the current period for the current indicator
 * This should be called every time a goal or actual or priority is changed
 */
-(void)updateScoreForKey:(NSString*)key
{
    //if the scores dictionary is not yet initialized, do it now
    if (self.data.periodScores == nil) 
    {
        //NSLog(@"initing periodScores dict");
        self.data.periodScores = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    
    // Calculate the score
    NSNumber* goal = [self.data.periodGoals objectForKey:key];
    NSString* lastPeriodKey = [DateRange keyForPeriodPriorToKey:key];
    NSNumber* lastPeriodGoal = [self.data.periodGoals objectForKey:lastPeriodKey];
    NSNumber* lastPeriodModifier;
    float weightBase;
    NSNumber* weightModifier;
    float totalWeight = 0.0f;
    
    // Set up the base weight and modifier weights appropriately
    // BASE   
    weightBase = self.data.weightBase;
    
    //MODIFIER
    //check to see if the previous period's modifier is set
    if ([self.data.periodWeightModifiers objectForKey:lastPeriodKey] == nil) 
    {
        // if not, set last week's modifier to 0
        //NSLog(@"Last period's weightModifier is not set");
        [self.data.periodWeightModifiers setValue:[NSNumber numberWithFloat:0.0f] forKey:lastPeriodKey];
    }
    //get the previous modifier
    lastPeriodModifier = [self.data.periodWeightModifiers objectForKey:lastPeriodKey];
    //NSLog(@"last period's weightModifier: %1.2f", [lastPeriodModifier floatValue]);
    // Set the current modifier ---
    //determine if the modifier needs to be upped or downed
    //make sure there is a goal for last period, and that it was not 0
    if (lastPeriodGoal != nil && [lastPeriodGoal floatValue] != 0.00f) {
        //compare the present goal with the previous goal, if the present goal is greater, then increase the modifier
        if ([goal floatValue] > [lastPeriodGoal floatValue]) 
        {
            //set the modifier, by adding .05f to the previous modifier
            weightModifier = [NSNumber numberWithFloat:[lastPeriodModifier floatValue] + .05f];
        }
        else if ([goal floatValue] < [lastPeriodGoal floatValue])
        {
            //set the modifier by subtracting .05f fromt the previous modifier
            weightModifier = [NSNumber numberWithFloat:[lastPeriodModifier floatValue] - .05f];
        }
        else
        {
            //set the modifier to be exactly the same as the previous modifier
            weightModifier = [NSNumber numberWithFloat:[lastPeriodModifier floatValue]];
        }
    }
    else // if the last period has no goal, then set the modifier to be 0.0f This resets the streak modifier when a goal is unset
        weightModifier = [NSNumber numberWithFloat:0.0f];
    
    //modifier is set, and base is set, add them together to get the actual total weight
    //NSLog(@"Base is: %1.2f, Modifier is: %1.2f",weightBase,[weightModifier floatValue]);
    totalWeight = weightBase + [weightModifier floatValue];
    
    //first make sure that the goal is not 0 and that there exists a goal for the key
    if (goal != nil && [goal floatValue] != 0.0f)
    {
        //Perform the score calculation
        //inverse goals
        if (self.data.isInverseGoal) 
        {
            float i = [goal floatValue]/[self periodValueWithKey:key];
            if (i < .5f) {
                float score = -1.0f*scoreMultiplier*totalWeight;
                //NSLog(@"Inverse, i is: %1.2f, score is: %1.2f",i,score);
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
            }
            else if (i < 1) {
                float score = ((1.8f*(i-.5)/.5f)-1)*scoreMultiplier*totalWeight;
                //NSLog(@"Inverse, i is: %1.2f, score is: %1.2f",i,score);
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
            }
            else if (i < 2) {
                float score = (.2*(i-1)+.8)*scoreMultiplier*totalWeight;
                //NSLog(@"Inverse, i is: %1.2f, score is: %1.2f",i,score);
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
            }
            else {
                float score = 1*scoreMultiplier*totalWeight;
                //NSLog(@"Inverse, i is: %1.2f, score is: %1.2f",i,score);
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
            }
        }
        //standard goals
        else {
            float i = [self periodValueWithKey:key]/[goal floatValue];
            if (i < .85) {
                //NSLog(@"<1");
                float score = ((.85f*i)/1.0f)*scoreMultiplier*totalWeight;
                //NSLog(@"Standard, i is: %1.2f, score is: %1.2f, scoreMult is %d, totalWeight is: %1.2f",i,score,scoreMultiplier,totalWeight);
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
            }
            else {
                float score = 1*scoreMultiplier*totalWeight;
                [self.data.periodScores setValue:[NSNumber numberWithFloat:score] forKey:key];
                
            }
        }
    }
    else if (goal == nil) {
        //NSLog(@"Goal is nil");
        [self.data.periodGoals setValue:[NSNumber numberWithFloat:0.0f] forKey:key];
        [self.data.periodScores setValue:[NSNumber numberWithFloat:-0.5f*scoreMultiplier*totalWeight] forKey:key];        
    }
    else //No goal = negative points
    {
        //NSLog(@"Else goal");
        [self.data.periodScores setValue:[NSNumber numberWithFloat:-0.5f*scoreMultiplier*totalWeight] forKey:key];
    }

    [self saveData];
}

-(float)periodValueWithKey:(NSString*)key
{
    float selfTotal = 0;   
    NSArray* dates = [self getPeriodDaysWithKey:key]; //get the array of date keys       
    for (NSString *day in dates) {
        float dayValue = [[_data.dailyActuals valueForKey:day]  floatValue];
        selfTotal += dayValue;
        //NSLog(@"Day: %@",day);
    }
    return selfTotal;
}
-(float)selfValue
{
    //NSLog(@"Calcing self Value");
	float sum = 0.0;
    NSArray* keys = [_data.dailyActuals allKeys]; //get all the keys in the daily value dictionary 
	//iterate through all keys
	for (NSString *key in keys) {
		sum += [[_data.dailyActuals objectForKey:key] floatValue];
        //NSLog(@"Key is: %@",key);
	}
	return sum;
}

/* REMOVED
-(float)childrenHours
{
	//NSLog(@"Calcing Children: %@", [_data.children description]);
	float childrenTotal = 0.0;
	for (int i= 0; i < _data.children.count; i++) 
	{
		NSNumber* tmpKey = [self.data.children objectAtIndex:i];
		IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
		//NSLog(@"Accessing %@ : %i's child with ID: %i and title: %@",_data.title,[_data.key intValue],[tmpKey intValue],tmpDoc.data.title);
		//calculate their total values
        if ([tmpDoc.data.type isEqualToString:@"Timer"]) 
        {
            NSArray* keys = [tmpDoc.data.dailyActuals allKeys]; // Get all the keys from the child's daily actuals dictionary
            for (NSString* key in keys) 
            {
                childrenTotal+= [[tmpDoc.data.dailyActuals objectForKey:key] floatValue];
            }
        }
		
	}
	return childrenTotal;
}

-(float)childrenPeriodHours
{
	float childrenTotal = 0.0;
    if (_data.children.count != 0) 
    {
        NSArray* dates = [self getPeriodDays]; //Get the period days based on the categorical goal
        for (int i= 0; i < _data.children.count; i++) 
        {
            NSNumber* tmpKey = [self.data.children objectAtIndex:i];
            IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
            
            if ([tmpDoc.data.type isEqualToString:@"Timer"]) 
            {
                //calculate their total values
                for (NSString* day in dates)
                {
                    NSLog(@"Day: %@",day);
                    childrenTotal += [[tmpDoc.data.dailyActuals objectForKey:day] floatValue];
                }
            }
        }
        [dates release];
    }
    return childrenTotal;
}

-(float)childrenTallies
{
	//NSLog(@"Calcing Children: %@", [_data.children description]);
	float childrenTotal = 0.0;
	for (int i= 0; i < _data.children.count; i++) 
	{
		NSNumber* tmpKey = [self.data.children objectAtIndex:i];
		IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
		//NSLog(@"Accessing %@ : %i's child with ID: %i and title: %@",_data.title,[_data.key intValue],[tmpKey intValue],tmpDoc.data.title);
		//calculate their total values
        if ([tmpDoc.data.type isEqualToString:@"Tally"]) 
        {
            NSArray* keys = [tmpDoc.data.dailyActuals allKeys]; // Get all the keys from the child's daily actuals dictionary
            for (NSString* key in keys) 
            {
                childrenTotal+= [[tmpDoc.data.dailyActuals objectForKey:key] floatValue];
            }
        }
		
	}
	return childrenTotal;
}


-(float)childrenPeriodTallies
{
	float childrenTotal = 0.0;
    if (_data.children.count != 0)
    {
        NSArray* dates = [self getPeriodDays]; //Get the period days based on the categorical goal
        for (int i= 0; i < _data.children.count; i++) 
        {
            NSNumber* tmpKey = [self.data.children objectAtIndex:i];
            IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
            
            if ([tmpDoc.data.type isEqualToString:@"Tally"]) //This is needed because some children are not Tally children
            {
                //calculate their total values
                for (NSString* day in dates)
                {
                    childrenTotal += [[tmpDoc.data.dailyActuals objectForKey:day] floatValue];
                }
            }
        }
        [dates release];
    }
    return childrenTotal;
}
 */

/*
 * NOTE: Temporarily removed to simplify the app
 *
-(float)childrenWeekHoursGoal
{
    float totalGoal = 0.0;
    NSString* rangeKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
    //iterate through the children
    for (int i= 0; i < _data.children.count; i++) 
	{
		NSNumber* tmpKey = [self.data.children objectAtIndex:i];
		IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
        
        if ([tmpDoc.data.type isEqualToString:@"Timer"]) {
            //get it's goal
            float weeklyGoal = [[tmpDoc.data.periodGoals objectForKey:rangeKey] floatValue];
            totalGoal += weeklyGoal;
        }
    }
    return totalGoal;
}

-(float)childrenWeekTalliesGoal
{
    float totalGoal = 0.0;
    NSString* rangeKey = [DateRange keyFromDateRange:[DateRange currentWeek]];
    //iterate through the children
    for (int i= 0; i < _data.children.count; i++) 
	{
		NSNumber* tmpKey = [self.data.children objectAtIndex:i];
		IndicatorDoc* tmpDoc = [[IndicatorDatabase sharedDatabase].indicatorDocs objectForKey:tmpKey];
        
        if ([tmpDoc.data.type isEqualToString:@"Tally"]) {
            //get it's goal
            float weeklyGoal = [[tmpDoc.data.periodGoals objectForKey:rangeKey] floatValue];
            totalGoal += weeklyGoal;
        }
    }
    return totalGoal;
}
*/
#pragma mark Helpers
/*
-(NSArray*)getPeriodDays
{
    //NSLog(@"Getting the period days");
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"]; // Just get the days
    NSDate *today = [NSDate date]; // get todays date
    NSCalendar *cal = [NSCalendar currentCalendar]; // needed to work with components
    if (_data.isMonthIndicator == YES) // Grab all days from the month
    {
        //NSLog(@"Getting Month Period Days");
        NSDateComponents *components = [cal components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:today];
        NSUInteger day = [components day];
        for (NSUInteger i=day; i>0; i--) {
            // loop through all days till down to 1
            [components setDay:i]; // update the day in the components
            NSDate *date = [cal dateFromComponents:components]; 
            [dates addObject:[fmt stringFromDate:date]]; // add the new date to the array as a string
        }
    }
    else // Grab all days from the week
    {
        //NSLog(@"Getting Week Period Days");
        // start of the week
        NSDate * firstDay;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [cal rangeOfUnit:NSWeekCalendarUnit
               startDate:&firstDay
                interval:0
                 forDate:today];
        for (NSUInteger i=0; i<7; i++) {
            // grab 7 days including the start of the week
            [components setDay:i]; // update the day in the components
            NSDate *date = [cal dateByAddingComponents:components toDate:firstDay options:0]; //get the next day in the week iteratively
            [dates addObject:[fmt stringFromDate:date]]; // add the new date to the array
        }
        [components release];
    }
    [fmt release];
    return dates;
}
*/
-(NSArray*)getPeriodDaysWithKey:(NSString*)key
{
    //NSLog(@"Getting the period days");
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:1];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // Just get the days
    
    //split the string into start and end dates
    NSDate* startDate = [fmt dateFromString:[key substringToIndex:(19)]];
    NSDate* endDate = [fmt dateFromString:[key substringFromIndex:(19)]];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *cal = [NSCalendar currentCalendar]; // needed to work with components
    if (![DateRange isWeekKey:key]) // Grab all days from the month
    {
        //NSLog(@"Getting Month Period Days");
        NSDateComponents *components = [cal components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:[endDate dateByAddingTimeInterval:-24*60*60]];
        NSUInteger day = [components day];
        for (NSUInteger i=day; i>0; i--) {
            // loop through all days till down to 1
            [components setDay:i]; // update the day in the components
            NSDate *date = [cal dateFromComponents:components]; 
            [dates addObject:[fmt stringFromDate:date]]; // add the new date to the array as a string
        }
    }
    else // Grab all days from the week
    {
        //NSLog(@"Getting Week Period Days");
        // start of the week
        NSDate * firstDay;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [cal rangeOfUnit:NSWeekCalendarUnit
               startDate:&firstDay
                interval:0
                 forDate:startDate];
        for (NSUInteger i=0; i<7; i++) {
            // grab 7 days including the start of the week
            [components setDay:i]; // update the day in the components
            NSDate *date = [cal dateByAddingComponents:components toDate:firstDay options:0]; //get the next day in the week iteratively
            [dates addObject:[fmt stringFromDate:date]]; // add the new date to the array
        }
        [components release];
    }
    [fmt release];
    return dates;
}

#pragma mark Generic Data Load/Save Code
-(IndicatorData*)data
{
	if (_data != nil) return _data;
	
	NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[[NSData alloc] initWithContentsOfFile:dataPath] autorelease];
    if (codedData == nil) return nil;
	
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [[unarchiver decodeObjectForKey:kDataKey] retain];    
    [unarchiver finishDecoding];
    [unarchiver release];

    return _data;
	
}

- (BOOL)createDataPath {
	
    if (_docPath == nil) {
        self.docPath = [IndicatorDatabase nextIndicatorDocPath];
    }
	
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        //NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
	
}

- (void)saveData {
	
    if (_data == nil) return;
	//NSLog(@"Saving");
    [self createDataPath];
	
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];          
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
    [archiver release];
    [data release];
	[[IndicatorDatabase sharedDatabase] update];
}


- (void)deleteDoc {
	
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_docPath error:&error];
    if (!success) {
        //NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
	
}

-(void)dealloc {
	[_data release];
	_data = nil;
	[_docPath release];
	_docPath = nil;
	//[_indicators release];
	//_indicators = nil;
	[super dealloc];
}

@end
