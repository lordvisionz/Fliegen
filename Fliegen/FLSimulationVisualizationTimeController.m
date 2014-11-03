//
//  FLSimulationVisualizationTimeController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationTimeController.h"

#import "FLSimulationVisualizationView.h"

@interface FLSimulationVisualizationTimeController ()

@end

@implementation FLSimulationVisualizationTimeController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    FLSimulationVisualizationView *simVisView = [[FLSimulationVisualizationView alloc] initWithFrame:NSZeroRect];
    self.view = simVisView;
    
    return self;
}

@end
