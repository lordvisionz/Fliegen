//
//  FLUtilityPaneSimVisViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

typedef NS_ENUM(unsigned short, FLVisualizationSimulationScaleFactor)
{
    FLVisualizationSimulationScaleFactor25Pixels = 0,
    FLVisualizationSimulationScaleFactor50Pixels = 1,
    FLVisualizationSimulationScaleFactor100Pixels = 2,
    FLVisualizationSimulationScaleFactor200Pixels = 3
};

@interface FLUtilityPaneSimVisViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>

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

-(void)viewDidAppear;

@end
