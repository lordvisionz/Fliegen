//
//  FLSimulationVisualizationView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationView.h"

#import "FLSimulationVisualizationViewController.h"

@implementation FLSimulationVisualizationView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill(self.frame);
    
    [self drawSimViz];
}

-(void)drawSimViz
{
    NSSize size = self.frame.size;
    
    
}

-(void)viewDidMoveToSuperview
{
    self.frame = self.superview.frame;
}

@end
