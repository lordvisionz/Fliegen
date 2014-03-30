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
    SCNNode *selectionNode = [SCNNode node];
    [selectionNode setName:@"selectionHandles"];
    SCNCylinder *xAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *xAxisRodNode = [SCNNode nodeWithGeometry:xAxisRod];
    SCNMaterial *xAxisMaterial = [SCNMaterial material];
    xAxisMaterial.diffuse.contents = [NSColor greenColor];
    [xAxisRod setFirstMaterial:xAxisMaterial];
    
    
    SCNVector3 xAxisOffset = SCNVector3Make(self.worldTransform.m41, self.worldTransform.m42, self.worldTransform.m43);
//    CATransform3D xAxisTransform = CATransform3DMakeRotation(M_PI_2, 1, 0, 0);
//    xAxisTransform = CATransform3DTranslate(xAxisTransform, xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    CATransform3D xAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    xAxisTransform = CATransform3DRotate(xAxisTransform, M_PI_2, 1, 0, 0);
    xAxisTransform = CATransform3DTranslate(xAxisTransform, 0, 2, 0);
    [xAxisRodNode setTransform:xAxisTransform];
//    [self addChildNode:xAxisRodNode];
    
    SCNCone *xAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *xAxisConeNode = [SCNNode nodeWithGeometry:xAxisCone];
    [xAxisCone setFirstMaterial:xAxisMaterial];
    [xAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [xAxisRodNode addChildNode:xAxisConeNode];
    
    [selectionNode addChildNode:xAxisRodNode];
    
    SCNCylinder *yAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *yAxisRodNode = [SCNNode nodeWithGeometry:yAxisRod];
    SCNMaterial *yAxisMaterial = [SCNMaterial material];
    yAxisMaterial.diffuse.contents = [NSColor blueColor];
    [yAxisRod setFirstMaterial:yAxisMaterial];
    
    CATransform3D yAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    yAxisTransform = CATransform3DRotate(yAxisTransform, M_PI_2, 0, 1, 0);
    yAxisTransform = CATransform3DTranslate(yAxisTransform, 0, 2, 0);
    [yAxisRodNode setTransform:yAxisTransform];
    
    SCNCone *yAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *yAxisConeNode = [SCNNode nodeWithGeometry:yAxisCone];
    [yAxisCone setFirstMaterial:yAxisMaterial];
    [yAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [yAxisRodNode addChildNode:yAxisConeNode];
    [selectionNode addChildNode:yAxisRodNode];
    
    SCNCylinder *zAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *zAxisRodNode = [SCNNode nodeWithGeometry:zAxisRod];
    SCNMaterial *zAxisMaterial = [SCNMaterial material];
    zAxisMaterial.diffuse.contents = [NSColor redColor];
    [zAxisRod setFirstMaterial:zAxisMaterial];
    
    CATransform3D zAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    zAxisTransform = CATransform3DRotate(zAxisTransform, M_PI_2, 0, 0, 1);
    zAxisTransform = CATransform3DTranslate(zAxisTransform, 0, 2, 0);
    [zAxisRodNode setTransform:zAxisTransform];
    
    SCNCone *zAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *zAxisConeNode = [SCNNode nodeWithGeometry:zAxisCone];
    [zAxisCone setFirstMaterial:zAxisMaterial];
    [zAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [zAxisRodNode addChildNode:zAxisConeNode];
    
    [selectionNode addChildNode:zAxisRodNode];
    return selectionNode;
}

@end
