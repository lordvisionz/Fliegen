//
//  FLUtilityPaneController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneController.h"

#import "FLAppFrameController.h"
#import "FLUtilityPaneAnchorPointsViewController.h"
#import "FLUtilityPaneFliegenViewController.h"
#import "FLUtilityPaneStreamsViewController.h"
#import "FLUtilityPaneSimVisViewController.h"

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
    [_utilityViewPane addSubview:_fliegenPropertiesController.view];
}

- (IBAction)switchUtilityPaneTab:(id)sender
{
    [_utilityViewPane.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSUInteger selectedSegment = _utilityPaneSegmentedControl.selectedSegment;
    if(selectedSegment == 0)
        [_utilityViewPane addSubview:_fliegenPropertiesController.view];
    else if(selectedSegment == 1)
        [_utilityViewPane addSubview:_streamsPropertiesController.view];
    else if(selectedSegment == 2)
        [_utilityViewPane addSubview:_anchorPointsPropertiesPaneController.view];
    else if(selectedSegment == 3)
    {
        [_utilityViewPane addSubview:_simVisPropertiesController.view];
        _appFrameController.simulationEditorToolbarItem.toolbar.selectedItemIdentifier = _appFrameController.simulationEditorToolbarItem.itemIdentifier;
        [_appFrameController toggleEditor:nil];
    }
    [self.view setNeedsDisplay:YES];
}

@end
