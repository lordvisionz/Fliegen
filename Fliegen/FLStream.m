//
//  FLStream.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLStream.h"
#import "FLAnchorPointsCollection.h"

@implementation FLStream

@synthesize streamId = _streamId;
@synthesize streamType = _streamType;
@synthesize streamVisualType = _streamVisualType;
@synthesize streamVisualColor = _streamVisualColor;
@synthesize streamInterpolationType = _streamInterpolationType;
@synthesize anchorPointsCollection = _anchorPointsCollection;

-(id)init
{
    self = [super init];
    _anchorPointsCollection = [[FLAnchorPointsCollection alloc] initWithStream:self];
    _streamVisualColor = [NSColor cyanColor];
    _streamInterpolationType = FLStreamInterpolationTypeFlat;
    
    return self;
}

@end
