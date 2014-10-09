//
//  FLSceneViewController
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/2/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneViewController.h"
#import "FLAppFrameController.h"
#import "FLUtilityPaneController.h"
#import "FLUtilityPaneAnchorPointsViewController.h"
#import "FLUtilityPaneStreamsViewController.h"

#import "FLModel.h"
#import "FLStreamsCollection.h"
#import "FLStream.h"
#import "FLAnchorPoint.h"
#import "FLAnchorPointsCollection.h"
#import "FLAnchorPointView.h"

#import "FLSceneView.h"
#import <SceneKit/SceneKit.h>
#import "FLAxisNode.h"
#import "FLGridlines.h"

#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>
#import "FLSceneKitUtilities.h"

@interface FLSceneViewController ()
{
    NSMenu *anchorPointsMenu;
    NSMenu *streamsMenu;
    
    NSPoint lastClickedPoint;
    
    BOOL _isDraggingSelectionHandles;
    
    SCNNode *_selectionHandleInDrag;
    
    FLAxisNode *_viewPortAxes;
    FLGridlines *_gridlines;
}

@end

@implementation FLSceneViewController

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _isDraggingSelectionHandles = NO;
        _selectionMode = FLSelectionModeNone;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _isDraggingSelectionHandles = NO;
    _selectionMode = FLSelectionModeNone;
    
    return self;
}

-(void)setInitialCamera
{
    self.sceneView.scene = [SCNScene scene];
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [cameraNode.camera setUsesOrthographicProjection:NO];
    cameraNode.camera.zFar = 1000;
    
    CATransform3D cameraTransform = CATransform3DMakeRotation(M_PI_4/4, 0, 1, 0);
    cameraTransform = CATransform3DTranslate(cameraTransform, 0, 10, 75);
    cameraNode.transform = cameraTransform;
    [self.sceneView.scene.rootNode addChildNode:cameraNode];
    
    SCNVector4 rotation = self.sceneView.pointOfView.rotation;
    
    SCNPlane *plane = [SCNPlane planeWithWidth:FLT_MAX height:FLT_MAX];
    SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
    [planeNode setName:@"hitplane"];
    
    [planeNode setRotation:rotation];
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [NSColor clearColor];
    [plane setFirstMaterial:material];
    [self.sceneView.scene.rootNode addChildNode:planeNode];
    
    [self.sceneView addObserver:self forKeyPath:@"pointOfView.transform" options:NSKeyValueObservingOptionNew context:NULL];
    
    _viewPortAxes = [[FLAxisNode alloc]init];
    _gridlines = [[FLGridlines alloc] init];
    [self.sceneView.scene.rootNode addChildNode:_gridlines];
}

-(void)awakeFromNib
{
    [self.view setNextResponder:self];
    [self.view.window makeFirstResponder:self];

    [super awakeFromNib];
    [self initMenuItems];
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
    
    streamsMenu = [[NSMenu alloc] init];
    NSMenuItem *appendStream = [[NSMenuItem alloc]initWithTitle:@"Add new Stream" action:@selector(appendStream:) keyEquivalent:@""];
    [appendStream setTarget:self.appFrameController.utilityPanelController.streamsPropertiesController];
    
    NSMenuItem *deleteStream = [[NSMenuItem alloc] initWithTitle:@"Delete Stream" action:@selector(removeSelectedStream:) keyEquivalent:@""];
    [deleteStream setTarget:self.appFrameController.utilityPanelController.streamsPropertiesController];
    
    [streamsMenu addItem:appendStream];
    [streamsMenu addItem:deleteStream];
}

#pragma mark - Validation/KVO/KVC

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"pointOfView.transform"] == YES)
    {
        SCNVector4 rotation = self.sceneView.pointOfView.rotation;
        [self hitPlane].rotation = rotation;
    }
}

#pragma mark - View/UI features

-(void)showViewportAxes:(BOOL)visible
{
    if(visible && _viewPortAxes.parentNode == nil)
        [self.sceneView.scene.rootNode addChildNode:_viewPortAxes];
    else if(visible == NO)
        [_viewPortAxes removeFromParentNode];
}

-(void)showGridlines:(BOOL)visible
{
    if(visible && _gridlines.parentNode == nil)
        [self.sceneView.scene.rootNode addChildNode:_gridlines];
    else if(visible == NO)
        [_gridlines removeFromParentNode];
}

#pragma mark - Anchor Points add/delete

