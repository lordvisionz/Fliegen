//
//  FLAnchorPoint.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPoint.h"
#import "FLStreamProtocol.h"

@implementation FLAnchorPoint

@synthesize anchorPointID = _anchorPointID;
@synthesize position = _position;
@synthesize stream = _stream;
@synthesize sampleTime = _sampleTime;

-(id)initWithStream:(id<FLStreamProtocol>)stream
{
    self = [super init];
    
    _stream = stream;
    id<FLAnchorPointProtocol> lastAnchorPoint = [stream.anchorPointsCollection.anchorPoints lastObject];
    _sampleTime = (lastAnchorPoint == nil) ? 0 : lastAnchorPoint.sampleTime + 1;
    
    return self;
}

-(void)dealloc
{
    
}

-(void)setSampleTime:(double)sampleTime
{
    double previousSampleTime = (_anchorPointID == 1) ? 0 : [_stream.anchorPointsCollection anchorPointForId:(_anchorPointID - 1)].sampleTime;
    double nextSampleTime = (_anchorPointID == _stream.anchorPointsCollection.anchorPoints.count) ?
    DBL_MAX : [_stream.anchorPointsCollection anchorPointForId:(_anchorPointID + 1)].sampleTime;
    
    if(sampleTime < _sampleTime)
    {
        _sampleTime = MAX(sampleTime, previousSampleTime);
    }
    else if(sampleTime > _sampleTime)
    {
        _sampleTime = MIN(sampleTime, nextSampleTime);
    }
}

@end
