//
//  IndicatorDetailView.h
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import "MBProgressHUD.h"
#import "CustomProgressView.h"

@interface IndicatorDetailView : UIViewController <UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MBProgressHUDDelegate>
{
    //IBOutlets
	CustomProgressView* _monthProgressView;
    CustomProgressView* _weekProgressView;
	UIButton* _widgetButton;
	UIButton* _addMonthValueButton;
    UIButton* _addWeekValueButton;
    UIButton* _goalMonthButton;
    UIButton* _goalWeekButton;
	UIButton* _categorySelectorButton;
    UIButton* _priorityButton;
    UIButton* _undoButton;
    UIButton* _redoButton;
    UILabel* allTimeLabel;
    
    //Action sheets
    UIActionSheet* _priorityPickerActionSheet;
    UIActionSheet* _categoryPickerActionSheet;
    UIActionSheet* _addHoursPickerActionSheet;
    UIActionSheet* _goalPickerActionSheet;
    UIDatePicker* _datePicker;
    
    //refresh timer
    NSTimer* refreshtimer;
    
    //Data
    BOOL postDate; //whether or not postdating is happening, TESTING only
    float valueToAdd;
    int lastValueAdded; //Subtracted by the undo button
    int lastValueRemoved; //Added by the redo button
    float goalToSet; //used anytime the goal buttons are used to set a new goal or change a goal
    float tempBaseWeight;
    
    NSArray* _priorityPickerArray;
	IndicatorDoc* _indicatorDoc;
}
//IBOutlets
@property (retain) IBOutlet CustomProgressView* monthProgressView;
@property (retain) IBOutlet CustomProgressView* weekProgressView;
@property (retain) IBOutlet UIButton* widgetButton;
@property (retain) IBOutlet UIButton* addMonthValueButton;
@property (retain) IBOutlet UIButton* addWeekValueButton;
@property (retain) IBOutlet UIButton* goalMonthButton;
@property (retain) IBOutlet UIButton* goalWeekButton;
@property (retain) IBOutlet UIButton* categorySelectorButton;
@property (retain) IBOutlet UIButton* priorityButton;
@property (retain) IBOutlet UIButton* undoButton;
@property (retain) IBOutlet UIButton* redoButton;
@property (retain) IBOutlet UILabel* undoLabel;
@property (retain) IBOutlet UILabel* redoLabel;
@property (retain) IBOutlet UILabel* allTimeLabel;

//Action Sheets
@property (retain) UIActionSheet* priorityPickerActionSheet;
@property (retain) UIActionSheet* categoryPickerActionSheet;
@property (retain) UIActionSheet* addHoursPickerActionSheet;
@property (retain) UIActionSheet* goalPickerActionSheet;
@property (retain) UIDatePicker* datePicker;

//Data
@property (retain) IndicatorDoc* indicatorDoc;
@property (retain) NSArray* priorityPickerArray;


- (float)getInterval;
- (void)initTimerView;
- (void)initTallyView;
//- (IBAction)inversionSwitchFlipped:(id)sender;
- (IBAction)categorySelectorButtonTapped:(id)sender; //Category Selection Button
//- (IBAction)periodGoalFieldValueChanged:(id)sender;
- (IBAction)widgetButtonTapped:(id)sender;
- (IBAction)addValueButtonTapped:(id)sender;
- (IBAction)goalMonthButtonTapped:(id)sender;
- (IBAction)goalWeekButtonTapped:(id)sender;
- (IBAction)showDeleteConfirm:(id)sender;
- (IBAction)priorityButtonTapped:(id)sender;
- (IBAction)reactivateTapped:(id)sender;
- (IBAction)undoButtonTapped:(id)sender;
- (IBAction)redoButtonTapped:(id)sender;
@end
