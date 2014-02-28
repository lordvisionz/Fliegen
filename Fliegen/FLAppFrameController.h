//
//  FLAppFrameController.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface FLAppFrameController : NSObject

@property (weak) IBOutlet NSSplitView *splitView;

- (IBAction)toggleUtilitiesPanel:(id)sender;
@property (weak) IBOutlet SCNView *editorView;
@property (weak) IBOutlet NSView *utilityPanel;

@end
