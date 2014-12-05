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

typedef NS_ENUM(unsigned short, FLSimVizViewSelectionType)
{
    FLSimVizViewSelectionTypeNone = 0,
    FLVisualizationAnchorPoint = 1,
    FLSimulationAnchorPoint = 2
};

@interface FLSimulationVisualizationView()
{
    NSBezierPath *_visualizationLine;
    NSMutableArray *_visualizationPoints;
    NSMutableArray *_visualizationPointPaths;
    NSMutableArray *_visualizationTicks;
    NSMutableDictionary *_visualizationTickLabels;
    
    NSBezierPath *_simulationLine;
    NSMutableArray *_simulationPoints;
    NSMutableArray *_simulationPointPaths;
    NSMutableArray *_simulationTicks;
    NSMutableDictionary *_simulationTickLabels;
    
    NSAttributedString *_visualizationHeader;
    NSAttributedString *_simulationHeader;
    
    BOOL _isInThreeMethodApproach;
    FLSimVizViewSelectionType _selectionType;
}

@end

@implementation FLSimulationVisualizationView

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    _isInThreeMethodApproach = NO;
    _selectionType = FLSimVizViewSelectionTypeNone;
    
    NSFont *font = [NSFont systemFontOfSize:20];
    _visualizationHeader = [[NSAttributedString alloc] initWithString:@"Visualization Stream"
                                                           attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    _simulationHeader = [[NSAttributedString alloc] initWithString:@"Simulation Stream"
                                                        attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    
    return self;
}

#pragma mark - NSView overrides

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill(self.frame);
    
    [self drawSimViz];
}

-(void)viewDidMoveToSuperview
{
    self.frame = self.superview.frame;
}

-(BOOL)isFlipped
{
    return YES;
}

#pragma mark - NSResponder overrides

-(void)mouseDown:(NSEvent *)theEvent
{
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSPoint pointInRect = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSUInteger index = [_visualizationPointPaths indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *anchorPoint = obj;
        if([anchorPoint containsPoint:pointInRect] == YES)
        {
            _isInThreeMethodApproach = YES;
            _selectionType = FLVisualizationAnchorPoint;
            return YES;
        }
        return NO;
    }];
    
    if(index != NSNotFound)
    {
        [simulator setSelectedVisualizationAnchorPoint:[simulator.visualizationStream.anchorPointsCollection anchorPointForIndex:index]];
        return;
    }
    
    index = [_simulationPointPaths indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *anchorPoint = obj;
        if([anchorPoint containsPoint:pointInRect] == YES)
        {
            _isInThreeMethodApproach = YES;
            _selectionType = FLSimulationAnchorPoint;
            return YES;
        }
        return NO;
    }];
    
    if(index != NSNotFound)
        simulator.selectedSimulationAnchorPoint = [simulator.simulationStream.anchorPointsCollection anchorPointForIndex:index];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    if(_isInThreeMethodApproach == NO) return;
    
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;

    NSPoint pointInRect = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    double xPos = pointInRect.x - FL_SIMULATION_VISUALIZATION_BORDER;
    double pixelsPerSecond = FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor100Pixels);
    
    double sampleTime = xPos / pixelsPerSecond;
    
    id<FLAnchorPointProtocol> selectedAnchorPoint = (_selectionType == FLVisualizationAnchorPoint) ?
    simulator.selectedVisualizationAnchorPoint : simulator.selectedSimulationAnchorPoint;
    
    id<FLStreamProtocol> stream = selectedAnchorPoint.stream;
    
    double previousSampleTime = 0, nextSampleTime = DBL_MAX;
    
    if(selectedAnchorPoint.anchorPointID > 1)
        previousSampleTime = [[stream.anchorPointsCollection anchorPointForId:selectedAnchorPoint.anchorPointID - 1] sampleTime];
    
    if(selectedAnchorPoint.anchorPointID < [[stream.anchorPointsCollection.anchorPoints lastObject] anchorPointID])
        nextSampleTime = [[stream.anchorPointsCollection anchorPointForId:selectedAnchorPoint.anchorPointID + 1] sampleTime];
    
    sampleTime = MAX(sampleTime, previousSampleTime);
    sampleTime = MIN(sampleTime, nextSampleTime);
    
    selectedAnchorPoint.sampleTime = sampleTime;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    _isInThreeMethodApproach = NO;
}

#pragma mark - Rendering helpers

