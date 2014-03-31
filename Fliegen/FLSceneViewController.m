//
//  FLSceneViewController
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneViewController.h"

#import "FLAnchorPoint.h"
#import "FLAnchorPointsCollection.h"
#import "FLAnchorPointView.h"

#import "FLSceneView.h"

#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>

#import "GLKit/GLKMath.h"

@interface FLSceneViewController ()
{
    NSMenu *anchorPointsMenu;
    
    NSPoint lastClickedPoint;
    
    BOOL _isDraggingSelectionHandles;
    
    SCNNode *_selectionHandleInDrag;
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
    anchorPointsCollection = [[FLAnchorPointsCollection alloc] init];
    _isDraggingSelectionHandles = NO;
}

-(void)setInitialCamera
{
    SCNNode *cameraNode = [self cameraNode];
    [cameraNode.camera setUsesOrthographicProjection:NO];
//    [cameraNode.camera setProjectionTransform:GLKMatrix4ToCATransform3D( GLKMatrix4Make(2, 0, 0, 0, 0, 2, 0, 0, 0, 0, -1.22, -2.22, 0, 0, -1, 0))];
    cameraNode.position = SCNVector3Make(0, 0, 100);
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);
    
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
    
    SCNBox *box = [SCNBox boxWithWidth:3 height:3 length:3 chamferRadius:0];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    [boxNode setName:@"box"];
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
//    [self setNextResponder:self.view];
    [self.view setNextResponder:self];
    [self.view.window makeFirstResponder:self];

    [self setInitialCamera];
}

-(void)initMenuItems
{
    anchorPointsMenu = [[NSMenu alloc]init];
    NSMenuItem *appendAnchorPoint = [[NSMenuItem alloc]initWithTitle:@"Append Anchor Point" action:@selector(pushAnchorPoint) keyEquivalent:@""];
    [appendAnchorPoint setTarget:self];

    [anchorPointsMenu addItem:appendAnchorPoint];
}

-(void)pushAnchorPoint
{
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]init];
    SCNVector3 lookAt = SCNVector3Make(0, 0, 0);
    [anchorPoint setLookAt:lookAt];
    
    SCNScene *scene = self.sceneView.scene;
//    SCNNode *rootNode = scene.rootNode;
    
//    SCNSphere *sphere = [SCNSphere sphereWithRadius:1];
//    SCNMaterial *material = [SCNMaterial material];
//    material.diffuse.contents = [NSColor blackColor];
//    [sphere setFirstMaterial:material];

    
    NSArray *result = [self.sceneView hitTest:lastClickedPoint options:nil];
    SCNHitTestResult *hitResult = [result objectAtIndex:0];
    SCNVector3 localPoint = hitResult.localCoordinates;
//    SCNVector3 worldPoint = hitResult.worldCoordinates;
//    SCNVector3 localNormal = hitResult.localNormal;
//    SCNVector3 worldNormal = hitResult.worldNormal;
    
    SCNVector4 rotation = self.sceneView.pointOfView.rotation;
    
//    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
//    [sphereNode setRotation:rotation];

    CATransform3D transform = CATransform3DMakeRotation( rotation.w, rotation.x, rotation.y, rotation.z);
        CATransform3D translate = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
//    [sphereNode setTransform:translate];
//    [self.sceneView.scene.rootNode addChildNode:sphereNode];
    
    SCNVector3 position = SCNVector3Make(translate.m41, translate.m42, translate.m43);
    [anchorPoint setPosition:position];
    
    FLAnchorPointView *anchorPointView = [[FLAnchorPointView alloc] initWithAnchorPoint:anchorPoint withRootNode:self.sceneView.scene.rootNode
                                                                          withTransform:translate];
    [anchorPointsCollection appendAnchorPoint:anchorPoint];
    [anchorPointsCollection addObserver:anchorPointView forKeyPath:@"selectedAnchorPointID"
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    anchorPointsCollection.selectedAnchorPointID = anchorPoint.anchorPointID;
    [self.sceneView.scene.rootNode addChildNode:anchorPointView];
    
}

