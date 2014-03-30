//
//  FLAnchorPointsCollection.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPointsCollection.h"
#import "FLAnchorPoint.h"

@implementation FLAnchorPointsCollection

-(id)init
{
    self = [super init];
    _anchorPoints = [[NSMutableArray alloc]init];
    return self;
}

-(void)appendAnchorPoint:(FLAnchorPoint *)anchorPoint
{
    anchorPoint.anchorPointID = _anchorPoints.count;
    [_anchorPoints addObject:anchorPoint];
}

@end
