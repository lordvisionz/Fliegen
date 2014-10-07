//
//  FLAxisNode.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/5/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAxisNode.h"
#import "FLConstants.h"
#import <SceneKit/SceneKit.h>

@interface FLAxisNode()
{
    SCNNode *_rootNode;
}

@end

@implementation FLAxisNode

-(id)init
{
    self = [super init];
    
    double axisWidth = FL_VIEWPORT_AXES_LENGTH;
    [self setName:@"defaultAxes"];
 
    SCNVector3 xPositions[] = {SCNVector3Make(0.0, 0.0, 0.0), SCNVector3Make(axisWidth, 0.0, 0.0)};
    SCNVector3 yPositions[] = {SCNVector3Make(0, 0, 0), SCNVector3Make(0, axisWidth, 0)};
    SCNVector3 zPositions[] = {SCNVector3Make(0, 0, 0), SCNVector3Make(0, 0, axisWidth)};
    int indices[] = {0, 1};
    
    SCNGeometrySource *xVertexSource = [SCNGeometrySource geometrySourceWithVertices:xPositions count:2];
    SCNGeometrySource *yVertexSource = [SCNGeometrySource geometrySourceWithVertices:yPositions count:2];
    SCNGeometrySource *zVertexSource = [SCNGeometrySource geometrySourceWithVertices:zPositions count:2];
    
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine
                                                                primitiveCount:1 bytesPerIndex:sizeof(int)];
    SCNGeometry *xAxis = [SCNGeometry geometryWithSources:@[xVertexSource] elements:@[element]];
    SCNGeometry *yAxis = [SCNGeometry geometryWithSources:@[yVertexSource] elements:@[element]];
    SCNGeometry *zAxis = [SCNGeometry geometryWithSources:@[zVertexSource] elements:@[element]];
    SCNMaterial *redMaterial = [SCNMaterial material];
    SCNMaterial *greenMaterial = [SCNMaterial material];
    SCNMaterial *blueMaterial = [SCNMaterial material];
    redMaterial.ambient.contents = redMaterial.diffuse.contents = redMaterial.specular.contents = redMaterial.emission.contents = [NSColor redColor];
    greenMaterial.ambient.contents = greenMaterial.diffuse.contents = greenMaterial.specular.contents = greenMaterial.emission.contents =
    [NSColor greenColor];
    blueMaterial.ambient.contents = blueMaterial.diffuse.contents = blueMaterial.specular.contents = blueMaterial.emission.contents =
    [NSColor blueColor];
    xAxis.firstMaterial = redMaterial;
    yAxis.firstMaterial = greenMaterial;
    zAxis.firstMaterial = blueMaterial;
    xAxis.firstMaterial.doubleSided = yAxis.firstMaterial.doubleSided = zAxis.firstMaterial.doubleSided = YES;
    
    SCNNode *xAxisNode = [SCNNode nodeWithGeometry:xAxis];
    SCNNode *yAxisNode = [SCNNode nodeWithGeometry:yAxis];
    SCNNode *zAxisNode = [SCNNode nodeWithGeometry:zAxis];
    
    [self addChildNode:xAxisNode];
    [self addChildNode:yAxisNode];
    [self addChildNode:zAxisNode];
    
//    [self addChildNode:axes];
    return self;
}

@end
