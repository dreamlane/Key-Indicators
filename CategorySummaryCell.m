//
//  CategorySummaryCell.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 2/16/12.
//  Copyright (c) 2012 Blank Sketch Studios LLC. All rights reserved.
//

#import "CategorySummaryCell.h"

@implementation CategorySummaryCell

@synthesize titleLabel;
@synthesize thisWeek;
@synthesize thisMonth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
