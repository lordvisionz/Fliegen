//
//  FLAppFrameController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@class FLUtilityPaneController, FLSceneViewController, FLSimulationVisualizationViewController, FLModel;

@interface FLAppFrameController : NSObject<NSSplitViewDelegate, NSToolbarDelegate>

@property (readonly, retain) FLModel *model;

@property (weak) IBOutlet NSSplitView *splitView;

@property (weak) IBOutlet FLSceneViewController *sceneViewController;
@property (weak) IBOutlet FLSimulationVisualizationViewController *simVisTimeViewController;
@property (weak) IBOutlet FLUtilityPaneController *utilityPanelController;

@property (weak) IBOutlet NSView *editorPlaceholderView;

@property (weak) IBOutlet NSToolbarItem *propertiesToolbarItem;
@property (weak) IBOutlet NSToolbarItem *simulationEditorToolbarItem;
@property (weak) IBOutlet NSToolbarItem *sceneEditorToolbarItem;

- (IBAction)toggleUtilitiesPanel:(id)sender;
- (IBAction)toggleEditor:(id)sender;
- (void)toggleEditorWithoutSwitchingUtilityTab;

@end
