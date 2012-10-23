//
//  AddValueView.h
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndicatorDoc.h"
#import "IndicatorData.h"
#import	"IndicatorDatabase.h"

@interface AddValueView : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate> {
	//UILabel* _titleLabel;
	UILabel* _valueLabel;
	UITextField* _valueToBeAddedField;
	IndicatorDoc* _indicatorDoc;
}

//@property (retain) IBOutlet UILabel* titleLabel;//maybe remove
@property (retain) IBOutlet UILabel* valueLabel;
@property (retain) IBOutlet UITextField* valueToBeAddedField;
@property (retain) IndicatorDoc* indicatorDoc;

-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)cancelButtonPressed:(id)sender;
-(IBAction)valueToBeAddedChanged:(id)sender;
-(IBAction)valueToBeAddedFieldSelected:(id)sender;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
@end
