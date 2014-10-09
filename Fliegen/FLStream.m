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

-(id)init
{
    self = [super init];
    _anchorPoints = [[FLAnchorPointsCollection alloc] init];
    
    return self;
}

@end
