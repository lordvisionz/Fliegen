//
//  FLAppFrameController.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAppFrameController.h"
#import "FLModel.h"

#import "FLSceneView.h"

@implementation FLAppFrameController

-(id)init
{
    self = [super init];
    _model = [[FLModel alloc] init];
    
    return self;
}

- (IBAction)toggleUtilitiesPanel:(id)sender
{
    
}

-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return ([subview isKindOfClass:[FLSceneView class]] == NO);
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float windowWidth = splitView.window.frame.size.width;
    return windowWidth - 301;
}

-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float windowWidth = splitView.window.frame.size.width;
    return windowWidth - 301;
}

-(BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    return ([view isKindOfClass:[FLSceneView class]] == YES);
}

@end
