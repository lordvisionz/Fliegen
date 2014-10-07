//
//  FLUtilityPaneFliegenViewController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/1/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLUtilityPaneController;

@interface FLUtilityPaneFliegenViewController : NSViewController

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;

@property (weak) IBOutlet NSButton *showViewportAxes;
@property (weak) IBOutlet NSButton *showGridlines;

//@property (weak) IBOutlet NSPopUpButton *sceneReferenceObject;

@end
