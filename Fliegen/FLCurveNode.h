//
//  FLCurveNode.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/14/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@class FLStreamView;

@interface FLCurveNode : SCNNode

-(id)initWithStreamView:(FLStreamView*)streamView points:(NSArray*)points;

-(void)updateGeometry;

-(void)updateAnchorPointColor;

@end
