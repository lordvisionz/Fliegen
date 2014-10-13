//
//  FLAnchorPointsCollection.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPointsCollection.h"
#import "FLAnchorPoint.h"

NSString *const FLAnchorPointAddedNotification = @"FLAnchorPointAddedNotification";
NSString *const FLAnchorPointDeletedNotification = @"FLAnchorPointDeletedNotification";
NSString *const FLAnchorPointSelectionChangedNotification = @"FLAnchorPointSelectionChangedNotification";

@interface FLAnchorPointsCollection()
{
    NSMutableArray *_anchorPoints;
}

@end

@implementation FLAnchorPointsCollection

@synthesize anchorPoints = _anchorPoints;
@synthesize stream = _stream;
@synthesize selectedAnchorPoint = _selectedAnchorPoint;

-(id)initWithStream:(id<FLStreamProtocol>)stream
{
    self = [super init];
    _stream = stream;
    _anchorPoints = [[NSMutableArray alloc]init];
    _selectedAnchorPoint = nil;
    return self;
}

-(FLAnchorPoint *)anchorPointForId:(NSUInteger)anchorPointId
{
    if(anchorPointId > _anchorPoints.count) return nil;
    
    return [_anchorPoints objectAtIndex:(anchorPointId - 1)];
}

-(FLAnchorPoint *)anchorPointForIndex:(NSUInteger)index
{
    if(index >= _anchorPoints.count) return nil;
    
    return [_anchorPoints objectAtIndex:index];
}

-(void)appendAnchorPoint:(FLAnchorPoint*)anchorPoint
{
    [_anchorPoints addObject:anchorPoint];
    anchorPoint.anchorPointID = _anchorPoints.count;
    self.selectedAnchorPoint = anchorPoint;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAnchorPointAddedNotification object:nil];
}

-(BOOL)deleteSelectedAnchorPoint
{
    if(_selectedAnchorPoint == nil) return NO;
    
    FLAnchorPoint *oldAnchorPoint = _selectedAnchorPoint;

    self.selectedAnchorPoint = nil;
    [_anchorPoints removeObject:oldAnchorPoint];
    
    [_anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FLAnchorPoint *anchorPoint = obj;
        if(anchorPoint.anchorPointID > oldAnchorPoint.anchorPointID)
        {
            anchorPoint.anchorPointID -= 1;
        }
    }];
    NSDictionary *userInfo = [[NSDictionary alloc]initWithObjectsAndKeys:oldAnchorPoint, NSStringFromClass([FLAnchorPoint class]), nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAnchorPointDeletedNotification object:nil userInfo:userInfo];
    return YES;
}

-(void)setSelectedAnchorPoint:(FLAnchorPoint *)selectedAnchorPoint
{
    if(selectedAnchorPoint == _selectedAnchorPoint) return;
    
    _selectedAnchorPoint = selectedAnchorPoint;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAnchorPointSelectionChangedNotification object:nil];
}

@end