-(void)drawSimViz
{
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSUInteger connections = MIN(_simulationPoints.count, _visualizationPoints.count);
    for(NSUInteger i = 0; i < connections; i++)
    {
        NSColor *startColor = [simulator.visualizationStream streamVisualColor];
        NSColor *endColor = [[simulator simulationStream] streamVisualColor];
        
        NSPoint startPoint = [[_visualizationPoints objectAtIndex:i] pointValue];
        startPoint.x += FL_VIS_SIM_ANCHORPOINT_SIZE / 2;
        startPoint.y += FL_VIS_SIM_ANCHORPOINT_SIZE / 2;
        NSPoint endPoint = [[_simulationPoints objectAtIndex:i] pointValue];
        endPoint.x += FL_VIS_SIM_ANCHORPOINT_SIZE / 2;
        endPoint.y += FL_VIS_SIM_ANCHORPOINT_SIZE / 2;
        
        if(i % 2 == 0)
            [startColor setStroke];
        else
            [endColor setStroke];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path lineToPoint:endPoint];
        path.lineWidth = 3;
        
        [path stroke];
    }
    
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
        tickLabelPosition.y -= tickLabel.size.height;
        [tickLabel drawAtPoint:tickLabelPosition];
    }];
    [_visualizationPointPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *anchorPoint = obj;
        [simulator.visualizationStream.streamVisualColor setFill];
        if(idx == (simulator.selectedVisualizationAnchorPoint.anchorPointID - 1))
            [[NSColor darkGrayColor]setStroke];
        else
            [[NSColor whiteColor]setStroke];
        
        [anchorPoint fill];
        [anchorPoint stroke];
    }];
    
    if(simulator.visualizationStream != nil)
    {
        double yPos = (NSHeight(self.frame) - FL_SIMULATION_VISUALIZATION_HEIGHT - 200 - _visualizationHeader.size.height) / 2;
        [_visualizationHeader drawAtPoint:NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER, yPos)];
    }
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
    [_simulationPointPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSBezierPath *anchorPoint = obj;
        [simulator.simulationStream.streamVisualColor setFill];
        if(idx == (simulator.selectedSimulationAnchorPoint.anchorPointID - 1))
            [[NSColor darkGrayColor] setStroke];
        else
            [[NSColor whiteColor]setStroke];
        [anchorPoint fill];
        [anchorPoint stroke];
    }];
    
    if(simulator.simulationStream != nil)
    {
        double headerHeight = (NSHeight(self.frame) + FL_SIMULATION_VISUALIZATION_HEIGHT + 200) / 2;
        [_simulationHeader drawAtPoint:NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER, headerHeight)];
    }
}

#pragma mark - Public

-(void)updateVisualizationStreamView
{
    _visualizationLine = [NSBezierPath bezierPath];
    _visualizationPoints = [NSMutableArray new];
    _visualizationPointPaths = [NSMutableArray new];
    _visualizationTicks = [NSMutableArray new];
    _visualizationTickLabels = [NSMutableDictionary new];
    
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSUInteger numberOfVisualizationPoints = [simulator.visualizationStream.anchorPointsCollection anchorPoints].count;
    if(numberOfVisualizationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame) / 2 - FL_SIMULATION_VISUALIZATION_HEIGHT / 2;
    
    NSUInteger startTime = 0;
    NSUInteger endTime = 360;
    double pixelsPerSecond = FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor100Pixels);
    
    NSPoint startPoint = NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER , yOrigin);
    NSPoint endPoint = NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER + (endTime - startTime) * pixelsPerSecond, yOrigin);
    
    [_visualizationLine moveToPoint:startPoint];
    [_visualizationLine lineToPoint:endPoint];
    
    _visualizationLine.lineWidth = FL_VIS_SIM_LINE_SIZE;
    _visualizationLine.lineCapStyle = NSRoundLineCapStyle;
    
    double fullTickHeight = FL_VIS_SIM_FULL_TICK_HEIGHT;
    double halfTickHeight = FL_VIS_SIM_HALF_TICK_HEIGHT;
    
    for(NSUInteger i = startTime; i <= endTime; i++)
    {
        double xPos = FL_SIMULATION_VISUALIZATION_BORDER + pixelsPerSecond * i;
        NSBezierPath *tickAtSecondMark = [NSBezierPath bezierPath];
        [tickAtSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtSecondMark lineToPoint:NSMakePoint(xPos, yOrigin - fullTickHeight)];
        [_visualizationTicks addObject:tickAtSecondMark];
        
        NSAttributedString *tickLabel = [[NSAttributedString alloc] initWithString:[[NSNumberFormatter new]
                                                                  stringFromNumber:[NSNumber numberWithUnsignedInteger:i]]];
        [_visualizationTickLabels setObject:[NSValue valueWithPoint:NSMakePoint(xPos, yOrigin - fullTickHeight)] forKey:tickLabel];
        
        if(i == startTime) continue;
        
        xPos -= pixelsPerSecond / 2;
        NSBezierPath *tickAtHalfSecondMark = [NSBezierPath bezierPath];
        [tickAtHalfSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtHalfSecondMark lineToPoint:NSMakePoint(xPos, yOrigin - halfTickHeight)];
        [_visualizationTicks addObject:tickAtHalfSecondMark];
    }
    
    for(NSUInteger i = 0; i < numberOfVisualizationPoints; i++)
    {
        double sizeOfAnchorPoint = FL_VIS_SIM_ANCHORPOINT_SIZE;
        id<FLAnchorPointProtocol> anchorPoint = [simulator.visualizationStream.anchorPointsCollection anchorPointForIndex:i];
        double visualizationTime = anchorPoint.sampleTime;
        NSRect anchorPointRect = NSMakeRect(FL_SIMULATION_VISUALIZATION_BORDER + visualizationTime * pixelsPerSecond - sizeOfAnchorPoint /2,
                                            yOrigin - sizeOfAnchorPoint / 2, sizeOfAnchorPoint, sizeOfAnchorPoint);
        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
        circlePath.lineWidth = 3;
        [_visualizationPoints addObject:[NSValue valueWithPoint:anchorPointRect.origin]];
        [_visualizationPointPaths addObject:circlePath];
    }
    
    [self setFrameSize:NSMakeSize(MAX(NSWidth(self.frame), endPoint.x + FL_SIMULATION_VISUALIZATION_BORDER), NSHeight(self.frame))];
    [self setNeedsDisplay:YES];
}

