//
//  FLAnchorPointView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPointView.h"

@implementation FLAnchorPointView

-(id)initWithAnchorPoint:(FLAnchorPoint *)model withTransform:(CATransform3D)modelTransform
{
    self = [super init];
    _anchorPointModel = model;
    
    SCNCone *cone = [SCNCone coneWithTopRadius:.1 bottomRadius:1 height:2.5];
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor blackColor];
    [cone setFirstMaterial:material];
    
    [self setGeometry:cone];
    [self setTransform:modelTransform];
    return self;
}

-(SCNNode*)setSelectionHandlesForRootNode:(SCNNode *)rootNode
{
    SCNCylinder *xAxisRod = [SCNCylinder cylinderWithRadius:.2 height:4];
    SCNNode *xAxisRodNode = [SCNNode nodeWithGeometry:xAxisRod];
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor greenColor];
    [xAxisRod setFirstMaterial:material];
    
//    CATransform3D xAxisTransform = self.worldTransform;
    
    
//    CATransform3D xAxisTransform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
//    CATransform3D xAxisTransform = CATransform3DRotate(self.worldTransform, M_PI_2, 1, 0, 0);
    
//    xAxisTransform = CATransform3DConcat(self.worldTransform, xAxisTransform);
    
//    xAxisTransform = CATransform3DTranslate(xAxisTransform, 4, 0, 0);
    
//    CATransform3D xAxisTransform = CATransform3DTranslate(xAxisTransform, 0, 0, 4);
//    xAxisTransform = CATransform3DRotate(xAxisTransform, M_PI_2, 1, 0, 0);
    
//    CATransform3D xAxisTransform = viewMatrix;
    
//    [xAxisRodNode setPosition:SCNVector3Make(4, 0, 0)];
//    [xAxisRodNode setRotation:SCNVector4Make(1, 0, 0, M_PI_2)];
    
    SCNVector3 xAxisOffset = SCNVector3Make(self.worldTransform.m41, self.worldTransform.m42, self.worldTransform.m43);
//    CATransform3D xAxisTransform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
//    xAxisTransform = CATransform3DTranslate(xAxisTransform, xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    CATransform3D xAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    xAxisTransform = CATransform3DRotate(xAxisTransform, M_PI_2, 1, 0, 0);
    xAxisTransform = CATransform3DTranslate(xAxisTransform, 0, 2, 1);
    [xAxisRodNode setTransform:xAxisTransform];
//    [self addChildNode:xAxisRodNode];
    
    SCNCone *xAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *xAxisConeNode = [SCNNode nodeWithGeometry:xAxisCone];
    [xAxisCone setFirstMaterial:material];
    [xAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [xAxisRodNode addChildNode:xAxisConeNode];
    
    
    
    return xAxisRodNode;
}

@end
