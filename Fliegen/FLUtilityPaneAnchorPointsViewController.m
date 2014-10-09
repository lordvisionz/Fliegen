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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointSelectionChanged:) name:FLAnchorPointSelectionChangedNotification
                                               object:nil];
}

#pragma mark - Notifications/KVO

-(void)anchorPointWasAdded:(NSNotification*)notification
{
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeAnchorPoint;
    self.utilityPaneController.utilityPaneSegmentedControl.selectedSegment = 2;
    [self.utilityPaneController switchUtilityPaneTab:nil];
}

-(void)anchorPointWasDeleted:(NSNotification*)notification
{
    self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
    [self.anchorIdComboBox reloadData];
}

-(void)anchorPointSelectionChanged:(NSNotification*)notification
{
    FLStream *currentStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLAnchorPoint *anchorPoint = currentStream.anchorPoints.selectedAnchorPoint;
    SCNVector3 position = anchorPoint.position;
    
    if(anchorPoint == nil)
    {
        self.utilityPaneController.appFrameController.sceneViewController.selectionMode = FLSelectionModeNone;
        [self.anchorIdComboBox selectItemAtIndex:0];
        return;
    }
    [self.anchorIdComboBox reloadData];
    [self.anchorIdComboBox selectItemAtIndex:anchorPoint.anchorPointID];
    _xPositionTextField.doubleValue = position.x;
    _yPositionTextField.doubleValue = position.y;
    _zPositionTextField.doubleValue = position.z;
    
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if([keyPath isEqualToString:@"selectedAnchorPoint"] == YES)
//    {
//        FLAnchorPoint *previousSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeOldKey];
//        FLAnchorPoint *newSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeNewKey];
//        
//        if([newSelectedAnchorPoint isKindOfClass:[NSNull class]] == YES)
//            [self toggleEnableInputElements:NO];
//        else
//        {
//            [self toggleEnableInputElements:YES];
//            self.anchorIdComboBox.integerValue = newSelectedAnchorPoint.anchorPointID;
//            
//            if([previousSelectedAnchorPoint isKindOfClass:[NSNull class]] == NO)
//            {
//                [previousSelectedAnchorPoint removeObserver:self forKeyPath:@"position"];
//            }
//            
//            [newSelectedAnchorPoint addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:NULL];
//            
//            _xPositionTextField.doubleValue = newSelectedAnchorPoint.position.x;
//            _yPositionTextField.doubleValue = newSelectedAnchorPoint.position.y;
//            _zPositionTextField.doubleValue = newSelectedAnchorPoint.position.z;
//        }
//    }
//    else if([keyPath isEqualToString:@"position"] == YES)
//    {
//        FLAnchorPoint *anchorPoint = object;
//        _xPositionTextField.doubleValue = anchorPoint.position.x;
//        _yPositionTextField.doubleValue = anchorPoint.position.y;
//        _zPositionTextField.doubleValue = anchorPoint.position.z;
//    }
//}

#pragma mark - UI actions/callbacks

- (void)appendAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc] init];
    anchorPoint.position = SCNVector3Make(0, 0, 0);
    [selectedStream.anchorPoints appendAnchorPoint:anchorPoint];
}

- (void)removeSelectedAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    [selectedStream.anchorPoints deleteSelectedAnchorPoint];
}

#pragma mark - NSTextField/combobox value changed

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    FLSceneView *sceneView = self.utilityPaneController.appFrameController.sceneViewController.sceneView;
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints;
    if(commandSelector == @selector(insertNewline:))
    {
        if(control == _anchorIdComboBox)
        {
            NSUInteger anchorPointID = _anchorIdComboBox.integerValue;
            FLAnchorPoint *point = [anchorPointsCollection anchorPointForId:anchorPointID];
            if(point == nil)
                point = [anchorPointsCollection anchorPointForId:anchorPointsCollection.anchorPointsCount];
            
            anchorPointsCollection.selectedAnchorPoint = point;
            
            return YES;
        }
        
        FLAnchorPoint *anchorPoint = anchorPointsCollection.selectedAnchorPoint;
        SCNVector3 oldPosition = anchorPoint.position;
        SCNNode *selectionHandles = [sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
        CATransform3D selectionHandlesTransform = selectionHandles.transform;
        
        FLAnchorPointView *anchorPointView = [self anchorPointViewForModel:anchorPoint];
        if(control == _xPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(_xPositionTextField.doubleValue, anchorPoint.position.y, anchorPoint.position.z);
            anchorPointView.position = anchorPoint.position;
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, anchorPoint.position.x - oldPosition.x, 0, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _yPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPositionTextField.doubleValue, anchorPoint.position.z);
            anchorPointView.position = anchorPoint.position;
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, anchorPoint.position.y - oldPosition.y, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _zPositionTextField)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPositionTextField.doubleValue);
            anchorPointView.position = anchorPoint.position;
            
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
    FLAnchorPoint *anchorPoint = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints.selectedAnchorPoint;
    FLAnchorPointView *anchorPointView = [self anchorPointViewForModel:anchorPoint];
    
    SCNVector3 oldPosition = anchorPoint.position;
    SCNNode *selectionHandles = [sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
    CATransform3D selectionHandlesTransform = selectionHandles.transform;
    
    NSStepper *stepper = (NSStepper *)sender;
    if(sender == _xPositionStepper)
    {
        anchorPoint.position = SCNVector3Make([stepper doubleValue], anchorPoint.position.y, anchorPoint.position.z);
        anchorPointView.position = anchorPoint.position;
        
        selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, anchorPoint.position.x - oldPosition.x, 0, 0);
        [selectionHandles setTransform:selectionHandlesTransform];
    }
    else if(sender == _yPositionStepper)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPositionStepper.doubleValue, anchorPoint.position.z);
        anchorPointView.position = anchorPoint.position;
        
        selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, anchorPoint.position.y - oldPosition.y, 0);
        [selectionHandles setTransform:selectionHandlesTransform];
    }
    else if(sender == _zPositionStepper)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPositionStepper.doubleValue);
        anchorPointView.position = anchorPoint.position;
        
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
        FLAnchorPointsCollection *anchorPointsCollection = streamCollection.selectedStream.anchorPoints;
        return (anchorPointsCollection.selectedAnchorPoint != nil);
    }
    return YES;
}

#pragma mark - Utility Methods

-(FLAnchorPointView*)anchorPointViewForModel:(FLAnchorPoint *)anchorPoint
{
    FLSceneView *sceneView = self.utilityPaneController.appFrameController.sceneViewController.sceneView;
    __block FLAnchorPointView *anchorPointView;
    [sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop)
     {
         if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
         anchorPointView = (FLAnchorPointView*) child;
         
         if(anchorPointView.anchorPointModel == anchorPoint)
         {
             *stop = YES;
             return YES;
         }
         return NO;
     }];
    return anchorPointView;
}

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
    return [selectedStream.anchorPoints anchorPointsCount] + 1;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if(index == 0)
        return @"No Selection";
    
    FLStream *selectedStream = self.utilityPaneController.appFrameController.model.streams.selectedStream;
    FLAnchorPoint *anchorPoint = [selectedStream.anchorPoints anchorPointForId:index];
    return [NSNumber numberWithUnsignedInteger:anchorPoint.anchorPointID];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints;

    NSUInteger index = [_anchorIdComboBox indexOfSelectedItem];
    anchorPointsCollection.selectedAnchorPoint = (index == 0) ? nil : [anchorPointsCollection anchorPointForId:index];
    [self toggleAnchorPointEditControls:(index > 0)];
}



@end
