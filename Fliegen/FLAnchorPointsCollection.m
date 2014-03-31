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
    _selectedAnchorPointID = NSNotFound;
    return self;
}

-(void)appendAnchorPoint:(FLAnchorPoint *)anchorPoint
{
    anchorPoint.anchorPointID = _anchorPoints.count;
    [_anchorPoints addObject:anchorPoint];
}

-(BOOL)deleteSelectedAnchorPoint
{
    if(_selectedAnchorPointID == NSNotFound) return NO;
    
    [_anchorPoints removeObjectAtIndex:[_anchorPoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        FLAnchorPoint *anchorPoint = obj;
        if(anchorPoint.anchorPointID == _selectedAnchorPointID)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }]];
    [_anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FLAnchorPoint *anchorPoint = obj;
        if(anchorPoint.anchorPointID > _selectedAnchorPointID)
        {
            anchorPoint.anchorPointID -= 1;
        }
            
    }];
    self.selectedAnchorPointID = NSNotFound;
    return YES;
}

@end
