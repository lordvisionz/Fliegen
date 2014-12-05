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
@synthesize selectedVisualizationAnchorPoint = _selectedVisualizationAnchorPoint;

@synthesize simulationStream = _simulationStream;
@synthesize selectedSimulationAnchorPoint = _selectedSimulationAnchorPoint;

-(id)init
{
    self = [super init];

    _selectedVisualizationAnchorPoint = nil;
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

#pragma mark - Public methods

-(NSString *)parseCurrentSimulation
{
    if(_visualizationStream == nil || _simulationStream == nil) return @"";
    
    NSMutableString *output = [NSMutableString new];
    NSUInteger visualizationPoints = _visualizationStream.anchorPointsCollection.anchorPoints.count;
    NSUInteger simulationPoints = _simulationStream.anchorPointsCollection.anchorPoints.count;
    NSUInteger totalPoints = MIN(visualizationPoints, simulationPoints);
    
    double totalVisualizationTime = [[_visualizationStream.anchorPointsCollection anchorPointForId:totalPoints] sampleTime] * 1000;
    double fps = 24.0;
    NSString *visualizationStreamInterpolator = (_visualizationStream.streamInterpolationType == FLStreamInterpolationTypeBSplines)
    ? @"B-Splines" : @"Linear";
    NSString *simulationStreamInterpolator = (_simulationStream.streamInterpolationType == FLStreamInterpolationTypeBSplines)
    ? @"B-Splines" : @"Linear";
    
    [output appendFormat:@"length %f",totalVisualizationTime];
    [output appendString:@"\n\n"];
    [output appendFormat:@"fps %f", fps];
    [output appendString:@"\n\n"];
    [output appendString:@"stream simulationTime {\n\tname \"simulationTime\"\n\ttype double\n\tinterpolator Linear\n}"];
    [output appendString:@"\n\n"];
    [output appendFormat:@"stream cameraPosition {\n\tname \"cameraPosition\"\n\ttype vector\n\tinterpolator %@\n}",visualizationStreamInterpolator];
    [output appendString:@"\n\n"];
    [output appendFormat:@"stream lookAt {\n\tname \"lookAt\"\n\ttype vector\n\tinterpolator %@\n}",simulationStreamInterpolator];
    [output appendString:@"\n\n"];
    
    for(NSUInteger i = 0; i < totalPoints; i++)
    {
        id<FLAnchorPointProtocol> visualizationAnchorPoint = [_visualizationStream.anchorPointsCollection anchorPointForIndex:i];
        id<FLAnchorPointProtocol> simulationAnchorPoint = [_simulationStream.anchorPointsCollection anchorPointForIndex:i];
        
        double visualizationTime = [visualizationAnchorPoint sampleTime] * 1000;
        double simulationTime = [simulationAnchorPoint sampleTime] * 1000;
        SCNVector3 cameraPosition = visualizationAnchorPoint.position;
        SCNVector3 lookAt = simulationAnchorPoint.position;
        
        [output appendFormat:@"time %f {\n\tcameraPosition(%f, %f, %f)\n\tlookAt(%f, %f, %f)\n\tsimulationTime %f\n}", visualizationTime,
         cameraPosition.x, cameraPosition.y, cameraPosition.z, lookAt.x, lookAt.y, lookAt.z, simulationTime];
        [output appendString:@"\n\n"];
    }
    
    return output;
}

@end
