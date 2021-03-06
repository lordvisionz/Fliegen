//
//  FLUtilityPaneAnchorPointsViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@class FLUtilityPaneController;

@interface FLUtilityPaneAnchorPointsViewController : NSViewController<NSTextFieldDelegate, NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;

@property (weak) IBOutlet NSComboBox *anchorIdComboBox;

@property (weak) IBOutlet NSTextField *xPositionTextField;
@property (weak) IBOutlet NSTextField *yPositionTextField;
@property (weak) IBOutlet NSTextField *zPositionTextField;

@property (weak) IBOutlet NSStepper *xPositionStepper;
@property (weak) IBOutlet NSStepper *yPositionStepper;
@property (weak) IBOutlet NSStepper *zPositionStepper;

@property (weak) IBOutlet NSButton *deleteSelectedAnchorPointButton;

- (IBAction)appendAnchorPoint:(id)sender;

- (IBAction)removeSelectedAnchorPoint:(id)sender;

@end
