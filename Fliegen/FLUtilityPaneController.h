//
//  FLUtilityPaneController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneAnchorPointsViewController, FLAppFrameController, FLUtilityPaneFliegenViewController, FLUtilityPaneStreamsViewController,
FLUtilityPaneSimVisViewController;

@interface FLUtilityPaneController : NSViewController

@property (weak) IBOutlet FLAppFrameController *appFrameController;

@property (weak) IBOutlet NSSegmentedControl *utilityPaneSegmentedControl;
@property (weak) IBOutlet NSView *utilityViewPane;

@property (weak) IBOutlet FLUtilityPaneAnchorPointsViewController *anchorPointsPropertiesPaneController;
@property (weak) IBOutlet FLUtilityPaneFliegenViewController *fliegenPropertiesController;
@property (weak) IBOutlet FLUtilityPaneStreamsViewController *streamsPropertiesController;
@property (weak) IBOutlet FLUtilityPaneSimVisViewController *simVisPropertiesController;

- (IBAction)switchUtilityPaneTab:(id)sender;

-(void)didFinishLaunching;

@end
