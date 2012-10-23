//
//  IndicatorDatabase.h
//  ProductivityApp
//
//  Created by Benjamin Johnson on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "IndicatorData.h"
#import "IndicatorDoc.h"

@class IndicatorDoc;

@interface IndicatorDatabase : NSObject
{
	NSMutableDictionary* _indicatorDocs;
    NSMutableArray* _categories; 
    NSInteger _badgeNumber;
    float _lifetimeTotal;
    float _weekAverageScore;
    float _monthAverageScore;
}

@property (retain) NSMutableDictionary* indicatorDocs;
@property (retain) NSMutableArray* categories;
@property NSInteger badgeNumber;
@property float lifetimeTotal;
@property float monthAverageScore;
@property float weekAverageScore;

-(NSMutableDictionary*)loadIndicatorDocs;
+(NSString*)nextIndicatorDocPath;
-(NSNumber*)nextKey;
+(NSString*)dateKey;
+(NSString*)dateKeyWithDate:(NSDate*)date;
+(IndicatorDatabase*)sharedDatabase;
-(NSMutableArray*)loadCategories; //these really should return NSArray instead of NSMutableArray
-(NSMutableArray*)loadIndicatorsWithCategory:(NSString*)category;
-(void)update;
-(void)updateLifetimeScore;

@end
