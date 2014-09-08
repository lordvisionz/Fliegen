//
//  FLModel.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLModel.h"
#import "FLAnchorPointsCollection.h"

@implementation FLModel

-(id)init
{
    self = [super init];
    _anchorPointsCollection = [[FLAnchorPointsCollection alloc] init];
    
    return self;
}

@end
