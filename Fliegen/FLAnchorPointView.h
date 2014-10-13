//
//  FLAnchorPointView.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

#import "FLStream.h"
#import "FLAnchorPointProtocol.h"

@class FLAnchorPoint, FLSelectionHandles;

@interface FLAnchorPointView : SCNNode

-(id)initWithAnchorPoint:(id<FLAnchorPointProtocol>)anchorPoint;

@property(readonly, assign) id<FLAnchorPointProtocol> anchorPoint;

-(void)updateGeometry;

-(void)updateAnchorPointColor;

-(FLSelectionHandles*)getSelectionHandles;

@end
