//
//  FLSceneView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneView.h"


@implementation FLSceneView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    [self.nextResponder mouseDown:theEvent];
    [super mouseDown:theEvent];
}



@end
