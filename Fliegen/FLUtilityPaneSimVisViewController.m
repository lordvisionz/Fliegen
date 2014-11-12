//
//  FLUtilityPaneSimVisViewController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 11/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneSimVisViewController.h"
#import "FLUtilityPaneController.h"
#import "FLAppFrameController.h"
#import "FLModel.h"
#import "FLConstants.h"

#import "FLStreamsCollectionProtocol.h"
#import "FLCurrentSimulatorProtocol.h"

@interface FLUtilityPaneSimVisViewController ()
{
    FLVisualizationSimulationScaleFactor _visualizationScaleFactor;
    FLVisualizationSimulationScaleFactor _simulationScaleFactor;
}
@end

@implementation FLUtilityPaneSimVisViewController

-(void)awakeFromNib
{
    NSObject<FLCurrentSimulatorProtocol> *simulator = _utilityPaneController.appFrameController.model.simulator;
    [simulator addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedSimulationAnchorPoint))
                   options:NSKeyValueObservingOptionNew context:NULL];
    [simulator addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedVisualizationAnchorPoint))
                   options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visualizationPropertiesChanged:)
                                                 name:FLVisualizationStreamPropertyChangedNotification object:simulator];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simulationpropertiesChanged:)
                                                 name:FLSimulationStreamPropertyChangedNotification object:simulator];
    
    [_visualizationScaleFactorButton selectItemAtIndex:FLVisualizationSimulationScaleFactor100Pixels];
    [_simulationScaleFactorButton selectItemAtIndex:FLVisualizationSimulationScaleFactor100Pixels];
}

-(void)dealloc
{
    NSObject<FLCurrentSimulatorProtocol> *simulator = _utilityPaneController.appFrameController.model.simulator;
    [simulator removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedSimulationAnchorPoint))];
    [simulator removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedVisualizationAnchorPoint))];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - KVO/Notifications

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualTo:NSStringFromSelector(@selector(selectedSimulationAnchorPoint))] == YES)
    {
        id<FLCurrentSimulatorProtocol> simulator = object;
        NSUInteger anchorPointID = [simulator.selectedSimulationAnchorPoint anchorPointID];
        [_simulationSelectedAnchorPointComboBox selectItemAtIndex:anchorPointID];
    }
    else if([keyPath isEqualTo:NSStringFromSelector(@selector(selectedVisualizationAnchorPoint))] == YES)
    {
        id<FLCurrentSimulatorProtocol> simulator = object;
        NSUInteger anchorPointID = [simulator.selectedVisualizationAnchorPoint anchorPointID];
        [_visualizationStreamSelectedAnchorPointComboBox selectItemAtIndex:anchorPointID];
    }
}

-(void)visualizationPropertiesChanged:(NSNotification*)notification
{
    id<FLCurrentSimulatorProtocol> currentSimulator = _utilityPaneController.appFrameController.model.simulator;
    _visualizationAnchorPointTimeTextField.doubleValue = currentSimulator.selectedVisualizationAnchorPoint.sampleTime;
}

-(void)simulationpropertiesChanged:(NSNotification*)notification
{
    id<FLCurrentSimulatorProtocol> currentSimulator = _utilityPaneController.appFrameController.model.simulator;
    _simulationAnchorPointTimeTextField.doubleValue = currentSimulator.selectedSimulationAnchorPoint.sampleTime;
}

