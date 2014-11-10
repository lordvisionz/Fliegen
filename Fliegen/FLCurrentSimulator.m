//
//  FLCurrentSimulator.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLCurrentSimulator.h"

#import "FLConstants.h"

@implementation FLCurrentSimulator

@synthesize visualizationStream = _visualizationStream;
@synthesize visualizationStartTime = _visualizationStartTime;
@synthesize visualizationEndTime = _visualizationEndTime;
@synthesize simulationStream = _simulationStream;
@synthesize simulationStartTime = _simulationStartTime;
@synthesize simulationEndTime = _simulationEndTime;

-(id)init
{
    self = [super init];
    _visualizationStartTime = FL_VISUALIZATION_START_TIME_DEFAULT;
    _visualizationEndTime = _visualizationStartTime + FL_MIN_VISUALIZATION_TIME_DURATION;
    _simulationStartTime = FL_SIMULATION_START_TIME_DEFAULT;
    _simulationEndTime = _simulationStartTime + FL_MIN_SIMULATION_TIME_DURATION;
    
    return self;
}

@end
