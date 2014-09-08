//
//  FLAppFrameController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAppFrameController.h"
#import "FLModel.h"

@implementation FLAppFrameController

-(id)init
{
    self = [super init];
    _model = [[FLModel alloc] init];
    
    return self;
}

- (IBAction)toggleUtilitiesPanel:(id)sender
{
    
}
@end
