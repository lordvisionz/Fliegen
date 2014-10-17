//
//  FLBSplinesCurve.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/16/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLBSplinesCurve.h"
#import <SceneKit/SceneKit.h>
#import "FLSceneKitUtilities.h"

@interface FLBSplinesCurve()
{
    NSUInteger _steps;
}

@end

@implementation FLBSplinesCurve

-(id)init
{
    self = [super init];
    _steps = 200;
    return self;
}

-(NSArray *)interpolatePoints:(NSArray *)points
{
    if(points.count < 5) return nil;
    
    NSMutableArray *interpolatedPoints = [NSMutableArray new];
    
    NSUInteger n = points.count;
    NSUInteger m = n + 4;
    NSUInteger p = m - n - 1;
    
    double T[m];
    T[0] = 0;
    T[1] = 0;
    T[2] = 0;
    T[3] = 0;
    
    NSUInteger internalKnotsCount = m - 2 * (p + 1);
    for(int i = 0; i < internalKnotsCount; i++)
    {
        T[4+i] = (double)1 / (internalKnotsCount + 1);
    }
    T[n] = 1;
    T[n+1] = 1;
    T[n+2] = 1;
    T[n+3] = 1;
    
    for(int x = 0; x < _steps; x++)
    {
        double t = (double)x / _steps;
        SCNVector3 Ct = SCNVector3Make(0, 0, 0);
        
        for(NSUInteger i = 0; i < points.count; i++)
        {
            SCNVector3 Pi = [[points objectAtIndex:i] SCNVector3Value];
            double Nipt = [self computeNijtWithI:i j:p t:t T:T];
            SCNVector3 Ci = FLMultiplyVectorByScalar(Pi, Nipt);
            Ct = FLAddVectorToVector(Ct, Ci);
        }
        [interpolatedPoints addObject:[NSValue valueWithSCNVector3:Ct]];
    }
    
    return interpolatedPoints;
}

-(double) computeNijtWithI:(NSUInteger)i j:(NSUInteger)j t:(double)t T:(double[])T
{
    if(j == 0)
    {
        if(T[i] <= t && t < T[i + 1])
        {
            if(T[i] < T[i+1])
                return 1;
        }
        return 0;
    }
    double leftSideNumerator  = (t - T[i]);
    double leftSideDenominator = T[i+j]- T[i];
    double leftSide = (leftSideDenominator == 0) ? 0 : (leftSideNumerator/leftSideDenominator) *
    [self computeNijtWithI:i j:(j - 1) t:t T:T];
    
    double rightSideNumerator = T[i+j+1] - t;
    double rightSideDenominator = T[i+j+1] - T[i+1];
    double rightSide =(rightSideDenominator == 0) ? 0 : (rightSideNumerator/rightSideDenominator) *
    [self computeNijtWithI:(i+1) j:(j-1) t:t T:T];
    
    return leftSide + rightSide;
}

@end
