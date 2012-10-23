//
//  IndicatorDatabase.m
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IndicatorDatabase.h"
#import "IndicatorDoc.h"

static IndicatorDatabase* sharedDatabase = nil;

@implementation IndicatorDatabase

@synthesize indicatorDocs = _indicatorDocs;
//@synthesize categoryDocs = _categoryDocs; //REMOVED
@synthesize badgeNumber = _badgeNumber;
@synthesize categories = _categories;
@synthesize lifetimeTotal = _lifetimeTotal;
@synthesize weekAverageScore = _weekAverageScore;
@synthesize monthAverageScore = _monthAverageScore;

#define kScoreKey @"lifetimeScore"
#define kMonthAverageKey @"monthlyAverage"
#define kWeekAverageKey @"weeklyAverage"

//returns the singleton instance
+(IndicatorDatabase*)sharedDatabase
{
    @synchronized(self) {		
        if (sharedDatabase == nil) {
            sharedDatabase = [[super allocWithZone:NULL] init]; // assignment not done here
        }
    }
    return sharedDatabase;
}

+ (id)allocWithZone:(NSZone *)zone
{
        if (sharedDatabase == nil) {
            return [[self sharedDatabase] retain];  // assignment and return on first allocation
    }
    return nil; //on subsequent allocation attempts return nil
}

//inits the singleton instance
-(id)init
{	
	if ( (self = [super init])) 
	{
        //NSLog(@"Init IndicatorDatabase");
		//Load the lifetime scores
        NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
        self.lifetimeTotal = [prefs floatForKey:kScoreKey];
        self.weekAverageScore = [prefs floatForKey:kWeekAverageKey];
        self.monthAverageScore = [prefs floatForKey:kMonthAverageKey];
		//initialize the Data
        self.badgeNumber = 0;
        // the following three methods do the same things quite a bit, maybe they should be consolodated
		self.indicatorDocs = [self loadIndicatorDocs]; 
        //self.categoryDocs = [self loadCategoryDocs]; //to be removed
        self.categories = [self loadCategories]; //get all of the categories by reading all of the docs' categories.
        
        
		//NSLog(@"Database contains indicators: %@",[self.indicatorDocs description]);
        //NSLog(@"Databade contains newCategories: %@",[self.categories description]);
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:_badgeNumber];
		//temporary variables:
		//using NSUserDefaults
		//read the User Defaults plist
		//NSDictionary *plistInfo = [self readPlist:@"SavedData"];
		//[NSUserDefaults resetStandardUserDefaults];
		//NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		//[prefs registerDefaults:plistInfo];
		
		//self.musicOn = [prefs boolForKey:@"musicOn"];
		//self.sfxOn = [prefs boolForKey:@"sfxOn"];
		//self.voiceOn = [prefs boolForKey:@"voiceOn"];
				
		
		
	}
	return self;
}

+(NSString*)getPrivateDocsDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"Private Documents"];
	
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];   
	
    return documentsDirectory;
	
}

+ (NSString *)nextIndicatorDocPath {
	
    // Get private docs directory
    NSString *documentsDirectory = [IndicatorDatabase getPrivateDocsDir];
	
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        //NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
	
    // Search for an available name
    int maxNumber = 0;
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"indicator" options:NSCaseInsensitiveSearch] == NSOrderedSame) {            
            NSString *fileName = [file stringByDeletingPathExtension];
			//NSLog(@"Got available filename: %@",fileName);
            maxNumber = MAX(maxNumber, fileName.intValue);
        }
    }
	
    // Get available name
    NSString *availableName = [NSString stringWithFormat:@"%d.indicator", maxNumber+1];
    return [documentsDirectory stringByAppendingPathComponent:availableName];
	
}
//Only run this when saving data, it may take some time

