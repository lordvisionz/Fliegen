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

#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>
#import "FLSceneKitUtilities.h"

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

//    [[self.sceneView.scene.rootNode childNodeWithName:@"pokeball" recursively:NO] removeFromParentNode];
    
//    SCNBox *box = [SCNBox boxWithWidth:3 height:3 length:3 chamferRadius:0];
//    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
//    [boxNode setName:@"box"];
//    boxNode.position = SCNVector3Make(0, 0, 0);
//
//    SCNMaterial *material = [SCNMaterial material];
//    material.diffuse.contents = [NSColor redColor];
//    box.firstMaterial = material;
//    [self.sceneView.scene.rootNode addChildNode:boxNode];
}

-(void)awakeFromNib
{
    [self.view setNextResponder:self];
    [self.view.window makeFirstResponder:self];

    [self setInitialCamera];
}

-(void)setSceneReferenceObject:(FLSceneReferenceObject)referenceObject
{
    [[self.sceneView.scene.rootNode childNodeWithName:@"pokeball" recursively:NO] removeFromParentNode];
    [[self.sceneView.scene.rootNode childNodeWithName:@"box" recursively:NO] removeFromParentNode];
    
    if(referenceObject == FLSceneReferenceObjectBox)
    {
        SCNBox *box = [SCNBox boxWithWidth:3 height:3 length:3 chamferRadius:0];
        SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
        [boxNode setName:@"box"];
        boxNode.position = SCNVector3Make(0, 0, 0);
        
        SCNMaterial *material = [SCNMaterial material];
        material.diffuse.contents = [NSColor redColor];
        box.firstMaterial = material;
        [self.sceneView.scene.rootNode addChildNode:boxNode];
    }
    else if(referenceObject == FLSceneReferenceObjectPokeball)
    {
        
    }
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

    SCNVector4 rotateToLookAt = FLRotatePointAToFacePointB(localPoint, lookAt);
    
    SCNVector4 cameraRotation = self.sceneView.pointOfView.rotation;
    CATransform3D transform = CATransform3DMakeRotation(cameraRotation.w, cameraRotation.x, cameraRotation.y, cameraRotation.z);
    transform = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
    transform = CATransform3DRotate(transform, rotateToLookAt.w, rotateToLookAt.x, rotateToLookAt.y, rotateToLookAt.z);
    
    SCNVector3 position = SCNVector3Make(transform.m41, transform.m42, transform.m43);
    [anchorPoint setPosition:position];
    
    FLAnchorPointView *anchorPointView = [[FLAnchorPointView alloc] initWithAnchorPoint:anchorPoint withRootNode:self.sceneView.scene.rootNode
                                                                          withTransform:transform];
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
        
        NSUInteger hitIndex =[oldHitNoes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            SCNNode *node = [obj node];
            if([node.name isEqualToString:@"hitplane"] == YES)
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if(hitIndex == NSNotFound) return NO;
        
        SCNHitTestResult *hitPlane = [oldHitNoes objectAtIndex:hitIndex];
        
        SCNVector3 oldWorldCoord = hitPlane.worldCoordinates;
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
        SCNVector3 newWorldCoord = hitPlane.worldCoordinates;

        SCNVector3 oldPosition = anchorPointView.position;
        SCNVector3 lookAtPosition = anchorPointView.anchorPointModel.lookAt;
        
        if([_selectionHandleInDrag.name isEqualToString:@"zAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.x - oldWorldCoord.x;
            oldPosition.x += distanceDragged;
            anchorPointView.position = oldPosition;

            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, distanceDragged, 0, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"yAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.y - oldWorldCoord.y;
            oldPosition.y += distanceDragged;
            anchorPointView.position = oldPosition;
            
            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, distanceDragged, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"xAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.z - oldWorldCoord.z;
            oldPosition.z += distanceDragged;
            anchorPointView.position = oldPosition;
            
            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, 0, distanceDragged)];
        }
        
        lastClickedPoint = newMousePoint;

        return YES;
    }
    return NO;
}

- (double)distanceBetweenPoint:(SCNVector3)point1 point2:(SCNVector3)point2
{
    return sqrt(pow((point2.x - point1.x) , 2) + pow((point2.y - point1.y), 2) + pow((point2.z - point1.z), 2));
}

-(SCNVector3)normalisedDirectionBetween:(SCNVector3)point1 point2:(SCNVector3)point2
{
    SCNVector3 direction = SCNVector3Make(point2.x - point1.x, point2.y - point1.y, point2.z - point1.z);
    double magnitude = sqrt(pow(direction.x, 2) + pow(direction.y, 2) + pow(direction.z, 2));
    
    direction.x /= magnitude;
    direction.y /= magnitude;
    direction.z /= magnitude;
    
    return direction;
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
