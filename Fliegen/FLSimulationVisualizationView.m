//
//  FLSimulationVisualizationView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationView.h"

@implementation FLSimulationVisualizationView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)viewDidMoveToSuperview
{
    self.frame = self.superview.frame;
}

@end
