//
//  IndicatorDoc.h
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateRange.h"
#import "IndicatorData.h"
#import "IndicatorDatabase.h"


@class IndicatorData;

@interface IndicatorDoc : NSObject {
	
	IndicatorData* _data;
	NSString *_docPath;
	float _hoursToBeAdded;
    float _minutesToBeAdded;
    BOOL isNewDoc;
	
}


@property (nonatomic, retain) IndicatorData* data;
@property (copy) NSString* docPath;
@property float hoursToBeAdded; 
@property float minutesToBeAdded;
@property BOOL isNewDoc;


-(id)init;
-(id)initWithDocPath:(NSString*)docPath;
-(id)initWithIndicatorData:(IndicatorData*)data;

//-(float)weekValue;
//-(float)totalValue;
//-(float)periodValue; //calculates the value based on the current date
-(float)periodValueWithKey:(NSString*)key; //calculates the value based on the given date key NOTE: Do not call in performance sensitive situations
-(float)selfValue; //used to calculate both hours and tallies depending on indicator type
-(float)totalScore; //takes week scores and averages them with month scores
-(float)maximumScoreWithKey:(NSString*)key; //returns the highest possible score for the given indicator in it's current state

//-(float)childrenHours; //REMOVED
//-(float)childrenTallies; //change all tallies to ints? would have to make a selfHours and selfTallies method to replace selfValue //REMOVED...
//-(float)childrenPeriodHours; //REMOVED
//-(float)childrenPeriodTallies; //REMOVED
//-(float)childrenWeekHoursGoal;
//-(float)childrenWeekTalliesGoal;

//Helpers
//-(NSArray*)getPeriodDays;
-(NSArray*)getPeriodDaysWithKey:(NSString*)key;
-(void)updateScoreForKey:(NSString*)key;
-(void)saveData;
-(void)deleteDoc;
@end
