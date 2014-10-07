//
//  FLSceneView.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface FLSceneView : SCNView<SCNSceneRendererDelegate>



@property (weak) IBOutlet NSViewController *controller;

@end