//
//  FLFlatBezierCurve.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/13/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLFlatBezierCurve.h"
#import "FLSceneKitUtilities.h"


@implementation FLFlatBezierCurve


-(NSArray *)interpolatePoints:(NSArray *)points
{
    return points;
}

-(SCNVector3)interpolatePoints:(NSArray *)points atTime:(double)t
{
    if(t >= 1)
        return [[points lastObject] SCNVector3Value];
    
    if(points.count < 2)
        return SCNVector3Make(0, 0, 0);
    
    double approxPointCrossed = t * (points.count - 1);
    NSUInteger indexOfPointCrossed = (NSUInteger)approxPointCrossed;
    SCNVector3 pointCrossed = [[points objectAtIndex:indexOfPointCrossed] SCNVector3Value];
    SCNVector3 nextPoint = [[points objectAtIndex:indexOfPointCrossed + 1] SCNVector3Value];
    return FLLerp(pointCrossed, nextPoint, approxPointCrossed - indexOfPointCrossed);
}

@end
