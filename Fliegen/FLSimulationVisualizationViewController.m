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
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraStreamChanged:) name:NSComboBoxSelectionDidChangeNotification
//                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.visualizationStreamComboBox];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraLookAtChanged:) name:NSComboBoxSelectionDidChangeNotification
//                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.simulationStreamComboBox];
    NSObject<FLCurrentSimulatorProtocol> *currentSimulator = _appFrameController.model.simulator;
    [currentSimulator addObserver:self forKeyPath:NSStringFromSelector(@selector(visualizationStream))
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [currentSimulator addObserver:self forKeyPath:NSStringFromSelector(@selector(simulationStream))
                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [_simVisView updateSimulationLine];
    [_simVisView updateVisualizationLine];
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
        _selectedCameraStream = _appFrameController.model.simulator.visualizationStream;
        [_simVisView updateVisualizationLine];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(simulationStream))] == YES)
    {
        _selectedCameraLookAt = _appFrameController.model.simulator.simulationStream;
        [_simVisView updateSimulationLine];
    }
}

-(void)selectedCameraStreamChanged:(NSNotification*)notification
{
    NSComboBox *combobox = notification.object;

    if([combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem] != nil)
    {
        NSNumber *streamNumber = [combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem];
        NSUInteger selectedStream = [streamNumber unsignedIntegerValue];
        _selectedCameraStream = [_appFrameController.model.streams streamForId:selectedStream];
        [_simVisView updateVisualizationLine];
    }
}

-(void)selectedCameraLookAtChanged:(NSNotification*)notification
{
    NSComboBox *combobox = notification.object;
    
    if([combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem] != nil)
    {
        NSNumber *streamNumber = [combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem];
        NSUInteger selectedStream = [streamNumber unsignedIntegerValue];
        _selectedCameraLookAt = [_appFrameController.model.streams streamForId:selectedStream];
        [_simVisView updateSimulationLine];
    }
}



@end