-(void)updateLifetimeScore
{
    //Calculate and save total and average scores
    float totalScore = 0.0f;
    float monthlyAverage = 0.0f;
    float weeklyAverage = 0.0f;
    float maxMonths = 0.0f;
    float maxWeeks = 0.0f;
    //float docCount = (float)[[self.indicatorDocs allKeys] count]; //un-needed unless want to find average score per indicator
    for (NSString* key in [self.indicatorDocs allKeys])
    {
        
        IndicatorDoc* doc = [self.indicatorDocs objectForKey:key];
        //Total score addition
        totalScore += [doc totalScore];
        //averages
        float monthsTotal = 0.0f;
        float numberMonths = 0.0f;
        float weeksTotal = 0.0f;
        float numberWeeks = 0.0f;
        
        for (NSString* dateKey in [doc.data.periodScores allKeys]) {
            if (![DateRange isWeekKey:dateKey]) 
            { //if it's a month key
                // Make sure that it is not this month's key
                if (![dateKey isEqualToString:[DateRange keyFromDateRange:[DateRange currentMonth]]]) 
                {
                    monthsTotal += [[doc.data.periodScores objectForKey:dateKey] floatValue];
                    numberMonths += 1.0f; // Note that some indicators have less than the total number of months tracked, so they get divided by less months...BUG
                    // Fix the bug by recording a max months
                    if (numberMonths > maxMonths)
                        maxMonths = numberMonths;
                    //NSLog(@"number of months is: %1.0f",numberMonths);
                    //NSLog(@"monthsTotal is: %1.0f",monthsTotal);
                }
            }
            else //week key
            {
                if (![dateKey isEqualToString:[DateRange keyFromDateRange:[DateRange currentWeek]]])
                {
                    weeksTotal += [[doc.data.periodScores objectForKey:dateKey] floatValue];
                    numberWeeks += 1.0f;
                    if (numberWeeks > maxWeeks)
                        maxWeeks = numberWeeks;
                }
            }
        }
        if (numberMonths != 0.0f) {
            monthlyAverage += monthsTotal/maxMonths;
            //NSLog(@"Monthly sum is :%1.0f",monthlyAverage);
        }
        if (numberWeeks != 0.0f) {
            weeklyAverage += weeksTotal/maxWeeks;
        }

    }
    //save the data to NSUserDefaults
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    [prefs setFloat:totalScore forKey:kScoreKey];
    [prefs setFloat:monthlyAverage forKey:kMonthAverageKey];
    [prefs setFloat:weeklyAverage forKey:kWeekAverageKey];
}

#pragma mark - Loading methods
/*
 * Returns an array of IndicatorDocs that have their category field equal to the passed category parameter
 *
 */
-(NSMutableArray*)loadIndicatorsWithCategory:(NSString*)category
{
    NSMutableArray* categorizedDocs = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary* docs = [IndicatorDatabase  sharedDatabase].indicatorDocs;
    for (NSString* key in [docs allKeys]) 
    {
        IndicatorDoc* doc = [docs objectForKey:key];
        //NSLog(@"testing to see if %@ is equal to %@",doc.data.category,category);
        if ([doc.data.category isEqualToString:category])
        {
            [categorizedDocs addObject:doc];
           // NSLog(@"Added object: %@", [doc description]);
        }
    }
    //NSLog(@"For loop complete");
    return categorizedDocs;
}

-(NSMutableDictionary*)loadIndicatorDocs
{
	// Get private docs dir
    NSString *documentsDirectory = [IndicatorDatabase getPrivateDocsDir];
    //NSLog(@"Loading indicators from %@", documentsDirectory);
	
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        //NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
	
    // Create IndicatorDoc for each file
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:files.count];
    for (NSString *file in files) 
    {
        if ([file.pathExtension compare:@"indicator" options:NSCaseInsensitiveSearch] == NSOrderedSame) 
        {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
            IndicatorDoc *doc = [[[IndicatorDoc alloc] initWithDocPath:fullPath] autorelease];
			
            //Add the doc to the dictionary IF it is not a category type
            if (![doc.data.type isEqualToString:@"Category"]) 
            {
                [retval setObject:doc forKey:doc.data.key];
                //count the tracking indicators
                if (doc.data.isTrackingTime) {
                    //NSLog(@"Increment Badge number before: %d",self.badgeNumber);
                    self.badgeNumber += 1;
                }
            }
        }
    }
	
    return retval;
	
}

