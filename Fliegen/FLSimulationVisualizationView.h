//
//  FLSimulationVisualizationView.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FLSimulationVisualizationViewController;

@interface FLSimulationVisualizationView : NSView

@property (weak) FLSimulationVisualizationViewController *controller;

-(void)updateVisualizationStreamView;

-(void)updateSimulationStreamView;

@end
