//
//  FLSceneViewController
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneViewController.h"
#import "FLAppFrameController.h"

#import "FLModel.h"
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
    _isDraggingSelectionHandles = NO;
}

-(void)setInitialCamera
{
    SCNNode *cameraNode = [self cameraNode];
    [cameraNode.camera setUsesOrthographicProjection:NO];

    cameraNode.position = SCNVector3Make(0, 0, 100);
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);

    [[self.sceneView.scene.rootNode childNodeWithName:@"pokeball" recursively:NO] removeFromParentNode];
    
    SCNBox *box = [SCNBox boxWithWidth:3 height:3 length:3 chamferRadius:0];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    [boxNode setName:@"box"];
    boxNode.position = SCNVector3Make(0, 0, 0);

    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor redColor];
    box.firstMaterial = material;
    [self.sceneView.scene.rootNode addChildNode:boxNode];
}

-(void)awakeFromNib
{
    [self.view setNextResponder:self];
    [self.view.window makeFirstResponder:self];

    [self setInitialCamera];
}

-(void)initMenuItems
{
    anchorPointsMenu = [[NSMenu alloc]init];
    NSMenuItem *appendAnchorPoint = [[NSMenuItem alloc]initWithTitle:@"Append Anchor Point" action:@selector(pushAnchorPoint:) keyEquivalent:@""];
    [appendAnchorPoint setTarget:self];
    
    NSMenuItem *deleteAnchorPoint = [[NSMenuItem alloc] initWithTitle:@"Delete Anchor Point" action:@selector(deleteAnchorPoint:) keyEquivalent:@""];
    [deleteAnchorPoint setTarget:self];

    [anchorPointsMenu addItem:appendAnchorPoint];
    [anchorPointsMenu addItem:deleteAnchorPoint];
}

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
    if([menuItem action] == @selector(deleteAnchorPoint:))
    {
        return (anchorPointsCollection.selectedAnchorPoint != nil);
    }
    return YES;
}

-(void)deleteAnchorPoint:(id)sender
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
    NSArray *anchorPoints = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
        
        FLAnchorPointView *anchorPointView = (FLAnchorPointView*)child;
        return (anchorPointView.anchorPointModel.anchorPointID == anchorPointsCollection.selectedAnchorPoint.anchorPointID);
    }];
    
    [anchorPointsCollection deleteSelectedAnchorPoint];

    SCNNode *deletedNode = [anchorPoints objectAtIndex:0];
    [deletedNode removeFromParentNode];
    
    [anchorPointsCollection removeObserver:deletedNode forKeyPath:@"selectedAnchorPoint"];
    deletedNode = nil;
}

-(void)pushAnchorPoint:(id)sender
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
    
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]init];
    SCNVector3 lookAt = SCNVector3Make(0, 0, 0);
    [anchorPoint setLookAt:lookAt];

    NSArray *result = [self.sceneView hitTest:lastClickedPoint options:nil];
    SCNHitTestResult *hitResult = [result objectAtIndex:0];
    SCNVector3 localPoint = hitResult.localCoordinates;

    CATransform3D modelViewMatrix = self.sceneView.pointOfView.transform;
    CATransform3D projectionMatrix = [self cameraNode].camera.projectionTransform;
    
    SCNVector4 rotation = self.sceneView.pointOfView.rotation;

    CATransform3D transform = CATransform3DMakeRotation( rotation.w, rotation.x, rotation.y, rotation.z);
        CATransform3D translate = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
    
    SCNVector3 position = SCNVector3Make(translate.m41, translate.m42, translate.m43);
    [anchorPoint setPosition:position];
    
    GLKVector4 objectPoint = GLKVector4Make(position.x, position.y, position.z, 1);
    GLKVector4 eyeCoord = GLKMatrix4MultiplyVector4(GLKMatrix4FromCATransform3D(modelViewMatrix), objectPoint);
    GLKVector4 ndcCoord = GLKMatrix4MultiplyVector4(GLKMatrix4FromCATransform3D(projectionMatrix), eyeCoord);
    ndcCoord = GLKVector4Normalize(ndcCoord);
    
    FLAnchorPointView *anchorPointView = [[FLAnchorPointView alloc] initWithAnchorPoint:anchorPoint withRootNode:self.sceneView.scene.rootNode
                                                                          withTransform:translate];
    [anchorPointsCollection appendAnchorPoint:anchorPoint];
    [anchorPointsCollection addObserver:anchorPointView forKeyPath:@"selectedAnchorPoint"
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    anchorPointsCollection.selectedAnchorPoint = anchorPoint;
    [self.sceneView.scene.rootNode addChildNode:anchorPointView];
}


-(void)mouseDown:(NSEvent *)theEvent
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
    
    lastClickedPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    NSArray *hitItems = [self.sceneView hitTest:lastClickedPoint options:nil];
    
    if(hitItems.count == 0)
    {
        anchorPointsCollection.selectedAnchorPoint = nil;
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
        anchorPointsCollection.selectedAnchorPoint = nil;
        return;
    }
    FLAnchorPointView *anchorPoint = (FLAnchorPointView*)firstHitItem.node;
    [anchorPointsCollection setSelectedAnchorPoint:anchorPoint.anchorPointModel];
}

-(BOOL)mouseDragged:(NSEvent *)theEvent
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
    
    NSPoint newMousePoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    if(_isDraggingSelectionHandles)
    {
        FLAnchorPoint *selectedAnchorPoint = anchorPointsCollection.selectedAnchorPoint;
        NSArray *childNodes = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop)
        {
            if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
            FLAnchorPointView *anchorPointView = (FLAnchorPointView*) child;
            
            if(anchorPointView.anchorPointModel == selectedAnchorPoint)
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
//        NSLog(@"dX is %f, dY is %f",newHitPointInPlane.x - oldHitPointInPlane.x, newHitPointInPlane.y - oldHitPointInPlane.y);

        if([_selectionHandleInDrag.name isEqualToString:@"zAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, newHitPointInPlane.x - oldHitPointInPlane.x, 0, 0);
            [anchorPointView setTransform:localTransform];
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, newHitPointInPlane.x - oldHitPointInPlane.x, 0, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"yAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, 0, newHitPointInPlane.y - oldHitPointInPlane.y, 0);
            [anchorPointView setTransform:localTransform];
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, newHitPointInPlane.y - oldHitPointInPlane.y, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"xAxisTranslate"])
        {
            CATransform3D localTransform = anchorPointView.transform;
            localTransform = CATransform3DTranslate(localTransform, 0, 0, oldHitPointInPlane.x - newHitPointInPlane.x);
            [anchorPointView setTransform:localTransform];
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, 0, oldHitPointInPlane.x - newHitPointInPlane.x)];
        }
        
        lastClickedPoint = newMousePoint;

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

    SCNVector4 rotation = self.sceneView.pointOfView.rotation;
    
    SCNPlane *plane = [SCNPlane planeWithWidth:100000 height:100000];
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
