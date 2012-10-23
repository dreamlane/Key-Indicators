//
//  IndicatorData.h
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndicatorDatabase.h"

@interface IndicatorData : NSObject <NSCoding>
{
	NSNumber* _key;
	NSString* _title;
	NSString* _type; //Timer, Tally, Category, or Project.
    //NSMutableArray* _tasks; //Add later
	NSMutableDictionary* _periodGoals; // A dictionary of period goals, with a date range as it's key
    // NOTE: Timer goals are represented as NSNumbers from float, and represent hours
	//NSMutableDictionary* _periodWeightBases; // Similar to periodgoals, just with weights instead. !deprecating!
    float _weightBase; // determined by the priority given
    NSMutableDictionary* _periodWeightModifiers; // Modifiers for given dateRange keys, these affect the scores
    NSMutableDictionary* _periodScores; //Score for a given daterange Key, calculated anytime a goal or actual value is modified
    NSMutableDictionary* _periodValues; //Value for a given daterange Key, recalculated each time the user enters a value, whether by the widget or by the add value buttons
	//NSMutableArray* _children; // key list of children REMOVED
	//NSNumber* _childOf; // key NSNumber of parent TO BE REMOVED
    NSString* _category; // Category string
	NSMutableArray* _entries; //An array of floats that will be used to get total and week values
	NSMutableArray* _entryTimes; //An array of entry times that match the entries
    NSMutableDictionary* _dailyActuals; //A dictionary of daily actual values
	BOOL _isTrackingTime; //Used to determine if the time should continue tracking while the application is off
    BOOL _isInverseGoal; //Used for goals that desire minimal values
	NSDate* _startDate; //A string from NSDate that represents the begining of tracking time for this indicator
    BOOL _isActive; //A boolean representing whether or not the indicator/category is active
}

@property BOOL isInverseGoal;
@property (retain) NSNumber* key;
@property BOOL isActive;
@property (copy) NSString* title;
@property (copy) NSString* type;
//@property (copy) NSMutableArray* tasks;
@property (retain) NSMutableDictionary* periodGoals;
//@property (retain) NSMutableDictionary* periodWeightBases; //These weights determined by priority !DEPRECATING!
@property float weightBase;
@property (retain) NSMutableDictionary* periodWeightModifiers; //These determined by changes up and down in goals
@property (retain) NSMutableDictionary* periodScores; //Calc'd anytime a goal or actual for a given key has changed
@property (retain) NSMutableDictionary* periodValues;
@property (retain) NSMutableDictionary* dailyActuals;
//@property (retain) NSMutableArray* children; // REMOVED
//@property (copy) NSNumber* childOf; //Removed
@property BOOL isTrackingTime; 
@property (retain) NSDate* startDate;
@property (retain) NSString* category;


+(IndicatorData*)defaultDataWithType:(NSString*)type;
@end