// 1) Find approximate position of click point
//-(void)pushAnchorPoint
//{
//    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]init];
//    [anchorPoint setAnchorPointID:(anchorPoints.count + 1)];
//    SCNVector3 lookAt = SCNVector3Make(0, 0, 0);
//    [anchorPoint setLookAt:lookAt];
//    
//    SCNScene *scene = self.sceneView.scene;
//    SCNNode *rootNode = scene.rootNode;
//    
//    SCNSphere *sphere = [SCNSphere sphereWithRadius:2];
//    SCNMaterial *material = [SCNMaterial material];
//    material.diffuse.contents = [NSColor blackColor];
//    [sphere setFirstMaterial:material];
//    
//    for(SCNNode *node in self.sceneView.scene.rootNode.childNodes)
//    {
//        CATransform3D transform = node.transform;
//        CATransform3D world = node.worldTransform;
//    }
//
////    [sphereNode set]
//    SCNNode *pointOfView = self.sceneView.pointOfView;
//    CATransform3D viewMatrix = self.sceneView.pointOfView.transform;
////    CATransform3D viewMatrix = [self cameraNode].transform;
//    CATransform3D projectionMatrix = [self cameraNode].camera.projectionTransform;
//    
//
//    
//    CATransform3D viewProjectionMatrix = CATransform3DConcat(viewMatrix, projectionMatrix);
//    
//    int viewPort[] = {0, 0, 1, 1};
//    GLKVector3 transformedPoint = GLKMathProject(GLKVector3Make(0, 0, 0), GLKMatrix4FromCATransform3D(viewMatrix),
//                                                 GLKMatrix4FromCATransform3D(projectionMatrix), viewPort);
//    transformedPoint.x = lastClickedPoint.x / self.view.frame.size.width;
//    transformedPoint.y = lastClickedPoint.y / self.view.frame.size.height;
//    transformedPoint.z = 0;
//    bool success;
//    GLKVector3 objectPoint = GLKMathUnproject(transformedPoint, GLKMatrix4FromCATransform3D(viewMatrix), GLKMatrix4FromCATransform3D(projectionMatrix),
//                                              viewPort, &success);
//    
//    NSLog(@"clicked coordinates is (%f, %f)", objectPoint.x, objectPoint.y);
//    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
//    [sphereNode setPosition:SCNVector3Make(objectPoint.x, objectPoint.y, 0)];
//    [[self.sceneView.scene.rootNode childNodeWithName:@"box" recursively:YES] addChildNode:sphereNode];
////    CATransform3D worldTransform = CATransform3DInvert([self cameraNode].worldTransform);
////    CATransform3D inverseProjection = CATransform3DInvert([self cameraNode].camera.projectionTransform);
////    
////    SCNVector3 clicked3DPoint = SCNVector3Make(lastClickedPoint.x/self.view.frame.size.width, lastClickedPoint.y/self.view.frame.size.height, 1);
////    CATransform3D clicked3DMatrix = CATransform3DMakeTranslation(clicked3DPoint.x, clicked3DPoint.y, clicked3DPoint.z);
////    
////    clicked3DMatrix = CATransform3DConcat(clicked3DMatrix, worldTransform);
////    CATransform3D concatMatrix = CATransform3DConcat(clicked3DMatrix, inverseProjection);
////    NSPoint point = NSMakePoint(transformedPoint.x, <#CGFloat y#>)
//    NSLog(@"Sdfsd");
//}

-(void)mouseDown:(NSEvent *)theEvent
{
    lastClickedPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSArray *hitItems = [self.sceneView hitTest:lastClickedPoint options:nil];
    
    if(hitItems.count == 0)
    {
        anchorPointsCollection.selectedAnchorPointID = NSNotFound;
        return;
    }
    SCNHitTestResult *firstHitItem = [hitItems objectAtIndex:0];
    SCNNode *selectionNode = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
    if(selectionNode != nil)
    {
        if([selectionNode childNodeWithName:firstHitItem.node.name recursively:YES] != nil)
        {
            _isDraggingSelectionHandles = YES;
            _selectionHandleInDrag = firstHitItem.node;
            SCNVector4 rotation = self.sceneView.pointOfView.rotation;
            
            SCNPlane *plane = [SCNPlane planeWithWidth:10000 height:10000];
            SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
            [planeNode setName:@"hitplane"];
            
            [planeNode setRotation:rotation];
            SCNMaterial *material = [SCNMaterial material];
            material.diffuse.contents = [NSColor clearColor];
            [plane setFirstMaterial:material];
            [self.sceneView.scene.rootNode addChildNode:planeNode];
            return;
        }
    }
    if([firstHitItem.node isKindOfClass:[FLAnchorPointView class]] == NO)
    {
        anchorPointsCollection.selectedAnchorPointID = NSNotFound;
        return;
    }
    FLAnchorPointView *anchorPoint = (FLAnchorPointView*)firstHitItem.node;
    
//    SCNNode * handlesNode =[anchorPoint setSelectionHandlesForRootNode:self.sceneView.scene.rootNode];
    [anchorPointsCollection setSelectedAnchorPointID:anchorPoint.anchorPointModel.anchorPointID];

//    [self.sceneView.scene.rootNode addChildNode:handlesNode];
    
//    [self.view.superview mouseDown:theEvent];
}

