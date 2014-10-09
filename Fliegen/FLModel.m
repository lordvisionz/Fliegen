//
//  FLModel.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLModel.h"
#import "FLStreamsCollection.h"

@implementation FLModel

-(id)init
{
    self = [super init];
    _streams = [[FLStreamsCollection alloc] init];
    
    return self;
}

@end
