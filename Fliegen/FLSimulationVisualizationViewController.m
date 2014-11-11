//
//  FLSimulationVisualizationTimeController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSimulationVisualizationViewController.h"
#import "FLAppFrameController.h"
#import "FLUtilityPaneController.h"
#import "FLUtilityPaneSimVisViewController.h"

#import "FLModel.h"
#import "FLStreamProtocol.h"
#import "FLStreamsCollectionProtocol.h"
#import "FLCurrentSimulatorProtocol.h"

#import "FLSimulationVisualizationView.h"

@interface FLSimulationVisualizationViewController ()
{
    FLSimulationVisualizationView *_simVisView;
}
@end

@implementation FLSimulationVisualizationViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    scrollView.autoresizesSubviews = YES;
    scrollView.hasHorizontalScroller = YES;
    
    _simVisView = [[FLSimulationVisualizationView alloc] initWithFrame:NSZeroRect];
    _simVisView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  
    scrollView.documentView = _simVisView;
    self.view = scrollView;

    _simVisView.controller = self;
    return self;
}

-(void)awakeFromNib
{
    NSObject<FLCurrentSimulatorProtocol> *currentSimulator = _appFrameController.model.simulator;
    [currentSimulator addObserver:self forKeyPath:NSStringFromSelector(@selector(visualizationStream))
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [currentSimulator addObserver:self forKeyPath:NSStringFromSelector(@selector(simulationStream))
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [_simVisView updateSimulationStreamView];
    [_simVisView updateVisualizationStreamView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visualizationPropertyChanged:)
                                                 name:FLVisualizationStreamPropertyChangedNotification object:currentSimulator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simulationPropertyChanged:)
                                                 name:FLSimulationStreamPropertyChangedNotification object:currentSimulator];
}

-(void)dealloc
{
    NSObject<FLCurrentSimulatorProtocol> *currentSimulator = _appFrameController.model.simulator;
    [currentSimulator removeObserver:self forKeyPath:NSStringFromSelector(@selector(visualizationStream))];
    [currentSimulator removeObserver:self forKeyPath:NSStringFromSelector(@selector(simulationStream))];
}

#pragma mark - KVO/Notifications

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(visualizationStream))] == YES)
    {
        [_simVisView updateVisualizationStreamView];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(simulationStream))] == YES)
    {
        [_simVisView updateSimulationStreamView];
    }
}

-(void)visualizationPropertyChanged:(NSNotification*)notification
{
    [_simVisView updateVisualizationStreamView];
}

-(void)simulationPropertyChanged:(NSNotification*)notification
{
    [_simVisView updateSimulationStreamView];
}

@end
