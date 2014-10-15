//
//  FLFlatBezierCurve.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/13/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLFlatBezierCurve.h"
#import "FLAnchorPointProtocol.h"

@implementation FLFlatBezierCurve

-(NSArray *)interpolatePoints:(NSArray *)points
{
    NSMutableArray *interpolatedPoints = [[NSMutableArray alloc]init];
    
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        id<FLAnchorPointProtocol> anchorPoint = obj;
        [interpolatedPoints addObject:[NSValue valueWithSCNVector3:anchorPoint.position]];
    }];
    return interpolatedPoints;
}

@end
