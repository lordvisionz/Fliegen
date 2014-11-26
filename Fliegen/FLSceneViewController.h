//
//  FLSceneViewController
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FLSceneKitUtilities.h"

@class FLAppFrameController, FLSceneView;

typedef NS_ENUM(unsigned short, FLSelectionMode)
{
    FLSelectionModeNone = 0,
    FLSelectionModeStreams = 1,
    FLSelectionModeAnchorPoint = 2
};

@interface FLSceneViewController : NSViewController<NSMenuDelegate>

@property (weak) IBOutlet FLAppFrameController *appFrameController;

@property (readwrite) FLSelectionMode selectionMode;

-(BOOL)mouseDragged:(NSEvent *)theEvent;

-(void)showViewportAxes:(BOOL)visible;

-(void)showGridlines:(BOOL)visible;

-(void)startCameraPOVSimulation;

-(void)stopCameraPOVSimulation;

-(FLSceneView*)sceneView;

@end
