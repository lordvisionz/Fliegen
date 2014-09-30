//
//  FLUtilityPaneController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneController.h"
#import "FLUtilityPaneAnchorPointsViewController.h"

@interface FLUtilityPaneController ()

@end

@implementation FLUtilityPaneController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

-(void)didFinishLaunching
{
//    NSSegmentedCell *cell = _utilityPaneSegmentedControl.cell;
//    double width = 0;
//    width = [cell widthForSegment:0];
//    width += [cell widthForSegment:1];
//    [cell setWidth:(self.view.frame.size.width - width)  forSegment:2];
    
    [_utilityViewPane addSubview:_anchorPointsPane.view];
}

- (IBAction)switchUtilityPaneTab:(id)sender
{
    NSUInteger selectedSegment = _utilityPaneSegmentedControl.selectedSegment;
    if(selectedSegment == 0)
    {
        [_miscPane removeFromSuperview];
        [_utilityViewPane addSubview:_anchorPointsPane.view];
    }
    else if(selectedSegment == 1)
    {
        [_anchorPointsPane.view removeFromSuperview];
        [_utilityViewPane addSubview:_miscPane];
    }
    
    [self.view setNeedsDisplay:YES];
}

@end
