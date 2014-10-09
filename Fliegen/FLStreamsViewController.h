//
//  FLStreamsViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

@interface FLStreamsViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;
@property (weak) IBOutlet NSComboBox *streamIDComboBox;
@property (weak) IBOutlet NSPopUpButton *streamTypePopupButton;
@property (weak) IBOutlet NSPopUpButton *streamVisualPopupButton;

- (IBAction)appendStream:(id)sender;

- (IBAction)removeSelectedStream:(id)sender;

@end
