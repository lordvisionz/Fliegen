//
//  FLUtilityPaneAnchorPointsViewController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLUtilityPaneAnchorPointsViewController.h"
#import "FLAnchorPointsCollection.h"
#import "FLUtilityPaneController.h"
#import "FLAppFrameController.h"
#import "FLSceneViewController.h"
#import "FLSceneViewController_FLPrivateHelpers.h"

#import <GLKit/GLKMath.h>
#import "FLModel.h"
#import "FLAnchorPoint.h"
#import "FLSceneKitUtilities.h"

#import "FLSceneView.h"
#import "FLStream.h"
#import "FLStreamsCollection.h"
#import "FLAnchorPointView.h"

@interface FLUtilityPaneAnchorPointsViewController ()

@end

@implementation FLUtilityPaneAnchorPointsViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointWasAdded:) name:FLAnchorPointAddedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointWasDeleted:) name:FLAnchorPointDeletedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointSelectionChanged:)
                                                 name:FLAnchorPointSelectionChangedNotification object:nil];
    
    [self anchorPointSelectionChanged:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications/KVO

-(void)anchorPointWasAdded:(NSNotification*)notification
{
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeAnchorPoint;
    self.utilityPaneController.utilityPaneSegmentedControl.selectedSegment = 1;
    [self.utilityPaneController switchUtilityPaneTab:nil];
    
    FLStream *currentStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLAnchorPoint *anchorPoint = currentStream.anchorPointsCollection.selectedAnchorPoint;
    
    [anchorPoint addObserver:self forKeyPath:NSStringFromSelector(@selector(position))
                     options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
}

-(void)anchorPointWasDeleted:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    FLAnchorPoint *deletedAnchorPoint = [userInfo objectForKey:NSStringFromClass([FLAnchorPoint class])];

    [deletedAnchorPoint removeObserver:self forKeyPath:NSStringFromSelector(@selector(position))];
    
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
    [self.anchorIdComboBox reloadData];
}

-(void)anchorPointSelectionChanged:(NSNotification*)notification
{
    FLStream *currentStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLAnchorPoint *anchorPoint = currentStream.anchorPointsCollection.selectedAnchorPoint;
    
    if(anchorPoint == nil)
    {
        self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
        [self.anchorIdComboBox selectItemAtIndex:0];
        return;
    }
    [self.anchorIdComboBox reloadData];
    [self.anchorIdComboBox selectItemAtIndex:anchorPoint.anchorPointID];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(position))] == YES)
    {
        FLAnchorPoint *anchorPoint = object;
        _xPositionTextField.doubleValue = anchorPoint.position.x;
        _yPositionTextField.doubleValue = anchorPoint.position.y;
        _zPositionTextField.doubleValue = anchorPoint.position.z;
    }
}

#pragma mark - UI actions/callbacks

- (void)appendAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc] initWithStream:selectedStream];
    anchorPoint.position = SCNVector3Make(0, 0, 0);
    [selectedStream.anchorPointsCollection appendAnchorPoint:anchorPoint];
}

- (void)removeSelectedAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    [selectedStream.anchorPointsCollection deleteSelectedAnchorPoint];
}

#pragma mark - NSTextField/combobox value changed

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    FLSceneView *sceneView = self.utilityPaneController.appFrameController.sceneViewController.sceneView;
    FLAnchorPointsCollection *anchorPointsCollection =
    self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPointsCollection;
    
    if(commandSelector == @selector(insertNewline:))
    {
        if(control == _anchorIdComboBox)
        {
            NSUInteger anchorPointID = _anchorIdComboBox.integerValue;
            FLAnchorPoint *point = [anchorPointsCollection anchorPointForId:anchorPointID];
            if(point == nil)
                point = [anchorPointsCollection anchorPointForId:anchorPointsCollection.anchorPoints.count];
            
            anchorPointsCollection.selectedAnchorPoint = point;
            
            return YES;
        }
        
        FLAnchorPoint *anchorPoint = anchorPointsCollection.selectedAnchorPoint;
        SCNVector3 oldPosition = anchorPoint.position;
        SCNNode *selectionHandles = [sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
        CATransform3D selectionHandlesTransform = selectionHandles.transform;
        
        if(control == _xPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(_xPositionTextField.doubleValue, anchorPoint.position.y, anchorPoint.position.z);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, anchorPoint.position.x - oldPosition.x, 0, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _yPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPositionTextField.doubleValue, anchorPoint.position.z);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, anchorPoint.position.y - oldPosition.y, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _zPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPositionTextField.doubleValue);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, 0, anchorPoint.position.z - oldPosition.z);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        return YES;
    }
    return NO;
}

- (IBAction)stepValue:(id)sender
{
    FLSceneView *sceneView = self.utilityPaneController.appFrameController.sceneViewController.sceneView;
    FLAnchorPoint *anchorPoint = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPointsCollection.selectedAnchorPoint;
    
    SCNVector3 oldPosition = anchorPoint.position;
    SCNNode *selectionHandles = [sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
    CATransform3D selectionHandlesTransform = selectionHandles.transform;
    
    NSStepper *stepper = (NSStepper *)sender;
    if(sender == _xPositionStepper)
    {
        anchorPoint.position = SCNVector3Make([stepper doubleValue], anchorPoint.position.y, anchorPoint.position.z);
        
        selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, anchorPoint.position.x - oldPosition.x, 0, 0);
        [selectionHandles setTransform:selectionHandlesTransform];
    }
    else if(sender == _yPositionStepper)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPositionStepper.doubleValue, anchorPoint.position.z);
        
        selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, anchorPoint.position.y - oldPosition.y, 0);
        [selectionHandles setTransform:selectionHandlesTransform];
    }
    else if(sender == _zPositionStepper)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPositionStepper.doubleValue);
        
        selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, 0, anchorPoint.position.z - oldPosition.z);
        [selectionHandles setTransform:selectionHandlesTransform];
    }
}

#pragma mark - Validation

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    FLStreamsCollection *streamCollection = self.utilityPaneController.appFrameController.model.streams;
    
    if([menuItem action] == @selector(removeSelectedAnchorPoint:))
    {
        FLAnchorPointsCollection *anchorPointsCollection = streamCollection.selectedStream.anchorPointsCollection;
        return (anchorPointsCollection.selectedAnchorPoint != nil);
    }
    return YES;
}

#pragma mark - Utility Methods

-(void)toggleAnchorPointEditControls:(BOOL)visible
{
    [_xPositionStepper setEnabled:visible];
    [_xPositionTextField setEnabled:visible];
    [_yPositionStepper setEnabled:visible];
    [_yPositionTextField setEnabled:visible];
    [_zPositionStepper setEnabled:visible];
    [_zPositionTextField setEnabled:visible];
    
    [_deleteSelectedAnchorPointButton setEnabled:visible];
}

#pragma mark - Combobox datasource/delegate

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    return selectedStream.anchorPointsCollection.anchorPoints.count + 1;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if(index == 0)
        return @"No Selection";
    
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLAnchorPoint *anchorPoint = [selectedStream.anchorPointsCollection anchorPointForId:index];
    return [NSNumber numberWithUnsignedInteger:anchorPoint.anchorPointID];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPointsCollection;

    NSUInteger index = [_anchorIdComboBox indexOfSelectedItem];
    anchorPointsCollection.selectedAnchorPoint = (index == 0) ? nil : [anchorPointsCollection anchorPointForId:index];
    [self toggleAnchorPointEditControls:(index > 0)];
}
@end
