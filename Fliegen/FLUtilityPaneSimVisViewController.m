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
//    id<FLCurrentSimulatorProtocol> simulator = _utilityPaneController.appFrameController.model.simulator;
    [_visualizationScaleFactorButton selectItemAtIndex:FLVisualizationSimulationScaleFactor100Pixels];
    
    [_simulationScaleFactorButton selectItemAtIndex:FLVisualizationSimulationScaleFactor100Pixels];
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
