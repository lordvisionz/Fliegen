//
//  FLUtilityPaneFliegenViewController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/1/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneFliegenViewController.h"
#import "FLSceneKitUtilities.h"
#import "FLUtilityPaneController.h"
#import "FLAppFrameController.h"
#import "FLSceneViewController.h"

@interface FLUtilityPaneFliegenViewController ()

@end

@implementation FLUtilityPaneFliegenViewController

- (IBAction)toggleShowViewportAxes:(id)sender
{
    BOOL checked = [sender state] == NSOnState;
    [self.utilityPaneController.appFrameController.sceneViewController showViewportAxes:checked];
}

- (IBAction)toggleShowGridlines:(id)sender
{
    BOOL checked = [sender state] == NSOnState;
    [self.utilityPaneController.appFrameController.sceneViewController showGridlines:checked];
}

@end
