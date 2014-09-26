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
#import "FLAnchorPointView.h"

@interface FLUtilityPaneAnchorPointsViewController ()

@end

@implementation FLUtilityPaneAnchorPointsViewController

-(void)awakeFromNib
{
    [self toggleEnableInputElements:NO];
    _xPosition.doubleValue = _yPosition.doubleValue = _zPosition.doubleValue = 0;
    _xLookAt.doubleValue = _yLookAt.doubleValue = _zLookAt.doubleValue = 0;
    _anchorId.integerValue = 0;
    
    FLAnchorPointsCollection *anchorPointsCollection = self.utilityPaneController.appFrameController.model.anchorPointsCollection;
    
    [anchorPointsCollection addObserver:self forKeyPath:@"selectedAnchorPoint" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                context:NULL];
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
            self.anchorId.integerValue = newSelectedAnchorPoint.anchorPointID;

            if([previousSelectedAnchorPoint isKindOfClass:[NSNull class]] == NO)
            {
                [previousSelectedAnchorPoint removeObserver:self forKeyPath:@"position"];
                [previousSelectedAnchorPoint removeObserver:self forKeyPath:@"lookAt"];
            }
            
            [newSelectedAnchorPoint addObserver:self forKeyPath:@"position" options:NSKeyValueObservingOptionNew context:NULL];
            [newSelectedAnchorPoint addObserver:self forKeyPath:@"lookAt" options:NSKeyValueObservingOptionNew context:NULL];
            
            _xPosition.doubleValue = newSelectedAnchorPoint.position.x;
            _yPosition.doubleValue = newSelectedAnchorPoint.position.y;
            _zPosition.doubleValue = newSelectedAnchorPoint.position.z;
            
            _xLookAt.doubleValue = newSelectedAnchorPoint.lookAt.x;
            _yLookAt.doubleValue = newSelectedAnchorPoint.lookAt.y;
            _zLookAt.doubleValue = newSelectedAnchorPoint.lookAt.z;
        }
    }
    else if([keyPath isEqualToString:@"position"] == YES)
    {
        FLAnchorPoint *anchorPoint = object;
        _xPosition.doubleValue = anchorPoint.position.x;
        _yPosition.doubleValue = anchorPoint.position.y;
        _zPosition.doubleValue = anchorPoint.position.z;
    }
    else if([keyPath isEqualToString:@"lookAt"] == YES)
    {
        FLAnchorPoint *anchorPoint = object;
        _xLookAt.doubleValue = anchorPoint.lookAt.x;
        _yLookAt.doubleValue = anchorPoint.lookAt.y;
        _zLookAt.doubleValue = anchorPoint.lookAt.z;
    }
}

-(void)toggleEnableInputElements:(BOOL)visible
{
    for(NSView *view in self.view.subviews)
    {
        [view setHidden:!visible];
    }
}

-(BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    FLSceneView *sceneView = self.utilityPaneController.appFrameController.sceneViewController.sceneView;
    if(commandSelector == @selector(insertNewline:))
    {
        FLAnchorPoint *anchorPoint = self.utilityPaneController.appFrameController.model.anchorPointsCollection.selectedAnchorPoint;
        SCNVector3 oldPosition = anchorPoint.position;
        SCNNode *selectionHandles = [sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
        CATransform3D selectionHandlesTransform = selectionHandles.transform;
        
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
        if(control == _xPosition)
        {
            anchorPoint.position = SCNVector3Make(_xPosition.doubleValue, anchorPoint.position.y, anchorPoint.position.z);
            anchorPointView.position = anchorPoint.position;
            
            SCNVector3 lookAtPosition = SCNVector3Make(0, 0, 0);
            anchorPointView.rotation = FLRotatePointAToFacePointB(anchorPoint.position, lookAtPosition);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, anchorPoint.position.x - oldPosition.x, 0, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _yPosition)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPosition.doubleValue, anchorPoint.position.z);
            SCNVector3 lookAtPosition = SCNVector3Make(0, 0, 0);
            
            anchorPointView.position = anchorPoint.position;
            anchorPointView.rotation = FLRotatePointAToFacePointB(anchorPoint.position, lookAtPosition);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, anchorPoint.position.y - oldPosition.y, 0);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _zPosition)
        {
            anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPosition.doubleValue);
            SCNVector3 lookAtPosition = SCNVector3Make(0, 0, 0);
            
            anchorPointView.position = anchorPoint.position;
            anchorPointView.rotation = FLRotatePointAToFacePointB(anchorPoint.position, lookAtPosition);
            
            selectionHandlesTransform = CATransform3DTranslate(selectionHandlesTransform, 0, 0, anchorPoint.position.z - oldPosition.z);
            [selectionHandles setTransform:selectionHandlesTransform];
        }
        else if(control == _xLookAt)
        {
            
        }
        else if(control == _yLookAt)
        {
            
        }
        else if(control == _zLookAt)
        {
            
        }
        return YES;
    }
    return NO;
}

-(void)textDidEndEditing:(NSNotification *)notification
{
    FLAnchorPoint *anchorPoint = self.utilityPaneController.appFrameController.model.anchorPointsCollection.selectedAnchorPoint;
    if(notification.object == _xPosition)
    {
        anchorPoint.position = SCNVector3Make(_xPosition.doubleValue, anchorPoint.position.y, anchorPoint.position.z);
    }
    else if(notification.object == _yPosition)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, _yPosition.doubleValue, anchorPoint.position.z);
    }
    else if(notification.object == _zPosition)
    {
        anchorPoint.position = SCNVector3Make(anchorPoint.position.x, anchorPoint.position.y, _zPosition.doubleValue);
    }
    else if(notification.object == _xLookAt)
    {
        
    }
    else if(notification.object == _yLookAt)
    {
        
    }
    else if(notification.object == _zLookAt)
    {
        
    }
}

@end
