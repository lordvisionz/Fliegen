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
    _selectedAnchorPoint = nil;
    return self;
}

-(FLAnchorPoint *)anchorPointForId:(NSUInteger)anchorPointId
{
    if(anchorPointId > _anchorPoints.count) return nil;
    
    return [_anchorPoints objectAtIndex:(anchorPointId - 1)];
}

-(void)appendAnchorPoint:(FLAnchorPoint *)anchorPoint
{
    [_anchorPoints addObject:anchorPoint];
    anchorPoint.anchorPointID = _anchorPoints.count;
}

-(BOOL)deleteSelectedAnchorPoint
{
    if(_selectedAnchorPoint == nil) return NO;
    
    [_anchorPoints removeObjectAtIndex:[_anchorPoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        FLAnchorPoint *anchorPoint = obj;
        if(anchorPoint.anchorPointID == _selectedAnchorPoint.anchorPointID)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    [_anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FLAnchorPoint *anchorPoint = obj;
        if(anchorPoint.anchorPointID > _selectedAnchorPoint.anchorPointID)
        {
            anchorPoint.anchorPointID -= 1;
        }
            
    }];
    self.selectedAnchorPoint = nil;
    return YES;
}

@end
