//
//  Key_IndicatorsAppDelegate.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Key_IndicatorsAppDelegate.h"
#import "IndicatorListView.h"

@implementation Key_IndicatorsAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize indicatorListView = _indicatorListView;
//@synthesize categoryListView = _categoryListView; //REMOVED
@synthesize reviewView = _reviewView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[IndicatorDatabase sharedDatabase].badgeNumber];
    //BUT.. the tab bar doesnt have any items to show.. lets solve that
    
    NSMutableArray *a = [[NSMutableArray alloc]init];
    
    // you should have two ViewControllers already created, ViewControllerA and ViewControllerB, or whetever you want to call them.
    // they should both inherit from UITableViewController (for our example)
    // then create two UINavigationControllers, initialize each one with the corresponding ViewController (ViewControllerA and B);
    // add each UINavigationController to our array above
    //create the Indicator List View and add it to the array
    self.indicatorListView = [[[IndicatorListView alloc] initWithNibName:@"IndicatorListView" bundle:[NSBundle mainBundle]] autorelease];
    self.indicatorListView.title = @"Indicators";
    self.indicatorListView.tabBarItem.image = [UIImage imageNamed:@"IndicatorsIcon.png"];	
    UINavigationController* listNavController = [[UINavigationController alloc] initWithRootViewController:self.indicatorListView];
    [listNavController.navigationBar setTintColor:[UIColor grayColor]];
    [a addObject:listNavController];
    [listNavController release];
    
     //create the Category List View and add it to the array REMOVED
    //self.categoryListView = [[CategoryListView alloc] initWithNibName:@"CategoryListView" bundle:[NSBundle mainBundle]];
    //self.categoryListView.title = @"Categories";
    //UINavigationController* categoryNavController = [[UINavigationController alloc] initWithRootViewController:_categoryListView];
    //[a addObject:categoryNavController];
    
    //create the Review View and add it to the array
    self.reviewView = [[[ReviewListView alloc] initWithNibName:@"ReviewListView" bundle:[NSBundle mainBundle]] autorelease];
    self.reviewView.title = @"Review";
    self.reviewView.tabBarItem.image = [UIImage imageNamed:@"GraphIcon.png"];
    UINavigationController* reviewNavController = [[UINavigationController alloc] initWithRootViewController:self.reviewView];
    [reviewNavController.navigationBar setTintColor:[UIColor grayColor]];
    [a addObject:reviewNavController];
    [reviewNavController release];
    
    //assign our view controllers;
    self.tabBarController.viewControllers=a;
    [a release];

    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    
    
    [self.window makeKeyAndVisible];
    return YES;
     
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
   // [_categoryListView release]; //removed
    [_indicatorListView release];
    [_reviewView release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