-(BOOL)mouseDragged:(NSEvent *)theEvent
{
    NSPoint newMousePoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(_isDraggingSelectionHandles)
    {
        NSUInteger selectedAnchorPoint = anchorPointsCollection.selectedAnchorPointID;
        NSArray *childNodes = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop)
        {
            if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
            FLAnchorPointView *anchorPointView = (FLAnchorPointView*) child;
            
            if(anchorPointView.anchorPointModel.anchorPointID == selectedAnchorPoint)
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if(childNodes.count == 0) return NO;
        FLAnchorPointView *anchorPointView = [childNodes objectAtIndex:0];
        
        NSArray *oldHitNoes = [self.sceneView hitTest:lastClickedPoint options:nil];
        NSArray *newHitNodes = [self.sceneView hitTest:newMousePoint options:nil];
        SCNHitTestResult *hitPlane = [oldHitNoes objectAtIndex:[oldHitNoes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            SCNNode *node = [obj node];
            if([node.name isEqualToString:@"hitplane"] == YES)
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }]];
        SCNVector3 oldHitPointInPlane = hitPlane.localCoordinates;
        hitPlane = [newHitNodes objectAtIndex:[newHitNodes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
         {
             SCNNode *node = [obj node];
             if([node.name isEqualToString:@"hitplane"] == YES)
             {
                 *stop = YES;
                 return YES;
             }
             return NO;
         }]];
        SCNVector3 newHitPointInPlane = hitPlane.localCoordinates;
        NSLog(@"dX is %f, dY is %f",newHitPointInPlane.x - oldHitPointInPlane.x, newHitPointInPlane.y - oldHitPointInPlane.y);
        
//        SCNHitTestResult *hitSelectionHandle = [oldHitNoes objectAtIndex:[oldHitNoes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
//        {
//            SCNNode *node = [obj node];
//            if([node.name isEqualToString:@"xAxisTranslate"] || [node.name isEqualToString:@"yAxisTranslate"] ||
//               [node.name isEqualToString:@"zAxisTranslate"] )
//            {
//                *stop = YES;
//                return YES;
//            }
//            return NO;
//        }]];
        
        if([_selectionHandleInDrag.name isEqualToString:@"zAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, newHitPointInPlane.x - oldHitPointInPlane.x, 0, 0);
            [anchorPointView setTransform:localTransform];
            
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, newHitPointInPlane.x - oldHitPointInPlane.x, 0, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"yAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, 0, newHitPointInPlane.y - oldHitPointInPlane.y, 0);
            [anchorPointView setTransform:localTransform];
            
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, newHitPointInPlane.y - oldHitPointInPlane.y, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"xAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, 0, 0, oldHitPointInPlane.x - newHitPointInPlane.x);
            [anchorPointView setTransform:localTransform];
            
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, 0, oldHitPointInPlane.x - newHitPointInPlane.x)];
        }
        
        lastClickedPoint = newMousePoint;

//        SCNVector4 rotation = self.sceneView.pointOfView.rotation;
        
//        CATransform3D transform = CATransform3DMakeTranslation(<#CGFloat tx#>, <#CGFloat ty#>, <#CGFloat tz#>)
        
//        CATransform3D transform = CATransform3DMakeRotation( rotation.w, rotation.x, rotation.y, rotation.z);
//        CATransform3D translate = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
        //    [sphereNode setTransform:translate];
        //    [self.sceneView.scene.rootNode addChildNode:sphereNode];
        
//        SCNVector3 position = SCNVector3Make(translate.m41, translate.m42, translate.m43);
//        [anchorPoint setPosition:position];

        return YES;
    }
    return NO;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    [[self.sceneView.scene.rootNode childNodeWithName:@"hitplane" recursively:YES] removeFromParentNode];
    _selectionHandleInDrag = nil;
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
    lastClickedPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];

    CATransform3D viewMatrix = self.sceneView.pointOfView.transform;
    SCNVector4 rotation = self.sceneView.pointOfView.rotation;
    
    SCNPlane *plane = [SCNPlane planeWithWidth:10000 height:10000];
    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
    [planeNode setName:@"hitplane"];
    
    [planeNode setRotation:rotation];
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor clearColor];
    [plane setFirstMaterial:material];
    [self.sceneView.scene.rootNode addChildNode:planeNode];
    
    [anchorPointsMenu setDelegate:self];
    
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

-(void)menuDidClose:(NSMenu *)menu
{
    [[self.sceneView.scene.rootNode childNodeWithName:@"hitplane" recursively:YES] removeFromParentNode];
}

@end
