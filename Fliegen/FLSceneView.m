//
//  FLSceneView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneView.h"
#import "FLSceneViewController.h"

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
    [_controller mouseDown:theEvent];
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    FLSceneViewController *controller = (FLSceneViewController*)_controller;
    if([controller mouseDragged:theEvent] == NO)
        [super mouseDragged:theEvent];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    [_controller mouseUp:theEvent];
    [super mouseUp:theEvent];
}

@end
