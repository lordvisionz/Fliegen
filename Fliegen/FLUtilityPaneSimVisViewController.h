//
//  FLUtilityPaneSimVisViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

@interface FLUtilityPaneSimVisViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate, NSTextFieldDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;

@property (weak) IBOutlet NSComboBox *visualizationStreamComboBox;
@property (weak) IBOutlet NSTextField *visualizationStartTimeTextField;
@property (weak) IBOutlet NSTextField *visualizationEndTimeTextField;
@property (weak) IBOutlet NSPopUpButton *visualizationScaleFactorButton;
@property (weak) IBOutlet NSComboBox *visualizationStreamSelectedAnchorPointComboBox;
@property (weak) IBOutlet NSTextField *visualizationAnchorPointTimeTextField;

@property (weak) IBOutlet NSComboBox *simulationStreamComboBox;
@property (weak) IBOutlet NSTextField *simulationStartTimeTextField;
@property (weak) IBOutlet NSTextField *simulationEndTimeTextField;
@property (weak) IBOutlet NSPopUpButton *simulationScaleFactorButton;
@property (weak) IBOutlet NSComboBox *simulationSelectedAnchorPointComboBox;
@property (weak) IBOutlet NSTextField *simulationAnchorPointTimeTextField;

@property (weak) IBOutlet NSButton *cameraPOVButton;
@property (weak) IBOutlet NSButton *saveButton;

- (IBAction)togglePreview:(id)sender;
- (IBAction)saveSimulation:(id)sender;

-(void)viewDidAppear;

@end
