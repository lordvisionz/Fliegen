//
//  FLCurrentSimulatorProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLStreamProtocol.h"

extern NSString *const FLVisualizationStreamPropertyChangedNotification;
extern NSString *const FLSimulationStreamPropertyChangedNotification;

@protocol FLCurrentSimulatorProtocol <NSObject>

@property (readwrite, nonatomic) id<FLStreamProtocol> visualizationStream;
@property (readwrite, nonatomic) double visualizationStartTime;
@property (readwrite, nonatomic) double visualizationEndTime;
@property (readwrite, nonatomic) id<FLAnchorPointProtocol> selectedVisualizationAnchorPoint;

@property (readwrite, nonatomic) id<FLStreamProtocol> simulationStream;
@property (readwrite, nonatomic) double simulationStartTime;
@property (readwrite, nonatomic) double simulationEndTime;
@property (readwrite, nonatomic) id<FLAnchorPointProtocol> selectedSimulationAnchorPoint;

-(NSString*)parseCurrentSimulation;

@end
