//
//  FLAppFrameController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAppFrameController.h"
#import "FLModel.h"
#import "FLConstants.h"

#import "FLSceneView.h"
#import "FLSceneViewController.h"
#import "FLUtilityPaneController.h"
#import "FLSimulationVisualizationTimeController.h"

@implementation FLAppFrameController

-(id)init
{
    self = [super init];
    _model = [[FLModel alloc] init];
    
    return self;
}

-(void)awakeFromNib
{
    [_sceneEditorToolbarItem.toolbar setSelectedItemIdentifier:_sceneEditorToolbarItem.itemIdentifier];
    [_editorPlaceholderView setSubviews:@[_sceneViewController.view]];
}

- (IBAction)toggleUtilitiesPanel:(id)sender
{
    NSToolbarItem *item = sender;

    if([item.label isEqualToString:@"Show Properties"])
    {
        [item setLabel:@"Hide Properties"];
        [_splitView setPosition:(_splitView.window.frame.size.width - FL_PROPERTIES_TAB_WIDTH)  ofDividerAtIndex:0];
    }
    else
    {
        [item setLabel:@"Show Properties"];
        [_splitView setPosition:_splitView.window.frame.size.width ofDividerAtIndex:0];
    }
}

- (IBAction)toggleEditor:(id)sender
{
    if(sender == _sceneEditorToolbarItem)
    {
        [_editorPlaceholderView setSubviews:@[_sceneViewController.view]];
    }
    else
    {
        [_editorPlaceholderView setSubviews:@[_simVisTimeViewController.view]];
    }
}

#pragma mark - Toolbar delegate

-(NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return @[_sceneEditorToolbarItem.itemIdentifier, _simulationEditorToolbarItem.itemIdentifier];
}

#pragma mark - Split View delegate

-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return subview != _editorPlaceholderView;
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float windowWidth = splitView.window.frame.size.width;
    return windowWidth - (FL_PROPERTIES_TAB_WIDTH + 1);
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float windowWidth = splitView.window.frame.size.width;
    return windowWidth - (FL_PROPERTIES_TAB_WIDTH + 1);
}

-(BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    return view == _editorPlaceholderView;
}

-(void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [_propertiesToolbarItem setLabel:([_splitView isSubviewCollapsed:_utilityPanelController.view] == YES) ? @"Show Properties" : @"Hide Properties" ];
}

@end
