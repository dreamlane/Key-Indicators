//
//  CustomProgressView.m
//  Key Indicators
//
//  Created by Benjamin Johnson on 7/29/11.
//  Copyright 2011 Blank Sketch Stuidos LLC. All rights reserved.
//
// Updated: December 16th 2011

#import "CustomProgressView.h"

#define kCustomProgressViewFillOffsetX 1
#define kCustomProgressViewFillOffsetTopY 1
#define kCustomProgressViewFillOffsetBottomY 2

@implementation CustomProgressView

@synthesize goal;

- (void)drawRect:(CGRect)rect {
    if (self.goal == 0.00f) {
        self.progress = 1;
    }
    //NSLog(@"progress is : %f",[self progress]);
    CGSize backgroundStretchPoints = {5,22}, fillStretchPoints = {2, 20};
    
    // Initialize the stretchable images.
    UIImage *background = [[UIImage imageNamed:@"IndicatorProgressBarOff-new.png"] stretchableImageWithLeftCapWidth:backgroundStretchPoints.width 
                                                                                           topCapHeight:backgroundStretchPoints.height];
    
    // Draw the background in the current rect
    [background drawInRect:rect];
    
    // Compute the max width in pixels for the fill.  Max width being how
    // wide the fill should be at 100% progress.
    NSInteger maxWidth = rect.size.width - (2 * kCustomProgressViewFillOffsetX);
    
    NSInteger curWidth;
    
    // Compute the width for the current progress value, 0.0 - 1.0 corresponding 
    // to 0% and 100% respectively.
    curWidth = floor([self progress] * maxWidth);
    // Create the rectangle for our fill image accounting for the position offsets,
    // 0 in the X direction and 0, 0 on the top and bottom for the Y.
    CGRect fillRect = CGRectMake(rect.origin.x + kCustomProgressViewFillOffsetX,
                                 rect.origin.y + kCustomProgressViewFillOffsetTopY,
                                 curWidth,
                                 rect.size.height - kCustomProgressViewFillOffsetBottomY);
    
    //Determine the fill color
    UIImage *fill;
    if (self.goal == 0.00f) {
        fill = [[UIImage imageNamed:@"IndicatorProgressOn-Red.png"] stretchableImageWithLeftCapWidth:fillStretchPoints.width 
                                                                                                   topCapHeight:fillStretchPoints.height];  
    }
    else if (self.progress < 1)
    {
        fill = [[UIImage imageNamed:@"IndicatorProgressOn-Blue.png"] stretchableImageWithLeftCapWidth:fillStretchPoints.width 
                                                                                        topCapHeight:fillStretchPoints.height];  
    }
    else
    {
        fill = [[UIImage imageNamed:@"IndicatorProgressOn-Green.png"] stretchableImageWithLeftCapWidth:fillStretchPoints.width 
                                                                                        topCapHeight:fillStretchPoints.height];  
    }
    
    // Draw the fill
    [fill drawInRect:fillRect];
}

@end