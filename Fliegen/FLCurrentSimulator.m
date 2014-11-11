//
//  FLCurrentSimulator.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLCurrentSimulator.h"

#import "FLConstants.h"

NSString *const FLVisualizationStreamPropertyChangedNotification = @"FLVisualizationStreamPropertyChangedNotification";
NSString *const FLSimulationStreamPropertyChangedNotification = @"FLSimulationStreamPropertyChangedNotification";

@implementation FLCurrentSimulator

@synthesize visualizationStream = _visualizationStream;
@synthesize visualizationStartTime = _visualizationStartTime;
@synthesize visualizationEndTime = _visualizationEndTime;
@synthesize selectedVisualizationAnchorPoint = _selectedVisualizationAnchorPoint;

@synthesize simulationStream = _simulationStream;
@synthesize simulationStartTime = _simulationStartTime;
@synthesize simulationEndTime = _simulationEndTime;
@synthesize selectedSimulationAnchorPoint = _selectedSimulationAnchorPoint;

-(id)init
{
    self = [super init];
    _visualizationStartTime = FL_VISUALIZATION_START_TIME_DEFAULT;
    _visualizationEndTime = _visualizationStartTime + FL_MIN_VISUALIZATION_TIME_DURATION;
    _selectedVisualizationAnchorPoint = nil;
    
    _simulationStartTime = FL_SIMULATION_START_TIME_DEFAULT;
    _simulationEndTime = _simulationStartTime + FL_MIN_SIMULATION_TIME_DURATION;
    _selectedSimulationAnchorPoint = nil;
    
    return self;
}

-(void)setSelectedVisualizationAnchorPoint:(NSObject<FLAnchorPointProtocol>*)selectedVisualizationAnchorPoint
{
    if(_selectedVisualizationAnchorPoint != selectedVisualizationAnchorPoint)
    {
        NSObject<FLAnchorPointProtocol> *oldAnchorPoint = _selectedVisualizationAnchorPoint;
        [oldAnchorPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(sampleTime))];
        [selectedVisualizationAnchorPoint addObserver:self forKeyPath:NSStringFromSelector(@selector(sampleTime))
                                              options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        
        _selectedVisualizationAnchorPoint = selectedVisualizationAnchorPoint;
        [[NSNotificationCenter defaultCenter] postNotificationName:FLVisualizationStreamPropertyChangedNotification object:self];
    }
}

-(void)setSelectedSimulationAnchorPoint:(NSObject<FLAnchorPointProtocol>*)selectedSimulationAnchorPoint
{
    if(_selectedSimulationAnchorPoint != selectedSimulationAnchorPoint)
    {
        NSObject<FLAnchorPointProtocol> *oldAnchorPoint = _selectedSimulationAnchorPoint;
        [oldAnchorPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(sampleTime))];
        [selectedSimulationAnchorPoint addObserver:self forKeyPath:NSStringFromSelector(@selector(sampleTime))
                                           options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
        
        _selectedSimulationAnchorPoint = selectedSimulationAnchorPoint;
        [[NSNotificationCenter defaultCenter] postNotificationName:FLSimulationStreamPropertyChangedNotification object:self];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(sampleTime))])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:(object == _selectedVisualizationAnchorPoint) ?
                 FLVisualizationStreamPropertyChangedNotification : FLSimulationStreamPropertyChangedNotification object:self];
    }
}

@end