-(void)deleteAnchorPoint:(id)sender
{
//    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.anchorPointsCollection;
//    NSArray *anchorPoints = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
//        if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
//        
//        FLAnchorPointView *anchorPointView = (FLAnchorPointView*)child;
//        return (anchorPointView.anchorPointModel.anchorPointID == anchorPointsCollection.selectedAnchorPoint.anchorPointID);
//    }];
//    
//    [anchorPointsCollection deleteSelectedAnchorPoint];
//
//    SCNNode *deletedNode = [anchorPoints objectAtIndex:0];
//    [deletedNode removeFromParentNode];
//    
//    [anchorPointsCollection removeObserver:deletedNode forKeyPath:@"selectedAnchorPoint"];
//    deletedNode = nil;
}

-(void)pushAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.appFrameController.model.streams.selectedStream;
    FLAnchorPointsCollection *anchorPointsCollection = selectedStream.anchorPoints;
    
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]init];

    NSArray *result = [self.sceneView hitTest:lastClickedPoint options:nil];
    SCNHitTestResult *hitResult = [result objectAtIndex:0];
    
    SCNVector3 localPoint = hitResult.localCoordinates;
    SCNVector4 cameraRotation = self.sceneView.pointOfView.rotation;
    CATransform3D transform = CATransform3DMakeRotation(cameraRotation.w, cameraRotation.x, cameraRotation.y, cameraRotation.z);
    transform = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
    
    SCNVector3 position = SCNVector3Make(transform.m41, transform.m42, transform.m43);
    [anchorPoint setPosition:position];
    [anchorPointsCollection appendAnchorPoint:anchorPoint];
    
    FLAnchorPointView *anchorPointView = [[FLAnchorPointView alloc] initWithAnchorPoint:anchorPoint withRootNode:self.sceneView.scene.rootNode
                                                                          withTransform:transform];
    [anchorPointsCollection addObserver:anchorPointView forKeyPath:@"selectedAnchorPoint"
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    
    [self.sceneView.scene.rootNode addChildNode:anchorPointView];
}

#pragma mark - Mouse events

-(void)mouseDown:(NSEvent *)theEvent
{
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.streams.selectedStream.anchorPoints;
    
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
    FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.streams.selectedStream.anchorPoints;
    
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
//        SCNVector3 lookAtPosition = anchorPointView.anchorPointModel.lookAt;
        
        if([_selectionHandleInDrag.name isEqualToString:@"zAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.x - oldWorldCoord.x;
            oldPosition.x += distanceDragged;
            anchorPointView.position = oldPosition;

//            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
//            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, distanceDragged, 0, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"yAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.y - oldWorldCoord.y;
            oldPosition.y += distanceDragged;
            anchorPointView.position = oldPosition;
            
//            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
//            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, distanceDragged, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"xAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.z - oldWorldCoord.z;
            oldPosition.z += distanceDragged;
            anchorPointView.position = oldPosition;
            
//            SCNVector4 rotation = FLRotatePointAToFacePointB(oldPosition, lookAtPosition);
//            anchorPointView.rotation = rotation;
            
            anchorPointView.anchorPointModel.position = anchorPointView.position;
            SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, 0, distanceDragged)];
        }
        
        lastClickedPoint = newMousePoint;

        return YES;
    }
    return NO;
}

-(void)mouseUp:(NSEvent *)theEvent
{
    _selectionHandleInDrag = nil;
}

-(void)rightMouseDown:(NSEvent *)theEvent
{
    lastClickedPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if(self.selectionMode == FLSelectionModeNone)
        [self.view.superview setMenu:streamsMenu];
    else
        [self.view.superview setMenu:anchorPointsMenu];
    
    [self.view.superview rightMouseDown:theEvent];
}

#pragma mark - Validations

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = menuItem.action;
    
    FLStreamsCollection *streamCollection = self.appFrameController.model.streams;
    if(action == @selector(deleteAnchorPoint:))
    {
        FLAnchorPointsCollection *anchorPointsCollection = streamCollection.selectedStream.anchorPoints;
        return (anchorPointsCollection.selectedAnchorPoint != nil);
    }
    return YES;
}

#pragma mark - NSView overrides

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(BOOL)becomeFirstResponder
{
    return YES;
}

#pragma mark - Utility

-(SCNNode*)hitPlane
{
    return [self.sceneView.scene.rootNode childNodeWithName:@"hitplane" recursively:YES];
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
