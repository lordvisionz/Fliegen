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

#import "FLSimulationVisualizationView.h"

@interface FLSimulationVisualizationViewController ()

@end

@implementation FLSimulationVisualizationViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    FLSimulationVisualizationView *simVisView = [[FLSimulationVisualizationView alloc] initWithFrame:NSZeroRect];
    simVisView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.view = simVisView;
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraStreamChanged:) name:NSComboBoxSelectionDidChangeNotification
                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.cameraPositionsComboBox];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraLookAtChanged:) name:NSComboBoxSelectionDidChangeNotification
                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.cameraLookAtComboBox];
}

-(void)selectedCameraStreamChanged:(NSNotification*)notification
{
    NSComboBox *combobox = notification.object;

    if([combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem] != nil)
    {
        NSNumber *streamNumber = [combobox.dataSource comboBox:combobox objectValueForItemAtIndex:combobox.indexOfSelectedItem];
        NSUInteger selectedStream = [streamNumber unsignedIntegerValue];
        _selectedCameraStream = [_appFrameController.model.streams streamForId:selectedStream];
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
    }
}

@end
