//
//  FLStreamsViewController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneStreamsViewController.h"
#import "FLUtilityPaneController.h"
#import "FLAppFrameController.h"
#import "FLSceneViewController.h"
#import "FLSceneViewController_FLPrivateHelpers.h"
#import "FLAnchorPointsCollection.h"

#import "FLModel.h"
#import "FLStream.h"
#import "FLStreamsCollection.h"

#import "FLStreamView.h"

@implementation FLUtilityPaneStreamsViewController

#pragma mark - Init

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    FLStreamsCollection *streams = self.utilityPaneController.appFrameController.model.streams;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasAdded:)
                                                 name:FLStreamAddedNotification object:streams];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasDeleted:)
                                                 name:FLStreamDeletedNotification object:streams];
    [streams addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedStream))
                 options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anchorPointWasAdded:)
                                                name:FLAnchorPointAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(anchorPointWasDeleted:)
                                                name:FLAnchorPointDeletedNotification object:nil];
    
    [_visualizationTime setDoubleValue:10];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications/KVO

-(void)anchorPointWasAdded:(NSNotification*)notification
{
    [self updateAnchorPointsCountLabel];
}

-(void)anchorPointWasDeleted:(NSNotification*)notification
{
    [self updateAnchorPointsCountLabel];
}

-(void)streamWasAdded:(NSNotification*)notification
{
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeStreams;
    self.utilityPaneController.utilityPaneSegmentedControl.selectedSegment = 1;
    [self.utilityPaneController switchUtilityPaneTab:nil];
}

-(void)streamWasDeleted:(NSNotification*)notification
{
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
    [self.streamIDComboBox reloadData];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(selectedStream))])
    {
        FLStream *selectedStream = [object selectedStream];
        FLStreamView *viewForStream = [self.utilityPaneController.appFrameController.sceneViewController viewForStream:selectedStream];
        
        if(selectedStream == nil)
        {
            self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
        }
        else
        {
            self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeStreams;;
            [self.streamColorPicker setColor:selectedStream.streamVisualColor];
        }
        [self.streamIDComboBox reloadData];
        [self.streamIDComboBox selectItemAtIndex:selectedStream.streamId];
        
        [self.streamTypePopupButton selectItemAtIndex:selectedStream.streamType];
        [self.streamVisualPopupButton selectItemAtIndex:selectedStream.streamVisualType];
        self.streamsVisibilityCheckBox.state = (viewForStream.isVisible) ? NSOnState : NSOffState;
        self.streamsSelectabilityCheckBox.state = viewForStream.isSelectable ? NSOnState : NSOffState;
        [self.streamInterpolationPopupButton selectItemAtIndex:selectedStream.streamInterpolationType];
        [self updateAnchorPointsCountLabel];
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(isSelectable))] == YES)
    {
        FLStream* stream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
        
        FLStreamView *view = object;
        self.streamsSelectabilityCheckBox.state = (view.isSelectable == YES) ? NSOnState : NSOffState;
        
        if(view.isSelectable == NO)
            stream.anchorPointsCollection.selectedAnchorPoint = nil;
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(isVisible))] == YES)
    {
        FLStream* stream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
        
        FLStreamView *view = object;
        self.streamsVisibilityCheckBox.state = (view.isVisible == YES) ? NSOnState : NSOffState;
        stream.anchorPointsCollection.selectedAnchorPoint = nil;
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamInterpolationType))] == YES)
    {
        FLStream* stream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
        [self.streamInterpolationPopupButton selectItemAtIndex:stream.streamInterpolationType];
    }
}

#pragma mark - UI callbacks

-(void)appendStream:(id)sender
{
    FLStreamsCollection *streams = self.utilityPaneController.appFrameController.model.streams;
    [streams appendStream];
}

-(void)removeSelectedStream:(id)sender
{
    [self.utilityPaneController.appFrameController.model.streams deleteSelectedStream];
}

- (IBAction)streamTypeChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    selectedStream.streamType = _streamTypePopupButton.indexOfSelectedItem;
    selectedStream.streamInterpolationType = (selectedStream.streamType == FLStreamTypeLookAt) ?
        FLStreamInterpolationTypeNone : FLStreamInterpolationTypeLinear;

    [self.streamInterpolationPopupButton setEnabled:(selectedStream.streamType == FLStreamTypePosition)];
}

- (IBAction)streamVisualAidChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    selectedStream.streamVisualType = _streamVisualPopupButton.indexOfSelectedItem;
}

- (IBAction)streamsVisibilityChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLStreamView *view = [self.utilityPaneController.appFrameController.sceneViewController viewForStream:selectedStream];
    view.isVisible = _streamsVisibilityCheckBox.state;
}

- (IBAction)streamsSelectabilityChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLStreamView *view = [self.utilityPaneController.appFrameController.sceneViewController viewForStream:selectedStream];
    view.isSelectable = _streamsSelectabilityCheckBox.state;
}

- (IBAction)streamColorChanged:(id)sender
{
    NSColor *selectedColor = _streamColorPicker.color;
    
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    selectedStream.streamVisualColor = selectedColor;
}

- (IBAction)streamInterpolationChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    selectedStream.streamInterpolationType = [_streamInterpolationPopupButton indexOfSelectedItem];
}

- (IBAction)startVisualization:(id)sender
{
    [self.utilityPaneController.appFrameController.sceneViewController startVisualization:_visualizationTime.doubleValue];
//    [_visualizationButton setEnabled:NO];
}

#pragma mark - stream ID Combobox datasource/delegate/value changed

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return self.utilityPaneController.appFrameController.model.streams.count + 1;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if(index == 0)
        return @"No Selection";
    
    FLStream *stream = [self.utilityPaneController.appFrameController.model.streams streamForId:index];
    return [NSNumber numberWithUnsignedInteger:stream.streamId];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    FLStreamsCollection *streams = self.utilityPaneController.appFrameController.model.streams;
    NSUInteger selectedIndex = self.streamIDComboBox.indexOfSelectedItem;
    streams.selectedStream = (selectedIndex == 0) ? nil : [streams streamForId:selectedIndex];
}

#pragma mark - Validation

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = menuItem.action;
    
    if(action == @selector(removeSelectedStream:))
    {
        return (self.utilityPaneController.appFrameController.model.streams.selectedStream != nil);
    }
    
    return YES;
}

#pragma mark - Private helpers

-(void)updateAnchorPointsCountLabel
{
    FLStream *stream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    self.anchorPointsCountLabel.stringValue = (stream == nil) ? @"No Selection" :
    [NSString stringWithFormat:@"%li",stream.anchorPointsCollection.anchorPoints.count ];
}

@end
