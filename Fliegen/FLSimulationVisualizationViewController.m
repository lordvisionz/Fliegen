//
//  FLSimulationVisualizationTimeController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationViewController.h"

#import "FLSimulationVisualizationView.h"

@interface FLSimulationVisualizationViewController ()

@end

@implementation FLSimulationVisualizationViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    FLSimulationVisualizationView *simVisView = [[FLSimulationVisualizationView alloc] initWithFrame:NSZeroRect];
    self.view = simVisView;
    
    return self;
}

@end
