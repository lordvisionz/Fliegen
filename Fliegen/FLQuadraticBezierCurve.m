//
//  FLQuadraticBezierCurve.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/14/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLQuadraticBezierCurve.h"
#import "FLAnchorPointProtocol.h"
#import "FLSceneKitUtilities.h"

@interface FLQuadraticBezierCurve()
{
    NSUInteger _subDivisionQuality;
}

@end

@implementation FLQuadraticBezierCurve

-(id)init
{
    self = [super init];
    _subDivisionQuality = 10;
    return self;
}

-(NSArray *)interpolatePoints:(NSArray *)points
{
    if(points.count < 3) return [NSArray new];
    
    NSMutableArray *interpolatedPoints = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < points.count; i=i+2)
    {
        id<FLAnchorPointProtocol> anchorPoint = [points objectAtIndex:i];
        SCNVector3 point1 = [anchorPoint position];

        if((i + 2) >= points.count) return interpolatedPoints;
        
        anchorPoint = [points objectAtIndex:i + 1];
        SCNVector3 point2 = [anchorPoint position];
        
        anchorPoint = [points objectAtIndex:i + 2];
        SCNVector3 point3 = [anchorPoint position];
        
        for(int j = 0; j <= _subDivisionQuality; j ++)
        {
            double t = (double) j / _subDivisionQuality;
            
            SCNVector3 term1 = FLMultiplyVectorByScalar(point1, pow(1 - t, 2));
            SCNVector3 term2 = FLMultiplyVectorByScalar(point2, 2 * t - 2 * t * t);
            SCNVector3 term3 = FLMultiplyVectorByScalar(point3, t * t);
            
            SCNVector3 interpolatedPoint = FLAddVectorToVector(FLAddVectorToVector(term1, term2), term3);
            [interpolatedPoints addObject:[NSValue valueWithSCNVector3:interpolatedPoint]];
        }
    }
    return interpolatedPoints;
}

@end
