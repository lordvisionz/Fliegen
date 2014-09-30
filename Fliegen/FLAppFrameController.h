//
//  FLAppFrameController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@class FLUtilityPaneController, FLSceneViewController, FLModel;

@interface FLAppFrameController : NSObject<NSSplitViewDelegate>

@property (readonly, retain) FLModel *model;

@property (weak) IBOutlet NSSplitView *splitView;

@property (weak) IBOutlet FLSceneViewController *sceneViewController;
@property (weak) IBOutlet FLUtilityPaneController *utilityPanelController;

- (IBAction)toggleUtilitiesPanel:(id)sender;

@end