/*
-(NSMutableDictionary*)loadCategoryDocs
{
	// Get private docs dir
    NSString *documentsDirectory = [IndicatorDatabase getPrivateDocsDir];
    NSLog(@"Loading indicators from %@", documentsDirectory);
	
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
	
    // Create IndicatorDoc for each file
    NSMutableDictionary *retval = [NSMutableDictionary dictionaryWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"indicator" options:NSCaseInsensitiveSearch] == NSOrderedSame) 
        {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
            IndicatorDoc *doc = [[[IndicatorDoc alloc] initWithDocPath:fullPath] autorelease];
			
            //Add the doc to the dictionary IF it is not a category type
            if ([doc.data.type isEqualToString:@"Category"]) 
            {
                [retval setObject:doc forKey:doc.data.key];
            }
            
        }
    }
	
    return retval;
	
}
 */

-(NSMutableArray*)loadCategories
{
    // Get private docs dir
    NSString *documentsDirectory = [IndicatorDatabase getPrivateDocsDir];
    //NSLog(@"Loading indicators from %@", documentsDirectory);
	
    // Get contents of documents directory
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (files == nil) {
        //NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return nil;
    }
    NSMutableArray *categoriesArray = [NSMutableArray arrayWithCapacity:files.count];
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"indicator" options:NSCaseInsensitiveSearch] == NSOrderedSame) 
        {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
            IndicatorDoc *doc = [[[IndicatorDoc alloc] initWithDocPath:fullPath] autorelease];
            //make sure the doc is not deactivated
            if (doc.data.isActive) {
                if (doc.data.category == nil) {
                    doc.data.category = @"Uncategorized"; //take care of old datas, This really should never happen...
                    [doc saveData];
                }
                //check if the category is already contained in the returnarray
                if ([categoriesArray indexOfObject:doc.data.category] == NSNotFound)
                    [categoriesArray addObject:doc.data.category]; //Add the category to the list of categories
            }
        }
    }
    return categoriesArray;
}

-(void)update
{
    self.badgeNumber = 0;
	self.indicatorDocs = [self loadIndicatorDocs];
    //self.categoryDocs = [self loadCategoryDocs];
    self.categories = [self loadCategories];
    self.lifetimeTotal = [[NSUserDefaults standardUserDefaults] floatForKey:kScoreKey];
    self.weekAverageScore = [[NSUserDefaults standardUserDefaults] floatForKey:kWeekAverageKey];
    self.monthAverageScore = [[NSUserDefaults standardUserDefaults] floatForKey:kMonthAverageKey];
    //update the badge number
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[IndicatorDatabase sharedDatabase].badgeNumber];
	//NSLog(@"Database Updated");
}

-(NSNumber*)nextKey
{
	int r = arc4random() % 100000;
    NSNumber* newKey = [NSNumber numberWithInt:r];
    NSArray* usedKeys = [_indicatorDocs allKeys];
    //NSArray* usedCatKeys = [_categoryDocs allKeys]; //REMOVED
    while([usedKeys containsObject:newKey] /*|| [usedCatKeys containsObject:newKey]*/) 
    {
        //NSLog(@"Key was duplicate, trying again");
        r = arc4random() % 100000;
        newKey = [NSNumber numberWithInt:r];
    }
	return newKey;
}

+(NSString*)dateKey
{
    //NSLog(@"Getting the date key");
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"]; // Just get the days
    NSDate *today = [NSDate date]; // get todays date
    NSString* dateKeyString = [fmt stringFromDate:today];
    //NSLog(@"date key is:%@",dateKeyString);
    [fmt release];
    return dateKeyString;
}
+(NSString*)dateKeyWithDate:(NSDate*)date
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"]; // Just get the days
    NSString* dateKeyString = [fmt stringFromDate:date];
    [fmt release];
    return dateKeyString;
}
- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (id)autorelease
{
    return self;
}

-(void)dealloc
{
	[_indicatorDocs release];
	_indicatorDocs = nil;
    //[_categoryDocs release];
    //_categoryDocs = nil;
    [_categories release];
    _categories = nil;
	[super dealloc];
}
@end
