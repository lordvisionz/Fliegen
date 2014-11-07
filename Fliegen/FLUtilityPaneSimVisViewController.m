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
#import "FLStreamsCollectionProtocol.h"

@interface FLUtilityPaneSimVisViewController ()

@end

@implementation FLUtilityPaneSimVisViewController

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    id<FLStreamsCollectionProtocol> streams = _utilityPaneController.appFrameController.model.streams;
    return [streams streamsWithStreamType:(aComboBox == _cameraPositionsComboBox) ? FLStreamTypePosition : FLStreamTypeLookAt].count;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    id<FLStreamsCollectionProtocol> streams = _utilityPaneController.appFrameController.model.streams;
    id<FLStreamProtocol> stream = [[streams streamsWithStreamType:(aComboBox == _cameraPositionsComboBox) ? FLStreamTypePosition : FLStreamTypeLookAt] objectAtIndex:index];
    return [NSNumber numberWithInteger:[stream streamId]];
}

-(void)viewDidAppear
{
    [_cameraLookAtComboBox reloadData];
    [_cameraPositionsComboBox reloadData];
    
    if(_cameraLookAtComboBox.numberOfItems > 0)
       [_cameraLookAtComboBox selectItemAtIndex:0];
    
    if(_cameraPositionsComboBox.numberOfItems > 0)
        [_cameraPositionsComboBox selectItemAtIndex:0];
}

@end
