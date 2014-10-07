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


@interface FLSceneViewController : NSViewController<NSMenuDelegate>

@property (weak) IBOutlet FLAppFrameController *appFrameController;

-(BOOL)mouseDragged:(NSEvent *)theEvent;

-(void)showViewportAxes:(BOOL)visible;

-(void)showGridlines:(BOOL)visible;

-(FLSceneView*)sceneView;

@end
