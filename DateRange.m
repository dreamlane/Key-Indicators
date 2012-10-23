//
//  DateRange.m
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 Blank Sketch Stuidos LLC. All rights reserved.
//
// Updated: December 16th 2011

#import "DateRange.h"


@implementation DateRange

@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

+ (NSCalendar *)calendar
{
    NSCalendar * gregorian = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian autorelease];
}

#pragma mark - Ranges With Dates

+ (DateRange *)weekContainingDate:(NSDate *)date
{
    DateRange * range = [[self alloc] init];
	
    // start of the week
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:NSWeekCalendarUnit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    range.startDate = firstDay;
	
    // end of the week
    NSDateComponents * oneWeek = [[NSDateComponents alloc] init];
    [oneWeek setWeek:1];
    [range setEndDate:[[self calendar] dateByAddingComponents:oneWeek
                                                       toDate:firstDay
                                                      options:0]];
    [oneWeek release];
    return [range autorelease];
}

+ (DateRange *)monthContainingDate:(NSDate *)date
{
    DateRange * range = [[self alloc] init];
	
    // start of the week
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:NSMonthCalendarUnit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    range.startDate = firstDay;
	
    // end of the week
    NSDateComponents * oneMonth = [[NSDateComponents alloc] init];
    [oneMonth setMonth:1];
    [range setEndDate:[[self calendar] dateByAddingComponents:oneMonth
                                                       toDate:firstDay
                                                      options:0]];
    [oneMonth release];
	
    return [range autorelease];
}

#pragma mark  - Ranges for current dates
+(DateRange*)currentWeek
{
	DateRange * range = [[self alloc] init];
	NSDate* date = [[NSDate alloc] init];
    // start of the week
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:NSWeekCalendarUnit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    range.startDate = firstDay;
	
    // end of the week
    NSDateComponents * oneWeek = [[NSDateComponents alloc] init];
    [oneWeek setWeek:1];
    [range setEndDate:[[self calendar] dateByAddingComponents:oneWeek
                                                       toDate:firstDay
                                                      options:0]];
    [oneWeek release];
	[date release];
    //[firstDay release];
    return [range autorelease];
	
}

+(DateRange*)currentMonth
{
	DateRange * range = [[self alloc] init];
	NSDate* date = [[NSDate alloc] init];

    // start of the week
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:NSMonthCalendarUnit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    range.startDate = firstDay;
	
    // end of the week
    NSDateComponents * oneMonth = [[NSDateComponents alloc] init];
    [oneMonth setMonth:1];
    [range setEndDate:[[self calendar] dateByAddingComponents:oneMonth
                                                       toDate:firstDay
                                                      options:0]];
    [oneMonth release];
	[date release];
    //[firstDay release];
    return [range autorelease];
}
/*
+(DateRange*)currentPeriodWithWeeks:(int)weeks
{
	DateRange * range = [[self alloc] init];
	NSDate* date = [[NSDate alloc] init];
	
    // start of the week
    NSDate * firstDay;
    [[self calendar] rangeOfUnit:NSWeekCalendarUnit
                       startDate:&firstDay
                        interval:0
                         forDate:date];
    range.startDate = firstDay;
	
    // end of the week
    NSDateComponents * onePeriod = [[NSDateComponents alloc] init];
    [onePeriod setWeek:weeks];
    [range setEndDate:[[self calendar] dateByAddingComponents:onePeriod
                                                       toDate:firstDay
                                                      options:0]];
    [onePeriod release];
	[date release];
    return [range autorelease];
}
*/

#pragma mark - Key Getter Methods

+(NSString*)keyForPeriodPriorToKey:(NSString *)key
{
    //TEST THIS METHOD
    //determine if the key is week or not
    DateRange* priorPeriod;
    if ([DateRange isWeekKey:key]) {
        // Get the prior week key
        //get the start date from the key
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* startDate = [dateFormatter dateFromString:[key substringToIndex:(19)]];
        // subtract a week from the date
        NSDateComponents * oneWeek = [[NSDateComponents alloc] init];
        [oneWeek setWeek:-1];
        startDate = [[self calendar] dateByAddingComponents:oneWeek toDate:startDate options:0];
        priorPeriod = [DateRange weekContainingDate:startDate];
        [oneWeek release];
        [dateFormatter release];
    }
    else {
        //get the prior month key
        //get the start date from the key
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* startDate = [dateFormatter dateFromString:[key substringToIndex:(19)]];
        // subtract a week from the date
        NSDateComponents * oneMonth = [[NSDateComponents alloc] init];
        [oneMonth setMonth:-1];
        startDate = [[self calendar] dateByAddingComponents:oneMonth toDate:startDate options:0];
        priorPeriod = [DateRange monthContainingDate:startDate];
        [oneMonth release];
        [dateFormatter release];
    }
    return [DateRange keyFromDateRange:priorPeriod];
}

+(NSString*)keyFromDateRange:(DateRange*)range
{
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateStringStart = [dateFormatter stringFromDate:range.startDate];
	NSString *dateStringEnd = [dateFormatter stringFromDate:range.endDate];
	[dateFormatter release];
	NSString *key = [dateStringStart stringByAppendingString:dateStringEnd];
	//NSLog(@"The key is %@",key);
	return key; 
	
}

/*
 *This method is used to get a nicely formatted label for the graphs
 */
+(NSString*)periodLabelWithKey:(NSString *)key 
{
    NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; 
    NSDate* startDate = [fmt dateFromString:[key substringToIndex:(19)]];
    if (![DateRange isWeekKey:key]) {
        [fmt setDateFormat:@"MMM-yyyy"]; // Format the date like: Jan-2012
        return [fmt stringFromDate:startDate];
    }
    else
    {
        [fmt setDateFormat:@"MMM-dd-yy"]; // Format the date like: Jan-11-12
        return [fmt stringFromDate:startDate];
    }
}

+(BOOL)isWeekKey:(NSString*)key
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //split the string into start and end dates
    NSDate* startDate = [dateFormatter dateFromString:[key substringToIndex:(19)]];
    NSDate* endDate = [dateFormatter dateFromString:[key substringFromIndex:(19)]];
    int datedifference = [endDate timeIntervalSince1970] - [startDate timeIntervalSince1970];
    [dateFormatter release];
    
    //NSLog(@"%d", datedifference);
    return (datedifference < 700000); // return true if the seconds between dates are less than 700k, essentially if it is a week key
}
/* Maybe superfluous
+(NSString*)keyFromDate:(NSDate*)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *
}
 */
#pragma mark -
#pragma mark Comparisons

+(BOOL)currentWeekContainsDate:(NSDate*)date
{
	NSComparisonResult resultStart = [[DateRange currentWeek].startDate compare:date];
	NSComparisonResult resultEnd = [[DateRange currentWeek].endDate compare:date];
	
	if (resultStart == NSOrderedDescending || resultEnd == NSOrderedAscending) {
		return NO;
	}
	else {
		return YES;
	}
}

#pragma mark description override
-(NSString*)description
{
	return [NSString stringWithFormat:@"Range Begin: %@ Range End: %@",[_startDate description],[_endDate description]];
}

#pragma mark memory management
-(void)dealloc
{
    [_startDate release];
    _startDate = nil;
    [_endDate release];
    _endDate = nil;
    [super dealloc];
}
@end
