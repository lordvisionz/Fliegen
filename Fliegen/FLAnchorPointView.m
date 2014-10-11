//
//  FLAnchorPointView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLAnchorPointView.h"

#import "FLAnchorPoint.h"
#import "FLSelectionHandles.h"

@implementation FLAnchorPointView

-(id)initWithAnchorPoint:(id<FLAnchorPointProtocol>)anchorPoint
{
    self = [super init];
    _anchorPoint = anchorPoint;
    [self updateGeometry];
    return self;
}

//-(id)initWithAnchorPoint:(FLAnchorPoint *)model withRootNode:(SCNNode*)rootNode withTransform:(CATransform3D)modelTransform
//{
//    self = [super init];
//    _anchorPointModel = model;
//    _rootNode = rootNode;
//    
//    SCNCone *cone = [SCNCone coneWithTopRadius:.1 bottomRadius:1 height:2.5];
//    SCNMaterial *material = [SCNMaterial material];
//    material.diffuse.contents = [NSColor blackColor];
//    [cone setFirstMaterial:material];
//    
//    [self setGeometry:cone];
//    [self setTransform:modelTransform];
//    return self;
//}

-(void)updateGeometry
{
    FLStreamVisualType visualType = self.anchorPoint.stream.streamVisualType;
    SCNMaterial *material = [SCNMaterial material];
    [material setLightingModelName:SCNLightingModelBlinn];
    material.diffuse.contents = [NSColor redColor];
    
    switch(visualType)
    {
        case FLStreamVisualTypeCone:
        {
            SCNCone *cone = [SCNCone coneWithTopRadius:.1 bottomRadius:1 height:2.5];
            cone.firstMaterial = material;
            
            self.geometry = cone;
            self.position = self.anchorPoint.position;
            break;
        }
        case FLStreamVisualTypeSphere:
        {
            SCNSphere *sphere = [SCNSphere sphereWithRadius:1];
            sphere.firstMaterial = material;
            self.geometry = sphere;
            
            self.position = self.anchorPoint.position;
            break;
        }
    }
}


-(void)dealloc
{

}

-(FLSelectionHandles*) getSelectionHandles
{
    FLSelectionHandles *selectionNode = [FLSelectionHandles node];
    [selectionNode setName:@"selectionHandles"];
    SCNCylinder *xAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *xAxisRodNode = [SCNNode nodeWithGeometry:xAxisRod];
    xAxisRodNode.name = @"xAxisTranslate";
    SCNMaterial *xAxisMaterial = [SCNMaterial material];
    xAxisMaterial.diffuse.contents = [NSColor redColor];
    [xAxisRod setFirstMaterial:xAxisMaterial];
    
    
    SCNVector3 xAxisOffset = SCNVector3Make(self.worldTransform.m41, self.worldTransform.m42, self.worldTransform.m43);
    CATransform3D xAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    xAxisTransform = CATransform3DRotate(xAxisTransform, -M_PI_2, 0, 0, 1);
    xAxisTransform = CATransform3DTranslate(xAxisTransform, 0, 2, 0);
    [xAxisRodNode setTransform:xAxisTransform];
    
    SCNCone *xAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *xAxisConeNode = [SCNNode nodeWithGeometry:xAxisCone];
    xAxisConeNode.name = @"xAxisTranslate";
    [xAxisCone setFirstMaterial:xAxisMaterial];
    [xAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [xAxisRodNode addChildNode:xAxisConeNode];
    
    [selectionNode addChildNode:xAxisRodNode];
    
    SCNCylinder *yAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *yAxisRodNode = [SCNNode nodeWithGeometry:yAxisRod];
    yAxisRodNode.name = @"yAxisTranslate";
    SCNMaterial *yAxisMaterial = [SCNMaterial material];
    yAxisMaterial.diffuse.contents = [NSColor greenColor];
    [yAxisRod setFirstMaterial:yAxisMaterial];
    
    CATransform3D yAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    yAxisTransform = CATransform3DRotate(yAxisTransform, M_PI_2, 0, 1, 0);
    yAxisTransform = CATransform3DTranslate(yAxisTransform, 0, 2, 0);
    [yAxisRodNode setTransform:yAxisTransform];
    
    SCNCone *yAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *yAxisConeNode = [SCNNode nodeWithGeometry:yAxisCone];
    yAxisConeNode.name = @"yAxisTranslate";
    [yAxisCone setFirstMaterial:yAxisMaterial];
    [yAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [yAxisRodNode addChildNode:yAxisConeNode];
    [selectionNode addChildNode:yAxisRodNode];
    
    SCNCylinder *zAxisRod = [SCNCylinder cylinderWithRadius:.1 height:4];
    SCNNode *zAxisRodNode = [SCNNode nodeWithGeometry:zAxisRod];
    zAxisRodNode.name = @"zAxisTranslate";
    SCNMaterial *zAxisMaterial = [SCNMaterial material];
    zAxisMaterial.diffuse.contents = [NSColor blueColor];
    [zAxisRod setFirstMaterial:zAxisMaterial];
    
    CATransform3D zAxisTransform = CATransform3DMakeTranslation(xAxisOffset.x, xAxisOffset.y, xAxisOffset.z);
    zAxisTransform = CATransform3DRotate(zAxisTransform, M_PI_2, 1, 0, 0);
    zAxisTransform = CATransform3DTranslate(zAxisTransform, 0, 2, 0);
    [zAxisRodNode setTransform:zAxisTransform];
    
    SCNCone *zAxisCone = [SCNCone coneWithTopRadius:0 bottomRadius:.5 height:2];
    SCNNode *zAxisConeNode = [SCNNode nodeWithGeometry:zAxisCone];
    zAxisConeNode.name = @"zAxisTranslate";
    [zAxisCone setFirstMaterial:zAxisMaterial];
    [zAxisConeNode setPosition:SCNVector3Make(0, 2, 0)];
    [zAxisRodNode addChildNode:zAxisConeNode];
    
    [selectionNode addChildNode:zAxisRodNode];
    return selectionNode;
}

//- (BOOL)removeSelectionHandles
//{
//    SCNNode *selectionNode = [_rootNode childNodeWithName:@"selectionHandles" recursively:YES];
//    
//    if(selectionNode == nil) return NO;
//    [selectionNode removeFromParentNode];
//    return YES;
//}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    FLAnchorPoint *oldSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeOldKey];
//    FLAnchorPoint *newSelectedAnchorPoint = [change objectForKey:NSKeyValueChangeNewKey];
//
//    if(([newSelectedAnchorPoint isKindOfClass:[NSNull class]] == NO) && newSelectedAnchorPoint.anchorPointID == _anchorPointModel.anchorPointID)
//        [self setSelectionHandles];
//    if(([oldSelectedAnchorPoint isKindOfClass:[NSNull class]] == NO) && oldSelectedAnchorPoint.anchorPointID == _anchorPointModel.anchorPointID)
//        [self removeSelectionHandles];
//}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(position))] == YES)
    {
        FLAnchorPoint *anchorPoint = object;
        self.position = anchorPoint.position;
    }
}

@end
