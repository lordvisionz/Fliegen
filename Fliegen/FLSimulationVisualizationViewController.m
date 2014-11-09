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
{
    FLSimulationVisualizationView *_simVisView;
}
@end

@implementation FLSimulationVisualizationViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    _simVisView = [[FLSimulationVisualizationView alloc] initWithFrame:NSZeroRect];
    _simVisView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.view = _simVisView;
    _simVisView.controller = self;
    return self;
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraStreamChanged:) name:NSComboBoxSelectionDidChangeNotification
                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.cameraPositionsComboBox];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCameraLookAtChanged:) name:NSComboBoxSelectionDidChangeNotification
                                               object:_appFrameController.utilityPanelController.simVisPropertiesController.cameraLookAtComboBox];
    [_simVisView updateSimulationLine];
    [_simVisView updateVisualizationLine];
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
