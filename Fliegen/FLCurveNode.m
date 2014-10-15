//
//  FLCurveNode.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/14/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLCurveNode.h"
#import "FLAnchorPointProtocol.h"

#import "FLStreamView.h"

@interface FLCurveNode()
{
    FLStreamView *_streamView;
}
@end

@implementation FLCurveNode

-(id)initWithStreamView:(FLStreamView *)streamView points:(NSArray *)points
{
    self = [super init];
    _streamView = streamView;
    
    if(points.count < 2) return self;
    
    NSUInteger lineSegmentCount = points.count * 2 - 2;
    SCNVector3 lineSegments[lineSegmentCount];

    for(int i = 0, lineSegmentCounter = 0; i < points.count; i++)
    {
        SCNVector3 position = [[points objectAtIndex:i] SCNVector3Value];
        lineSegments[lineSegmentCounter++] = position;
        if(i == 0 || (i == points.count - 1)) continue;
        
        lineSegments[lineSegmentCounter++] = position;
    }
    
    SCNGeometrySource *curve = [SCNGeometrySource geometrySourceWithVertices:lineSegments count:lineSegmentCount];
    int indices[lineSegmentCount];
    for(int i = 0; i < lineSegmentCount; i++)
    {
        indices[i] = i;
    }
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(indices)];
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indexData primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:lineSegmentCount bytesPerIndex:sizeof(int)];
    SCNGeometry *lineStrip = [SCNGeometry geometryWithSources:@[curve] elements:@[element]];
    SCNMaterial *material = [SCNMaterial material];
    material.ambient.contents = material.diffuse.contents = material.specular.contents = material.emission.contents =
    _streamView.stream.streamVisualColor;
    
    lineStrip.firstMaterial = material;
    self.geometry = lineStrip;
    
    return self;
}

-(void)updateGeometry
{
    
}

-(void)updateAnchorPointColor
{
    SCNMaterial *material = [SCNMaterial material];
    material.ambient.contents = material.diffuse.contents = material.specular.contents = material.emission.contents =
    _streamView.stream.streamVisualColor;
    self.geometry.firstMaterial = material;
}

@end
