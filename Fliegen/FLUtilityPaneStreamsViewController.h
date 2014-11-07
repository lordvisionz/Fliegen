//
//  FLStreamsViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

@interface FLUtilityPaneStreamsViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;
@property (weak) IBOutlet NSComboBox *streamIDComboBox;
@property (weak) IBOutlet NSPopUpButton *streamTypePopupButton;
@property (weak) IBOutlet NSPopUpButton *streamVisualPopupButton;
@property (weak) IBOutlet NSPopUpButton *streamInterpolationPopupButton;
@property (weak) IBOutlet NSTextField *anchorPointsCountLabel;
@property (weak) IBOutlet NSColorWell *streamColorPicker;
@property (weak) IBOutlet NSButton *streamsVisibilityCheckBox;
@property (weak) IBOutlet NSButton *streamsSelectabilityCheckBox;
@property (weak) IBOutlet NSButton *visualizationButton;
@property (weak) IBOutlet NSTextField *visualizationTime;

- (IBAction)appendStream:(id)sender;

- (IBAction)removeSelectedStream:(id)sender;
- (IBAction)streamTypeChanged:(id)sender;
- (IBAction)streamVisualAidChanged:(id)sender;
- (IBAction)streamsVisibilityChanged:(id)sender;
- (IBAction)streamsSelectabilityChanged:(id)sender;
- (IBAction)streamColorChanged:(id)sender;
- (IBAction)streamInterpolationChanged:(id)sender;

@end
