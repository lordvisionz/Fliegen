//
//  FLSceneViewController
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneViewController.h"

#import "FLAnchorPoint.h"
#import "FLSceneView.h"

#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>

@interface FLSceneViewController ()
{
    NSMenu *anchorPointsMenu;
}

-(FLSceneView*)sceneView;

@end

@implementation FLSceneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initialize];
        [self initMenuItems];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    [self initialize];
    [self initMenuItems];
    self = [super initWithCoder:aDecoder];

    return self;
}

-(void) initialize
{
    anchorPoints = [[NSMutableArray alloc]init];

}

-(void)setInitialCamera
{
    SCNNode *cameraNode = [self cameraNode];
    [cameraNode.camera setUsesOrthographicProjection:NO];
    cameraNode.position = SCNVector3Make(30, 15, 30);
//    cameraNode.transform = CATransform3DRotate(cameraNode.transform, -M_PI / 7.0, 1, 0, 0);
    
//    CATransform3D pivot  = cameraNode.transform;
//    SCNVector3 cameraPosition = cameraNode.position;
//    cameraPosition = SCNVector3Make(0, 0, 10);
//    SCNVector4 cameraRotation = cameraNode.rotation;
//    NSLog(@"initial camera position is (%f, %f, %f)", cameraPosition.x, cameraPosition.y, cameraPosition.z);
//    NSLog(@"camera rotation is (%f, %f, %f, %f)", cameraRotation.x, cameraRotation.y, cameraRotation.z, cameraRotation.w);
//    cameraPosition.z += 30;
//    [cameraNode setPosition:cameraPosition];
    
    [[self.sceneView.scene.rootNode childNodeWithName:@"pokeball" recursively:NO] removeFromParentNode];
    
    SCNBox *box = [SCNBox boxWithWidth:10 height:10 length:10 chamferRadius:0];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.position = SCNVector3Make(0, 0, 0);
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor redColor];
    box.firstMaterial = material;
    [self.sceneView.scene.rootNode addChildNode:boxNode];
    
    
    
//    [self.sceneView.scene.rootNode setTransform:CATransform3DMakeTranslation(0, 0, 0)];
//    [self.sceneView.scene.rootNode setRotation:SCNVector4Make(0, 0, 0, 0)];
}

-(void)awakeFromNib
{
    [self setNextResponder:self.view.nextResponder];
    [self.view setNextResponder:self];
    [self becomeFirstResponder];

    [self setInitialCamera];
}

-(void)initMenuItems
{
    anchorPointsMenu = [[NSMenu alloc]init];
    NSMenuItem *appendAnchorPoint = [[NSMenuItem alloc]initWithTitle:@"Append Anchor Point" action:@selector(pushAnchorPoint) keyEquivalent:@""];
    [appendAnchorPoint setTarget:self];
    
    [anchorPointsMenu addItem:appendAnchorPoint];
}

// 1) Find approximate position of click point
-(void)pushAnchorPoint
{
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]init];
    [anchorPoint setAnchorPointID:(anchorPoints.count + 1)];
    SCNVector3 lookAt = SCNVector3Make(0, 0, 0);
    [anchorPoint setLookAt:lookAt];
    
    SCNScene *scene = self.sceneView.scene;
    SCNNode *rootNode = scene.rootNode;
    
    for(id item in rootNode.childNodes)
    {
        NSLog(@"child node is %@", ((SCNNode*)item).camera);
    }
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
    NSLog(@"in view controller. super is %@", [super class]);
//    [self.view setMenu:anchorPointsMenu];
    [self.view.superview setMenu:anchorPointsMenu];
    [self.view.superview rightMouseDown:theEvent];
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(BOOL)becomeFirstResponder
{
    return YES;
}

-(FLSceneView*)sceneView
{
    return (FLSceneView*)(self.view);
}

-(SCNNode*)cameraNode
{
    NSArray *cameras = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        BOOL isCameraNode = (child.camera != nil);
        *stop = isCameraNode;
        return isCameraNode;
    }];
    SCNNode *cameraNode = [cameras objectAtIndex:0];
    return cameraNode;
}

@end
