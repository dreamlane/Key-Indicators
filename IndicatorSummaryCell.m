//
//  IndicatorSummaryCell.m
//  IndicatorsTracker
//
//  Created by Benjamin Johnson on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IndicatorSummaryCell.h"

@implementation IndicatorSummaryCell

@synthesize backingView = _backingView;
@synthesize titleLabel = _titleLabel;
//@synthesize parentLabel = _parentLabel;
@synthesize indicatorOnView = _indicatorOnView;
//@synthesize iconView = _iconView;
@synthesize weekGoalProgressView = _weekGoalProgressView;
@synthesize monthGoalProgressView = _monthGoalProgressView;
@synthesize indicatorBulbOn = _indicatorBulbOn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        /*
        if (self.indicatorOnView == nil) {
            UIImage* bulbOn = [[UIImage alloc] initWithContentsOfFile:@"IndicatorBulbOnNew.png"];
            [self.indicatorOnView initWithImage:bulbOn];
            [bulbOn release];
        }
         */
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
