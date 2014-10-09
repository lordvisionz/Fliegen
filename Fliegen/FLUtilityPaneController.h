//
//  FLUtilityPaneController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneAnchorPointsViewController, FLAppFrameController, FLUtilityPaneFliegenViewController, FLStreamsViewController;

@interface FLUtilityPaneController : NSViewController

@property (weak) IBOutlet FLAppFrameController *appFrameController;

@property (weak) IBOutlet NSSegmentedControl *utilityPaneSegmentedControl;
@property (weak) IBOutlet FLUtilityPaneAnchorPointsViewController *anchorPointsPropertiesPaneController;
@property (weak) IBOutlet FLUtilityPaneFliegenViewController *fliegenPropertiesController;
@property (weak) IBOutlet NSView *utilityViewPane;
@property (weak) IBOutlet FLStreamsViewController *streamsPropertiesController;

- (IBAction)switchUtilityPaneTab:(id)sender;

-(void)didFinishLaunching;

@end
