//
//  AppDelegate.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/26/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

#import "FLSceneViewController.h"
#import "FLUtilityPaneController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;



@property (unsafe_unretained) IBOutlet FLSceneViewController *anchorPointsViewController;


@property (unsafe_unretained) IBOutlet FLUtilityPaneController *utilityPaneController;

@end
