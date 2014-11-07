//
//  FLUtilityPaneSimVisViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

@interface FLUtilityPaneSimVisViewController : NSViewController<NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;


@property (weak) IBOutlet NSComboBox *cameraPositionsComboBox;
@property (weak) IBOutlet NSComboBox *cameraLookAtComboBox;

-(void)viewDidAppear;

@end
