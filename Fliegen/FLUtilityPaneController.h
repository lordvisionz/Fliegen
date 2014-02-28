//
//  FLUtilityPaneController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/28/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FLUtilityPaneController : NSViewController

@property (weak) IBOutlet NSSegmentedControl *utilityPaneSegmentedControl;
@property (weak) IBOutlet NSView *anchorPointsPane;
@property (weak) IBOutlet NSView *miscPane;
@property (weak) IBOutlet NSView *utilityViewPane;

- (IBAction)toggleUtilityView:(id)sender;

-(void)didFinishLaunching;

@end
