//
//  IndicatorData.m
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IndicatorData.h"


@implementation IndicatorData

@synthesize key = _key;
@synthesize title = _title;
@synthesize type = _type;
//@synthesize tasks = _tasks;
@synthesize periodGoals = _periodGoals;
//@synthesize periodWeightBases = _periodWeightBases; //!deprecating!
@synthesize weightBase = _weightBase;
@synthesize periodWeightModifiers = _periodWeightModifiers;
@synthesize periodScores = _periodScores;
@synthesize dailyActuals = _dailyActuals;
//@synthesize children = _children;// Array of IndicatorDoc titles. REMOVED
//@synthesize childOf = _childOf; removed
@synthesize isTrackingTime = _isTrackingTime;
@synthesize isInverseGoal = _isInverseGoal;
@synthesize startDate = _startDate;
@synthesize isActive = _isActive;
@synthesize category = _category;
@synthesize periodValues = _periodValues;


//has a for loop inside, if this gets large, it could be slow... 
//make sure there is a loading screen
//or use NSOperation or w/e its called
-(id) initWithKey:(NSNumber*)key title:(NSString*)title type:(NSString*)type
		periodGoals:(NSMutableDictionary*)periodGoals 
/*periodWeights:(NSMutableDictionary*)periodWeights*/ weightBase:(float)weightBase periodWeightsModifier:(NSMutableDictionary*)periodWeightsModifier
     periodScores:(NSMutableDictionary*)periodScores periodValues:(NSMutableDictionary*)periodValues
		   /*children:(NSMutableArray*)children childOf:(NSNumber*)childOf*/
     dailyActuals:(NSMutableDictionary*)dailyActuals
   isTrackingTime:(BOOL)isTrackingTime isInverseGoal:(BOOL)isInverseGoal
        startDate:(NSDate*)startDate isActive:(BOOL)isActive category:(NSString*)category
{
	if ((self = [super init])) 
	{
		_key = [key retain];
		_title = [title copy];
		_type = [type copy];
		_periodGoals = [periodGoals retain];
		//_periodWeightBases = [periodWeights retain];
        _weightBase = weightBase;
        _periodWeightModifiers = [periodWeightsModifier retain];
        _periodScores = [periodScores retain];
        _periodValues = [periodValues retain];
		//_children = [children retain];
		//_childOf = [childOf retain];
		_isTrackingTime = isTrackingTime;
        _isInverseGoal = isInverseGoal;
		_startDate = [startDate retain];
        _dailyActuals = [dailyActuals retain];
        _isActive = isActive;
        _category = [category retain];
		
	}
	return self;
}//end initWithTitle .... .... .... ....

+(IndicatorData*)defaultDataWithType:(NSString*)type
{
	IndicatorData* defaultData = [[IndicatorData alloc] 
								  initWithKey:[[IndicatorDatabase sharedDatabase] nextKey]
								  title:@"Indicator Name" 
								  type:type periodGoals:nil /*periodWeights:nil*/ weightBase:0.5f periodWeightsModifier:nil periodScores: nil
                                  periodValues:nil
								  /*children:nil childOf:nil*/ dailyActuals:nil isTrackingTime:NO 
                                  isInverseGoal:NO startDate:nil isActive:YES category:@"Uncategorized"];//No leak here, ignore analyze?
	return defaultData;
}
#pragma mark NSCoding

#define kDailyActualsKey @"dailyActuals"
#define kTitleKey		@"title"
#define kTypeKey		@"type"
#define kPeriodGoalsKey	@"periodGoals"
//#define kPeriodWeightsKey	@"periodWeights"
#define kWeightBase @"weightBase"
#define kPeriodWeightsModKey	@"periodWeightsMod"
#define kPeriodScoresKey @"periodScores"
//#define kChildrenKey	@"children"
//#define kChildOfKey		@"childOf"
#define kEntriesKey		@"entries"
#define	kEntryTimesKey	@"entryTimes"
#define kIsTrackingTimeKey @"isTrackingTime"
#define kIsInverseGoalKey @"isInverseGoal"
#define kStartDateKey	@"startDateKey"
#define kKeyKey			@"key"
#define kIsActiveKey    @"isActive"
#define kCategoryKey    @"category"
#define kPeriodValuesKey @"periodValues"