#pragma mark - Combobox delegate/datasource

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    if(aComboBox == _visualizationStreamComboBox || aComboBox == _simulationStreamComboBox)
    {
        id<FLStreamsCollectionProtocol> streams = _utilityPaneController.appFrameController.model.streams;
        return [streams streamsWithStreamType:(aComboBox == _visualizationStreamComboBox) ? FLStreamTypePosition : FLStreamTypeLookAt].count;
    }
    else if(aComboBox == _visualizationStreamSelectedAnchorPointComboBox)
    {
        id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
        return simulator.visualizationStream.anchorPointsCollection.anchorPoints.count + 1;
    }
    else if(aComboBox == _simulationSelectedAnchorPointComboBox)
    {
        id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
        return simulator.simulationStream.anchorPointsCollection.anchorPoints.count + 1;
    }
    return 0;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if(aComboBox == _visualizationStreamComboBox || aComboBox == _simulationStreamComboBox)
    {
        id<FLStreamsCollectionProtocol> streams = _utilityPaneController.appFrameController.model.streams;
        id<FLStreamProtocol> stream = [[streams streamsWithStreamType:(aComboBox == _visualizationStreamComboBox) ? FLStreamTypePosition : FLStreamTypeLookAt] objectAtIndex:index];
        return [NSNumber numberWithInteger:[stream streamId]];
    }
    else if(aComboBox == _visualizationStreamSelectedAnchorPointComboBox)
    {
        id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
        if(index == 0) return @"No Selection";
        
        id<FLAnchorPointProtocol> anchorPoint = [simulator.visualizationStream.anchorPointsCollection anchorPointForId:index];
        return [NSNumber numberWithUnsignedInteger:anchorPoint.anchorPointID];
    }
    else if (aComboBox == _simulationSelectedAnchorPointComboBox)
    {
        id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
        if(index == 0) return @"No Selection";
        
        id<FLAnchorPointProtocol> anchorPoint = [simulator.simulationStream.anchorPointsCollection anchorPointForId:index];
        return [NSNumber numberWithUnsignedInteger:anchorPoint.anchorPointID];
    }
    return nil;
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    id combobox = notification.object;
    id<FLCurrentSimulatorProtocol> currentSimulator = _utilityPaneController.appFrameController.model.simulator;

    if(combobox == _visualizationStreamComboBox)
    {
        NSNumber *streamNumber = [self comboBox:combobox objectValueForItemAtIndex:[combobox indexOfSelectedItem]];
        currentSimulator.visualizationStream = [_utilityPaneController.appFrameController.model.streams streamForId:streamNumber.unsignedIntegerValue];
        id<FLAnchorPointProtocol> anchorPoint = [currentSimulator.visualizationStream.anchorPointsCollection.anchorPoints lastObject];
        [self.visualizationEndTimeTextField setDoubleValue:MAX(anchorPoint.sampleTime, FL_MIN_VISUALIZATION_TIME_DURATION)];
        
        [_visualizationStreamSelectedAnchorPointComboBox reloadData];
        [_visualizationStreamSelectedAnchorPointComboBox selectItemAtIndex:0];
    }
    else if(combobox == _simulationStreamComboBox)
    {
        NSNumber *streamNumber = [self comboBox:combobox objectValueForItemAtIndex:[combobox indexOfSelectedItem]];
        currentSimulator.simulationStream = [_utilityPaneController.appFrameController.model.streams streamForId:streamNumber.unsignedIntegerValue];
        id<FLAnchorPointProtocol> anchorPoint = [currentSimulator.simulationStream.anchorPointsCollection.anchorPoints lastObject];
        [self.simulationEndTimeTextField setDoubleValue:MAX(anchorPoint.sampleTime, FL_MIN_SIMULATION_TIME_DURATION)];
        
        [_simulationSelectedAnchorPointComboBox reloadData];
        [_simulationSelectedAnchorPointComboBox selectItemAtIndex:0];
    }
    else if(combobox == _visualizationStreamSelectedAnchorPointComboBox)
    {
        NSUInteger index = [_visualizationStreamSelectedAnchorPointComboBox indexOfSelectedItem];
        [currentSimulator setSelectedVisualizationAnchorPoint:(index == 0) ? nil : [currentSimulator.visualizationStream.anchorPointsCollection anchorPointForId:index]];
        [_visualizationAnchorPointTimeTextField setEnabled:(index > 0)];
        _visualizationAnchorPointTimeTextField.doubleValue = currentSimulator.selectedVisualizationAnchorPoint.sampleTime;
        
    }
    else if(combobox == _simulationSelectedAnchorPointComboBox)
    {
        NSUInteger index = [_simulationSelectedAnchorPointComboBox indexOfSelectedItem];
        [currentSimulator setSelectedSimulationAnchorPoint:(index == 0) ? nil : [currentSimulator.simulationStream.anchorPointsCollection anchorPointForId:index]];
        [_simulationAnchorPointTimeTextField setEnabled:(index > 0)];
        _simulationAnchorPointTimeTextField.doubleValue = currentSimulator.selectedSimulationAnchorPoint.sampleTime;
    }
}

#pragma mark - NSTextField delegate

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if(commandSelector == @selector(insertNewline:))
    {
        id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
        
        if(control == _visualizationAnchorPointTimeTextField)
        {
            [simulator.selectedVisualizationAnchorPoint setSampleTime:_visualizationAnchorPointTimeTextField.doubleValue];
            _visualizationAnchorPointTimeTextField.doubleValue = simulator.selectedVisualizationAnchorPoint.sampleTime;
            
        }
        else if(control == _simulationAnchorPointTimeTextField)
        {
            [simulator.selectedSimulationAnchorPoint setSampleTime:_simulationAnchorPointTimeTextField.doubleValue];
            _simulationAnchorPointTimeTextField.doubleValue = simulator.selectedSimulationAnchorPoint.sampleTime;
        }
        return YES;
    }
    return NO;
}

#pragma mark - public helpers

-(void)viewDidAppear
{
    [_simulationStreamComboBox reloadData];
    [_visualizationStreamComboBox reloadData];
    
    if(_simulationStreamComboBox.numberOfItems > 0)
       [_simulationStreamComboBox selectItemAtIndex:0];
    
    if(_visualizationStreamComboBox.numberOfItems > 0)
        [_visualizationStreamComboBox selectItemAtIndex:0];
}

@end
