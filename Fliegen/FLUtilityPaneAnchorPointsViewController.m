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

#import "FLModel.h"
#import "FLAnchorPoint.h"

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

@end
