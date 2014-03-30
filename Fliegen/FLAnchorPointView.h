//
//  FLAnchorPointView.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

#import "FLAnchorPoint.h"

@interface FLAnchorPointView : SCNNode
{
//    FLAnchorPoint *_model;
}

@property (readonly) FLAnchorPoint* anchorPointModel;

- (id) initWithAnchorPoint:(FLAnchorPoint*)model withTransform:(CATransform3D)modelTransform;

- (SCNNode*)setSelectionHandlesForRootNode:(SCNNode*)rootNode;

@end
