//
//  LifetimeSummaryCell.h
//  Key Indicators
//
//  Created by Benjamin Johnson on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LifetimeSummaryCell : UITableViewCell 

{
    UILabel* _scoreLabel;
}

@property (retain) IBOutlet UILabel* scoreLabel;
@end
