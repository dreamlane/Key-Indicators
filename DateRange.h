//
//  DateRange.h
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 Blank Sketch Stuidos LLC. All rights reserved.
//
// Updated: December 16th 2011

#import <Foundation/Foundation.h>


@interface DateRange : NSObject{
	NSDate* _startDate;
	NSDate* _endDate;
}

@property (retain) NSDate* startDate;
@property (retain) NSDate* endDate;

//Helper Class methods
+(NSCalendar*)calendar;
+(NSString*)keyFromDateRange:(DateRange*)range; //returns an NSString key used with IndicatorData's periodGoals and periodWeights
+(NSString*)periodLabelWithKey:(NSString*)key; //returns a formatted representation of the date range
//+(NSString*)keyFromDate:(NSDate*)date; //maybe superfluous
//currentDates
+(DateRange*)currentWeek;
+(DateRange*)currentMonth;
+(NSString*)keyForPeriodPriorToKey:(NSString*)key;
+(BOOL)isWeekKey:(NSString*)key;
//Comparison
+(BOOL)currentWeekContainsDate:(NSDate*)date;

//+(DateRange*)currentPeriodWithWeeks:(int)weeks andStartDate:(NSDate*)startDate;

//withDates
+(DateRange *)weekContainingDate:(NSDate *)date;
+(DateRange *)monthContainingDate:(NSDate *)date;

//+(DateRange *)periodContainingDate:(NSDate *)date;

//Instance methods


@end
