//
//  FLAnchorPoint.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPoint.h"

@implementation FLAnchorPoint

@synthesize anchorPointID = _anchorPointID;
@synthesize position = _position;
@synthesize stream = _stream;

-(id)initWithStream:(id<FLStreamProtocol>)stream
{
    self = [super init];
    
    _stream = stream;
    return self;
}

-(void)dealloc
{
    
}

@end