-(void) encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:_dailyActuals forKey:kDailyActualsKey];
    [encoder encodeObject:_title forKey:kTitleKey];
	[encoder encodeObject:_type forKey:kTypeKey];
	[encoder encodeObject:_periodGoals forKey:kPeriodGoalsKey];
	//[encoder encodeObject:_periodWeightBases forKey:kPeriodWeightsKey];
    [encoder encodeFloat:_weightBase forKey:kWeightBase];
    [encoder encodeObject:_periodWeightModifiers forKey:kPeriodWeightsModKey];
    [encoder encodeObject:_periodScores forKey:kPeriodScoresKey];
    [encoder encodeObject:_periodValues forKey:kPeriodValuesKey];
	//[encoder encodeObject:_children forKey:kChildrenKey];
	//[encoder encodeObject:_childOf forKey:kChildOfKey];
	[encoder encodeBool:_isTrackingTime forKey:kIsTrackingTimeKey];
    [encoder encodeBool:_isInverseGoal forKey:kIsInverseGoalKey];
	[encoder encodeObject:_startDate forKey:kStartDateKey];
	[encoder encodeObject:_key forKey:kKeyKey];
    [encoder encodeBool:_isActive forKey:kIsActiveKey];
    [encoder encodeObject:_category forKey:kCategoryKey];
}

-(id) initWithCoder:(NSCoder *)decoder
{
	NSString* title = [decoder decodeObjectForKey:kTitleKey];
	NSString* type = [decoder decodeObjectForKey:kTypeKey];
	NSMutableDictionary* weeklyGoals = [decoder decodeObjectForKey:kPeriodGoalsKey];
	//NSMutableDictionary* weeklyWeights = [decoder decodeObjectForKey:kPeriodWeightsKey]; //DEPRECATIng
    float weightBase = [decoder decodeFloatForKey:kWeightBase];
    NSMutableDictionary* periodWeightsModifier = [decoder decodeObjectForKey:kPeriodWeightsModKey];
    NSMutableDictionary* dailyActuals = [decoder decodeObjectForKey:kDailyActualsKey];
    NSMutableDictionary* periodScores = [decoder decodeObjectForKey:kPeriodScoresKey];
    NSMutableDictionary* periodValues = [decoder decodeObjectForKey:kPeriodValuesKey];
	//NSMutableArray* children = [decoder decodeObjectForKey:kChildrenKey];
	//NSNumber* childOf = [decoder decodeObjectForKey:kChildOfKey];
	BOOL isTrackingTime = [decoder decodeBoolForKey:kIsTrackingTimeKey];
    BOOL isInverserGoal = [decoder decodeBoolForKey:kIsInverseGoalKey];
	NSDate* startDate = [decoder decodeObjectForKey:kStartDateKey];
	NSNumber* key = [decoder decodeObjectForKey:kKeyKey];
    BOOL isActive  = [decoder decodeBoolForKey:kIsActiveKey];
    NSString* category = [decoder decodeObjectForKey:kCategoryKey];
	
	return [self initWithKey:key title:title type:type periodGoals:weeklyGoals
            /*periodWeights:weeklyWeights*/ weightBase:weightBase periodWeightsModifier:periodWeightsModifier
                periodScores:periodScores periodValues:periodValues/*children:children 
                     childOf:childOf*/ dailyActuals:dailyActuals isTrackingTime:isTrackingTime 
                    isInverseGoal:isInverserGoal startDate:startDate isActive:isActive category:category];	
}

-(void) dealloc
{
    [_dailyActuals release];
    _dailyActuals = nil;
	[_key release];
	_key = nil;
	[_title release];
	_title = nil;
	[_type release];
	_type = nil;
	//[_periodWeightBases release];
	//_periodWeightBases = nil;
	[_periodGoals release];
	_periodGoals = nil;
    [_periodScores release];
    _periodScores = nil;
	//[_children release];
	//_children = nil;
	//[_childOf release];
	//_childOf = nil;
	[_entries release];
	_entries = nil;
	[_entryTimes release];
	_entryTimes = nil;
	[_startDate release];
	_startDate = nil;
    [_category release];
    _category = nil;
    [_periodWeightModifiers release];
    _periodWeightModifiers = nil;
    [_periodValues release];
    _periodValues = nil;
	[super dealloc];
}
@end
