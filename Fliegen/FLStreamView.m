//
//  FLStreamView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLStreamView.h"
#import "FLAnchorPointView.h"

#import "FLFlatBezierCurve.h"
#import "FLCubicBezierCurve.h"
#import "FLAnchorPointsCollection.h"

@interface FLStreamView()
{
    id<FLCurveInterpolationProtocol> _curveInterpolator;
}

@end

@implementation FLStreamView

-(id)initWithStream:(NSObject<FLStreamProtocol>*)stream
{
    self = [super init];
    _stream = stream;
    _isVisible = YES;
    _isSelectable = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anchorPointWasAdded:)
                                                name:FLAnchorPointAddedNotification object:nil];
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
//    FLStream *stream =
//    NSArray *interpolatedPoints = _curveInterpolator interpolatePoints:<#(NSArray *)#>
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(streamType))] == YES)
    {

    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualType)) ] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateGeometry)];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualColor))] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateAnchorPointColor)];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamInterpolationType))] == YES)
    {
        FLStream *stream = object;
        switch(stream.streamInterpolationType)
        {
            case FLStreamInterpolationTypeFlat:
            {
                _curveInterpolator = [[FLFlatBezierCurve alloc] init];
                break;
            }
            case FLStreamInterpolationTypeCubicBezier:
            {
                _curveInterpolator = [[FLCubicBezierCurve alloc] init];
                break;
            }
            default:
            {
                _curveInterpolator = nil;
                break;
            }
        }
    }
}

@end
