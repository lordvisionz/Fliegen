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

-(void)setSceneReferenceObject:(FLSceneReferenceObject)referenceObject;

-(BOOL)mouseDragged:(NSEvent *)theEvent;

-(FLSceneView*)sceneView;

@end
