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

#import "FLModel.h"
#import "FLStream.h"
#import "FLStreamsCollection.h"

@implementation FLUtilityPaneStreamsViewController

#pragma mark - Init

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    FLStreamsCollection *streams = self.utilityPaneController.appFrameController.model.streams;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasAdded:) name:FLStreamAddedNotification object:streams];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasDeleted:) name:FLStreamDeletedNotification object:streams];
    [streams addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedStream)) options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - Notifications/KVO

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
        if(selectedStream == nil)
        {
            self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
            [self.streamIDComboBox selectItemAtIndex:0];
            
            return;
        }
        [self.streamIDComboBox reloadData];
        [self.streamIDComboBox selectItemAtIndex:selectedStream.streamId];
        [self.streamTypePopupButton selectItemAtIndex:selectedStream.streamType];
        [self.streamVisualPopupButton selectItemAtIndex:selectedStream.streamVisualType];
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
}

- (IBAction)streamVisualAidChanged:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    selectedStream.streamVisualType = _streamVisualPopupButton.indexOfSelectedItem;
}

#pragma mark - stream ID Combobox datasource/delegate/value changed

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [self.utilityPaneController.appFrameController.model.streams streamsCount] + 1;
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

@end