-(void)updateSimulationStreamView
{
    _simulationLine = [NSBezierPath new];
    _simulationPoints = [NSMutableArray new];
    _simulationPointPaths = [NSMutableArray new];
    _simulationTicks = [NSMutableArray new];
    _simulationTickLabels = [NSMutableDictionary new];
    
    id<FLCurrentSimulatorProtocol> simulator = _controller.appFrameController.model.simulator;
    NSUInteger numberOfSimulationPoints = simulator.simulationStream.anchorPointsCollection.anchorPoints.count;
    if(numberOfSimulationPoints == 0)
        return;
    
    double yOrigin = NSHeight(self.frame)/2 + FL_SIMULATION_VISUALIZATION_HEIGHT/2;
    
    NSUInteger startTime = 0;
    NSUInteger endTime = 360;
    double pixelsPerSecond = FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor100Pixels);
    
    NSPoint startPoint = NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER, yOrigin);
    NSPoint endPoint = NSMakePoint(FL_SIMULATION_VISUALIZATION_BORDER + (endTime - startTime) * pixelsPerSecond, yOrigin);

    [_simulationLine moveToPoint:startPoint];
    [_simulationLine lineToPoint:endPoint];
    
    _simulationLine.lineWidth = 5;
    _simulationLine.lineCapStyle = NSRoundLineCapStyle;
    
    double fullTickHeight = FL_VIS_SIM_FULL_TICK_HEIGHT;
    double halfTickHeight = FL_VIS_SIM_HALF_TICK_HEIGHT;
    
    for(NSUInteger i = startTime; i <= endTime; i++)
    {
        double xPos = FL_SIMULATION_VISUALIZATION_BORDER + pixelsPerSecond * i;
        NSBezierPath *tickAtSecondMark = [NSBezierPath bezierPath];
        [tickAtSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + fullTickHeight)];
        [_simulationTicks addObject:tickAtSecondMark];

        NSAttributedString *tickLabel = [[NSAttributedString alloc] initWithString:[[NSNumberFormatter new] stringFromNumber:[NSNumber numberWithUnsignedInteger:i]]];
        [_simulationTickLabels setObject:[NSValue valueWithPoint:NSMakePoint(xPos, yOrigin + fullTickHeight)] forKey:tickLabel];
        
        if(i == startTime) continue;
        
        xPos -= pixelsPerSecond / 2;
        NSBezierPath *tickAtHalfSecondMark = [NSBezierPath bezierPath];
        [tickAtHalfSecondMark moveToPoint:NSMakePoint(xPos, yOrigin)];
        [tickAtHalfSecondMark lineToPoint:NSMakePoint(xPos, yOrigin + halfTickHeight)];
        [_simulationTicks addObject:tickAtHalfSecondMark];
    }
    
    for(NSUInteger i = 0; i < numberOfSimulationPoints; i++)
    {
        id<FLAnchorPointProtocol> anchorPoint = [simulator.simulationStream.anchorPointsCollection anchorPointForIndex:i];
        double simulationTime = anchorPoint.sampleTime;
        double sizeOfAnchorPoint = FL_VIS_SIM_ANCHORPOINT_SIZE;
        
        NSRect anchorPointRect = NSMakeRect(FL_SIMULATION_VISUALIZATION_BORDER + simulationTime * pixelsPerSecond - sizeOfAnchorPoint / 2,
                                            yOrigin - sizeOfAnchorPoint / 2, sizeOfAnchorPoint, sizeOfAnchorPoint);
        NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:anchorPointRect];
        circlePath.lineWidth = 3;
        [_simulationPoints addObject:[NSValue valueWithPoint:anchorPointRect.origin]];
        [_simulationPointPaths addObject:circlePath];
    }
    [self setFrameSize:NSMakeSize(MAX(NSWidth(self.frame), endPoint.x + FL_SIMULATION_VISUALIZATION_BORDER), NSHeight(self.frame))];
    [self setNeedsDisplay:YES];
}

@end
