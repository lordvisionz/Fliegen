//
//  FLStreamView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLStreamView.h"
#import "FLAnchorPointView.h"
#import "FLCurveNode.h"

#import "FLFlatBezierCurve.h"
#import "FLBSplinesCurve.h"

#import "FLAnchorPointsCollection.h"
#import "FLAnchorPoint.h"

@interface FLStreamView()
{
    
    
    SCNNode *_curveNode;
}

@end

@implementation FLStreamView

-(id)initWithStream:(NSObject<FLStreamProtocol>*)stream
{
    self = [super init];
    _stream = stream;
    _isVisible = YES;
    _isSelectable = YES;
    _curveInterpolator = [[FLFlatBezierCurve alloc] init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anchorPointWasAdded:)
                                                name:FLAnchorPointAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anchorPointWasDeleted:)
                                                name:FLAnchorPointDeletedNotification object:nil];
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Property setters

-(void)setIsVisible:(BOOL)isVisible
{
    if(_isVisible == isVisible) return;
    
    _isVisible = isVisible;
    if(_isVisible == NO)
        self.isSelectable = NO;
    
    [self setHidden:!isVisible];
}

-(void)setIsSelectable:(BOOL)isSelectable
{
    if(isSelectable == _isSelectable) return;
    
    _isSelectable = isSelectable;
    if(_isSelectable == YES)
        self.isVisible = YES;
}

#pragma mark - Notifications/KVO

-(void)anchorPointWasAdded:(NSNotification*)notification
{
    id<FLStreamProtocol> anchorPointStream = notification.object;
    if(anchorPointStream != _stream) return;
    
    [self recomputeInterpolationCurve];
    NSObject<FLAnchorPointProtocol> *anchorPoint = [_stream.anchorPointsCollection selectedAnchorPoint];
    
    [anchorPoint addObserver:self forKeyPath:NSStringFromSelector(@selector(position)) options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)anchorPointWasDeleted:(NSNotification*)notification
{
    id<FLStreamProtocol> anchorPointStream = notification.object;
    if(anchorPointStream != _stream) return;
    
    [self recomputeInterpolationCurve];
    NSDictionary *userInfo = notification.userInfo;
    FLAnchorPoint *deletedAnchorPoint = [userInfo objectForKey:NSStringFromClass([FLAnchorPoint class])];
    [deletedAnchorPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(position))];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualType)) ] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateGeometry)];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualColor))] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateAnchorPointColor)];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamInterpolationType))] == YES)
    {
        [_curveNode removeFromParentNode];
        FLStream *stream = object;
        
        switch(stream.streamInterpolationType)
        {
            case FLStreamInterpolationTypeLinear:
            {
                _curveInterpolator = [[FLFlatBezierCurve alloc] init];
                [self recomputeInterpolationCurve];
                break;
            }
            case FLStreamInterpolationTypeBSplines:
            {
                _curveInterpolator = [[FLBSplinesCurve alloc] init];
                [self recomputeInterpolationCurve];
                break;
            }
            default:
            {
                _curveInterpolator = nil;
                break;
            }
        }
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(position))] == YES)
    {
        [self recomputeInterpolationCurve];
    }
}

#pragma mark - Private Helpers

-(void)recomputeInterpolationCurve
{
    [_curveNode removeFromParentNode];
    _curveNode = nil;
   
    NSMutableArray *scnVector3Points = [[NSMutableArray alloc] init];
    [_stream.anchorPointsCollection.anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         id<FLAnchorPointProtocol> anchorPoint = obj;
         [scnVector3Points addObject:[NSValue valueWithSCNVector3:anchorPoint.position]];
     }];
    
    NSArray *interpolatedPoints = [_curveInterpolator interpolatePoints:scnVector3Points];
    
    _curveNode = [[FLCurveNode alloc]initWithStreamView:self points:interpolatedPoints];
    [self addChildNode:_curveNode];
}

@end
