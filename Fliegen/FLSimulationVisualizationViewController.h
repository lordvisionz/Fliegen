//
//  FLSimulationVisualizationTimeController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FLStreamProtocol.h"

@class FLAppFrameController;

@interface FLSimulationVisualizationViewController : NSViewController

@property (weak) IBOutlet FLAppFrameController *appFrameController;

//@property (readonly) id<FLStreamProtocol> selectedCameraStream;

//@property (readonly) id<FLStreamProtocol> selectedCameraLookAt;

@end
