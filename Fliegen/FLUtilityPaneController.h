//
//  FLUtilityPaneController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneAnchorPointsViewController, FLAppFrameController;

@interface FLUtilityPaneController : NSViewController

@property (weak) IBOutlet FLAppFrameController *appFrameController;

@property (weak) IBOutlet NSSegmentedControl *utilityPaneSegmentedControl;
@property (weak) IBOutlet FLUtilityPaneAnchorPointsViewController *anchorPointsPane;
@property (weak) IBOutlet NSView *miscPane;
@property (weak) IBOutlet NSView *utilityViewPane;

- (IBAction)switchUtilityPaneTab:(id)sender;

-(void)didFinishLaunching;

@end
