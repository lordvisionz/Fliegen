//
//  FLSimulationVisualizationView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationView.h"

#import "FLSimulationVisualizationViewController.h"
#import "FLStreamProtocol.h"
#import "FLAnchorPointsCollectionProtocol.h"

#import "FLConstants.h"

@interface FLSimulationVisualizationView()
{
    NSBezierPath *_visualizationLine;
    NSMutableArray *_visualizationPoints;
    
    NSBezierPath *_simulationLine;
    NSMutableArray *_simulationPoints;
}

@end

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
    [self updateVisualizationLine];
    [self updateSimulationLine];
}

-(void)updateVisualizationLine
{
    if(self.superview == nil)
    {
        return;
    }
    _visualizationLine = [NSBezierPath bezierPath];
    _visualizationPoints = [NSMutableArray new];

    NSUInteger numberOfVisualizationPoints = [_controller.selectedCameraStream.anchorPointsCollection anchorPoints].count;
    if(numberOfVisualizationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame) / 2 - FL_SIMULATION_VISUALIZATION_HEIGHT / 2;
    
    NSPoint startPoint = NSMakePoint(100, yOrigin);
    NSPoint endPoint = NSMakePoint(100 + (numberOfVisualizationPoints - 1) * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS, yOrigin);
    
    [_visualizationLine moveToPoint:startPoint];
    [_visualizationLine lineToPoint:endPoint];
    
    _visualizationLine.lineWidth = 5;
    _visualizationLine.lineCapStyle = NSRoundLineCapStyle;
    [_controller.selectedCameraStream.streamVisualColor set];
    [_visualizationLine stroke];
    
    for(NSUInteger i = 0; i < numberOfVisualizationPoints; i++)
    {
        NSRect anchorPointRect = NSMakeRect(100 + i * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS - 10, yOrigin - 10, 20, 20);
        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
        circlePath.lineWidth = 3;

        [_controller.selectedCameraStream.streamVisualColor setFill];
        [circlePath fill];

        [[NSColor whiteColor]setStroke];
        [circlePath stroke];
        [_visualizationPoints addObject:circlePath];
    }
    [self setFrameSize:NSMakeSize(MAX(NSWidth(self.frame), endPoint.x + 100), NSHeight(self.frame))];
    [self setNeedsDisplay:YES];
}

-(void)updateSimulationLine
{
    if(self.superview == nil)
    {
        return;
    }
    
    _simulationLine = [NSBezierPath new];
    _simulationPoints = [NSMutableArray new];
    
    NSUInteger numberOfSimulationPoints = _controller.selectedCameraLookAt.anchorPointsCollection.anchorPoints.count;
    if(numberOfSimulationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame)/2 + FL_SIMULATION_VISUALIZATION_HEIGHT/2;
    
    NSPoint startPoint = NSMakePoint(100, yOrigin);
    NSPoint endPoint = NSMakePoint(100 + (numberOfSimulationPoints - 1) * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS, yOrigin);

    [_simulationLine moveToPoint:startPoint];
    [_simulationLine lineToPoint:endPoint];
    
    _simulationLine.lineWidth = 5;
    _simulationLine.lineCapStyle = NSRoundLineCapStyle;
    
    [_controller.selectedCameraLookAt.streamVisualColor set];
    [_simulationLine stroke];
    
    for(NSUInteger i = 0; i < numberOfSimulationPoints; i++)
    {
        NSRect anchorPointRect = NSMakeRect(100 + i * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS - 10, yOrigin - 10, 20, 20);
        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
        circlePath.lineWidth = 3;
        
        [_controller.selectedCameraLookAt.streamVisualColor setFill];
        [[NSColor whiteColor] setStroke];
        
        [circlePath fill];
        [circlePath stroke];
        [_simulationPoints addObject:circlePath];
    }
    [self setFrameSize:NSMakeSize(MAX(NSWidth(self.frame), endPoint.x + 100), NSHeight(self.frame))];
    [self setNeedsDisplay:YES];
}

-(void)viewDidMoveToSuperview
{
    self.frame = self.superview.frame;
}

-(BOOL)isFlipped
{
    return YES;
}

@end
