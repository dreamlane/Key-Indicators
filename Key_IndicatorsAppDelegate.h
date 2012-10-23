//
//  Key_IndicatorsAppDelegate.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorListView.h"
#import "CategoryListView.h"
#import "ReviewListView.h"
#import "IndicatorDatabase.h"

@interface Key_IndicatorsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IndicatorListView* indicatorListView;
//@property (nonatomic, retain) CategoryListView* categoryListView; //REMOVED
@property (nonatomic, retain) ReviewListView* reviewView;
@end
