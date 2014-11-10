//
//  FLSimulationVisualizationView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationView.h"

#import "FLSimulationVisualizationViewController.h"
#import "FLAppFrameController.h"

#import "FLModel.h"
#import "FLStreamProtocol.h"
#import "FLAnchorPointsCollectionProtocol.h"
#import "FLCurrentSimulatorProtocol.h"

#import "FLConstants.h"
#import "FLUtilities.m"

@interface FLSimulationVisualizationView()
{
    NSBezierPath *_visualizationLine;
    NSMutableArray *_visualizationPoints;
    NSMutableArray *_visualizationTicks;
    NSMutableDictionary *_visualizationTickLabels;
    
    NSBezierPath *_simulationLine;
    NSMutableArray *_simulationPoints;
    NSMutableArray *_simulationTicks;
    NSMutableDictionary *_simulationTickLabels;
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
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    [simulator.visualizationStream.streamVisualColor set];
    [_visualizationLine stroke];

    [_visualizationTicks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *tick = obj;
        [simulator.visualizationStream.streamVisualColor set];
        [tick stroke];
    }];
    
    [_visualizationTickLabels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSAttributedString *tickLabel = key;
        NSPoint tickLabelPosition = [obj pointValue];
        tickLabelPosition.x -= tickLabel.size.width / 2;
        [tickLabel drawAtPoint:tickLabelPosition];
    }];
    
    [simulator.simulationStream.streamVisualColor set];
    [_simulationLine stroke];
    
    [_simulationTicks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *tick = obj;
        [simulator.simulationStream.streamVisualColor set];
        [tick stroke];
    }];
    
    [_simulationTickLabels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSAttributedString *tickLabel = key;
        NSPoint tickLabelPosition = [obj pointValue];
        tickLabelPosition.x -= tickLabel.size.width / 2;
        [tickLabel drawAtPoint:tickLabelPosition];
    }];
}

-(void)updateVisualizationStreamView
{
    _visualizationLine = [NSBezierPath bezierPath];
    _visualizationPoints = [NSMutableArray new];
    _visualizationTicks = [NSMutableArray new];
    _visualizationTickLabels = [NSMutableDictionary new];
    
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSUInteger numberOfVisualizationPoints = [simulator.visualizationStream.anchorPointsCollection anchorPoints].count;
    if(numberOfVisualizationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame) / 2 - FL_SIMULATION_VISUALIZATION_HEIGHT / 2;
    
    NSUInteger startTime = simulator.visualizationStartTime;
    NSUInteger endTime = ceil(simulator.visualizationEndTime);
    double pixelsPerSecond = FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor100Pixels);
    
    NSPoint startPoint = NSMakePoint(100 , yOrigin);
    NSPoint endPoint = NSMakePoint(100 + (endTime - startTime) * pixelsPerSecond, yOrigin);
    
    [_visualizationLine moveToPoint:startPoint];
    [_visualizationLine lineToPoint:endPoint];
    
    _visualizationLine.lineWidth = 5;
    _visualizationLine.lineCapStyle = NSRoundLineCapStyle;

    for(NSUInteger i = startTime; i <= endTime; i++)
    {
        double xPos = 100 + pixelsPerSecond * i;
        NSBezierPath *tickAtSecondMark = [NSBezierPath bezierPath];
        [tickAtSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + 12)];
        [_visualizationTicks addObject:tickAtSecondMark];
        
        NSAttributedString *tickLabel = [[NSAttributedString alloc] initWithString:[[NSNumberFormatter new] stringFromNumber:[NSNumber numberWithUnsignedInteger:i]]];
        [_visualizationTickLabels setObject:[NSValue valueWithPoint:NSMakePoint(xPos, yOrigin + 12)] forKey:tickLabel];
        
        if(i == startTime) continue;
        
        xPos -= pixelsPerSecond / 2;
        NSBezierPath *tickAtHalfSecondMark = [NSBezierPath bezierPath];
        [tickAtHalfSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtHalfSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + 8)];
        [_visualizationTicks addObject:tickAtHalfSecondMark];
    }
    
//    for(NSUInteger i = 0; i < numberOfVisualizationPoints; i++)
//    {
//        NSRect anchorPointRect = NSMakeRect(100 + i * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS - 10, yOrigin - 10, 20, 20);
//        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
//        circlePath.lineWidth = 3;
//
//        [simulator.visualizationStream.streamVisualColor setFill];
//        [circlePath fill];
//
//        [[NSColor whiteColor]setStroke];
//        [circlePath stroke];
//        [_visualizationPoints addObject:circlePath];
//    }
    [self setFrameSize:NSMakeSize(MAX(NSWidth(self.frame), endPoint.x + 100), NSHeight(self.frame))];
    [self setNeedsDisplay:YES];
}

-(void)updateSimulationStreamView
{
    _simulationLine = [NSBezierPath new];
    _simulationPoints = [NSMutableArray new];
    _simulationTicks = [NSMutableArray new];
    _simulationTickLabels = [NSMutableDictionary new];
    
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSUInteger numberOfSimulationPoints = simulator.simulationStream.anchorPointsCollection.anchorPoints.count;
    if(numberOfSimulationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame)/2 + FL_SIMULATION_VISUALIZATION_HEIGHT/2;
    
    NSUInteger startTime = simulator.simulationStartTime;
    NSUInteger endTime = ceil(simulator.simulationEndTime);
    double pixelsPerSecond = FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor100Pixels);
    
    NSPoint startPoint = NSMakePoint(100, yOrigin);
    NSPoint endPoint = NSMakePoint(100 + (endTime - startTime) * pixelsPerSecond, yOrigin);

    [_simulationLine moveToPoint:startPoint];
    [_simulationLine lineToPoint:endPoint];
    
    _simulationLine.lineWidth = 5;
    _simulationLine.lineCapStyle = NSRoundLineCapStyle;
    
    for(NSUInteger i = startTime; i <= endTime; i++)
    {
        double xPos = 100 + pixelsPerSecond * i;
        NSBezierPath *tickAtSecondMark = [NSBezierPath bezierPath];
        [tickAtSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + 12)];
        [_simulationTicks addObject:tickAtSecondMark];

        NSAttributedString *tickLabel = [[NSAttributedString alloc] initWithString:[[NSNumberFormatter new] stringFromNumber:[NSNumber numberWithUnsignedInteger:i]]];
        [_simulationTickLabels setObject:[NSValue valueWithPoint:NSMakePoint(xPos, yOrigin + 12)] forKey:tickLabel];
        
        if(i == startTime) continue;
        
        xPos -= pixelsPerSecond / 2;
        NSBezierPath *tickAtHalfSecondMark = [NSBezierPath bezierPath];
        [tickAtHalfSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtHalfSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + 8)];
        [_simulationTicks addObject:tickAtHalfSecondMark];
    }
    
//    for(NSUInteger i = 0; i < numberOfSimulationPoints; i++)
//    {
//        NSRect anchorPointRect = NSMakeRect(100 + i * FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS - 10, yOrigin - 10, 20, 20);
//        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
//        circlePath.lineWidth = 3;
//        
//        [simulator.simulationStream.streamVisualColor setFill];
//        [[NSColor whiteColor] setStroke];
//        
//        [circlePath fill];
//        [circlePath stroke];
//        [_simulationPoints addObject:circlePath];
//    }
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
