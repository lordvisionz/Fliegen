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

@interface FLUtilityPaneAnchorPointsViewController : NSViewController<NSTextFieldDelegate>

@property (weak) IBOutlet FLUtilityPaneController *utilityPaneController;

@property (weak) IBOutlet NSTextField *anchorId;

@property (weak) IBOutlet NSTextField *xPosition;
@property (weak) IBOutlet NSTextField *yPosition;
@property (weak) IBOutlet NSTextField *zPosition;

@property (weak) IBOutlet NSTextField *xLookAt;
@property (weak) IBOutlet NSTextField *yLookAt;
@property (weak) IBOutlet NSTextField *zLookAt;


//@property (readwrite, assign) NSUInteger anchorId;
//
//@property (readwrite, assign) SCNVector3 anchorPosition;
//
//@property (readwrite, assign) SCNVector3 anchorLookAt;

@end
