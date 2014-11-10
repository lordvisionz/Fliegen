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
    _sampleTime = [[_stream anchorPointsCollection] anchorPoints].count;
    return self;
}

-(void)dealloc
{
    
}

@end
