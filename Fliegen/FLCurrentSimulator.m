//
//  FLCurrentSimulator.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLCurrentSimulator.h"

#import "FLConstants.h"
#import "FLStreamProtocol.h"
#import "FLAnchorPointsCollectionProtocol.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simulatorPropertiesChanged:)
                                                 name:FLAnchorPointAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simulatorPropertiesChanged:)
                                                 name:FLAnchorPointDeletedNotification object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    }
}

-(void)setVisualizationStream:(NSObject<FLStreamProtocol>*)visualizationStream
{
    if(_visualizationStream != visualizationStream)
    {
        NSObject<FLStreamProtocol>* oldVisualizationStream = _visualizationStream;
        [oldVisualizationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamId))];
        [oldVisualizationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamType))];
        [oldVisualizationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamVisualColor))];
        
        [visualizationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamId))
                                 options:NSKeyValueObservingOptionNew context:NULL];
        [visualizationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamType))
                                 options:NSKeyValueObservingOptionNew context:NULL];
        [visualizationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamVisualColor))
                                 options:NSKeyValueObservingOptionNew context:NULL];

        _visualizationStream = visualizationStream;
    }
}

-(void)setSimulationStream:(NSObject<FLStreamProtocol>*)simulationStream
{
    if(_simulationStream != simulationStream)
    {
        NSObject<FLStreamProtocol> *oldSimulationStream = _simulationStream;
        [oldSimulationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamId))];
        [oldSimulationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamType))];
        [oldSimulationStream removeObserver:self forKeyPath:NSStringFromSelector(@selector(streamVisualColor))];
        
        [simulationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamId))
                                 options:NSKeyValueObservingOptionNew context:NULL];
        [simulationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamType))
                                 options:NSKeyValueObservingOptionNew context:NULL];
        [simulationStream addObserver:self forKeyPath:NSStringFromSelector(@selector(streamVisualColor))
                                 options:NSKeyValueObservingOptionNew context:NULL];
        _simulationStream = simulationStream;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(sampleTime))])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:(object == _selectedVisualizationAnchorPoint) ?
                 FLVisualizationStreamPropertyChangedNotification : FLSimulationStreamPropertyChangedNotification object:self];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamId))] ||
            [keyPath isEqualToString:NSStringFromSelector(@selector(streamType))] ||
            [keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualColor))])
    {
        if(object == _simulationStream)
            [[NSNotificationCenter defaultCenter] postNotificationName:FLSimulationStreamPropertyChangedNotification object:self];
        else if(object == _visualizationStream)
            [[NSNotificationCenter defaultCenter] postNotificationName:FLVisualizationStreamPropertyChangedNotification object:self];
    }
}

-(void)simulatorPropertiesChanged:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FLVisualizationStreamPropertyChangedNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLSimulationStreamPropertyChangedNotification object:self];
}

@end
