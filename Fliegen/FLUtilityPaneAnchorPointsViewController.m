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
    _xPositionTextField.doubleValue = _yPositionTextField.doubleValue = _zPositionTextField.doubleValue = 0;
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints;
    
    [anchorPointsCollection addObserver:self forKeyPath:@"selectedAnchorPoint" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                context:NULL];
    [self toggleEnableInputElements:NO];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"selectedAnchorPoint"] == YES)
    {
        FLAnchorPoint *previousSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeOldKey];
        FLAnchorPoint *newSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeNewKey];
        
        if([newSelectedAnchorPoint isKindOfClass:[NSNull class]] == YES)
            [self toggleEnableInputElements:NO];
        else
        {
            [self toggleEnableInputElements:YES];
            self.anchorIdComboBox.integerValue = newSelectedAnchorPoint.anchorPointID;

            if([previousSelectedAnchorPoint isKindOfClass:[NSNull class]] == NO)
            {
                [previousSelectedAnchorPoint removeObserver:self forKeyPath:@"position"];
            }
            
            [newSelectedAnchorPoint addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:NULL];
            
            _xPositionTextField.doubleValue = newSelectedAnchorPoint.position.x;
            _yPositionTextField.doubleValue = newSelectedAnchorPoint.position.y;
            _zPositionTextField.doubleValue = newSelectedAnchorPoint.position.z;
        }
    }
    else if([keyPath isEqualToString:@"position"] == YES)
    {
        FLAnchorPoint *anchorPoint = object;
        _xPositionTextField.doubleValue = anchorPoint.position.x;
        _yPositionTextField.doubleValue = anchorPoint.position.y;
        _zPositionTextField.doubleValue = anchorPoint.position.z;
    }
}

-(void)toggleEnableInputElements:(BOOL)visible
{
    [_anchorIdComboBox setEnabled:visible];
    
    [_xPositionTextField setEnabled:visible];
    [_yPositionTextField setEnabled:visible];
    [_zPositionTextField setEnabled:visible];
    
    [_xPositionStepper setEnabled:visible];
    [_yPositionStepper setEnabled:visible];
    [_zPositionStepper setEnabled:visible];
}

#pragma mark - XIB actions

- (void)appendAnchorPoint:(id)sender
{
    
}

- (void)removeSelectedAnchorPoint:(id)sender
{
    
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

#pragma mark - Combobox datasource/delegate

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints anchorPointsCount];
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    FLAnchorPoint *anchorPoint = [self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints anchorPointForIndex:index];
    return [NSNumber numberWithUnsignedInteger:anchorPoint.anchorPointID];
}

-(void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.streams.selectedStream.anchorPoints;

    NSUInteger index = [_anchorIdComboBox indexOfSelectedItem];
    FLAnchorPoint *anchorPoint = [anchorPointsCollection anchorPointForIndex:index];
    
    if(anchorPoint == nil)
    {
        anchorPoint = [anchorPointsCollection anchorPointForId:anchorPointsCollection.anchorPointsCount];
    }
    anchorPointsCollection.selectedAnchorPoint = anchorPoint;
}



@end
