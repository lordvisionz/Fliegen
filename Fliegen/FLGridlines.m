//
//  FLGridlines.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLGridlines.h"
#import "FLConstants.h"

@implementation FLGridlines

-(id)init
{
    self = [super init];
    self.name = @"gridlines";
    double gridlinesWidth = FL_GRIDLINES_WIDTH;
    
    SCNVector3 horizontalLines[] = {
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth),
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth * 0.8), SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth * 0.8),
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth * 0.6), SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth * 0.6),
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth * 0.4), SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth * 0.4),
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth * 0.2), SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth * 0.2),
        SCNVector3Make(-gridlinesWidth, 0, 0), SCNVector3Make(gridlinesWidth, 0, 0),
        SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth * 0.2), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth * 0.2),
        SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth * 0.4), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth * 0.4),
        SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth * 0.6), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth * 0.6),
        SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth * 0.8), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth * 0.8),
        SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth),
    };
    SCNVector3 verticalLines[] = {
        SCNVector3Make(-gridlinesWidth, 0, -gridlinesWidth), SCNVector3Make(-gridlinesWidth, 0, gridlinesWidth),
        SCNVector3Make(-gridlinesWidth * 0.8, 0, -gridlinesWidth), SCNVector3Make(-gridlinesWidth * 0.8, 0, gridlinesWidth),
        SCNVector3Make(-gridlinesWidth * 0.6, 0, -gridlinesWidth), SCNVector3Make(-gridlinesWidth * 0.6, 0, gridlinesWidth),
        SCNVector3Make(-gridlinesWidth * 0.4, 0, -gridlinesWidth), SCNVector3Make(-gridlinesWidth * 0.4, 0, gridlinesWidth),
        SCNVector3Make(-gridlinesWidth * 0.2, 0, -gridlinesWidth), SCNVector3Make(-gridlinesWidth * 0.2, 0, gridlinesWidth),
        SCNVector3Make(0, 0, -gridlinesWidth), SCNVector3Make(0, 0, gridlinesWidth),
        SCNVector3Make(gridlinesWidth * 0.2, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth * 0.2, 0, gridlinesWidth),
        SCNVector3Make(gridlinesWidth * 0.4, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth * 0.4, 0, gridlinesWidth),
        SCNVector3Make(gridlinesWidth * 0.6, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth * 0.6, 0, gridlinesWidth),
        SCNVector3Make(gridlinesWidth * 0.8, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth * 0.8, 0, gridlinesWidth),
        SCNVector3Make(gridlinesWidth, 0, -gridlinesWidth), SCNVector3Make(gridlinesWidth, 0, gridlinesWidth),
    };
    int indices [] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19, 20, 21};
    SCNGeometrySource *horizontalVertexSource = [SCNGeometrySource geometrySourceWithVertices:horizontalLines count:22];
    SCNGeometrySource *verticalVertexSource = [SCNGeometrySource geometrySourceWithVertices:verticalLines count:22];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:11 bytesPerIndex:sizeof(int)];
    SCNGeometry *horizontalLinesGeometry = [SCNGeometry geometryWithSources:@[horizontalVertexSource] elements:@[element]];
    SCNGeometry *verticalLinesGeometry = [SCNGeometry geometryWithSources:@[verticalVertexSource] elements:@[element]];
    SCNNode *horizontalLinesNode = [SCNNode nodeWithGeometry:horizontalLinesGeometry];
    SCNNode *verticalLinesNode = [SCNNode nodeWithGeometry:verticalLinesGeometry];
    
    [self addChildNode:horizontalLinesNode];
    [self addChildNode:verticalLinesNode];
    return self;
}

@end
