//
//  FLCurveInterpolationProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/13/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@protocol FLCurveInterpolationProtocol <NSObject>

-(NSArray*)interpolatePoints:(NSArray*)points;

-(SCNVector3)interpolatePoints:(NSArray*)points atTime:(double)t;

@end
