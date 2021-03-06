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
#import "FLUtilityPaneStreamsViewController.h"
#import "FLUtilityPaneAnchorPointsViewController.h"
#import "FLUtilityPaneStreamsViewController.h"

#import "FLModel.h"
#import "FLStreamsCollection.h"
#import "FLStream.h"
#import "FLAnchorPoint.h"
#import "FLAnchorPointsCollection.h"

#import "FLAnchorPointView.h"
#import "FLSceneView.h"
#import "FLStreamView.h"
#import "FLAxisNode.h"
#import "FLGridlines.h"
#import "FLSelectionHandles.h"

#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>
#import "FLSceneKitUtilities.h"

@interface FLSceneViewController ()
{
    NSMenu *anchorPointsMenu;
    NSMenu *streamsMenu;
    
    NSPoint lastClickedPoint;
    
    BOOL _deSelectClickedItem;
    BOOL _isDraggingSelectionHandles;
    SCNNode *_selectionHandleInDrag;
    
    FLAxisNode *_viewPortAxes;
    FLGridlines *_gridlines;
    
    SCNNode *_defaultCamera;
    
    SCNNode *_streamPOVCamera;
    SCNNode *_streamPOVLookAt;
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
    
    FLSceneView *sceneView = [[FLSceneView alloc] initWithFrame:NSZeroRect];
    sceneView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    sceneView.controller = self;
    sceneView.allowsCameraControl = YES;
    sceneView.scene = [SCNScene scene];
    sceneView.autoenablesDefaultLighting = YES;
    
    self.view = sceneView;
    return self;
}

-(void)setInitialCamera
{
    _defaultCamera = [SCNNode node];
    _defaultCamera.camera = [SCNCamera camera];
    [_defaultCamera.camera setUsesOrthographicProjection:NO];
    _defaultCamera.camera.zFar = 1000;
    
    CATransform3D cameraTransform = CATransform3DMakeRotation(M_PI_4/4, 0, 1, 0);
    cameraTransform = CATransform3DTranslate(cameraTransform, 0, 10, 75);
    _defaultCamera.transform = cameraTransform;
    [self.sceneView.scene.rootNode addChildNode:_defaultCamera];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasAdded:) name:FLStreamAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamWasDeleted:) name:FLStreamDeletedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointWasAdded:) name:FLAnchorPointAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointWasDeleted:) name:FLAnchorPointDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anchorPointSelectedChanged:)
                                                 name:FLAnchorPointSelectionChangedNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - Notifications/KVO/KVC

-(void)streamWasAdded:(NSNotification*)notification
{
    FLUtilityPaneStreamsViewController *streamsViewController = self.appFrameController.utilityPanelController.streamsPropertiesController;
    FLStream *stream = self.appFrameController.model.streams.selectedStream;
    FLStreamView *streamView = [[FLStreamView alloc] initWithStream:stream];

    [stream addObserver:streamView forKeyPath:NSStringFromSelector(@selector(streamType))
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [stream addObserver:streamView forKeyPath:NSStringFromSelector(@selector(streamVisualType))
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [stream addObserver:streamView forKeyPath:NSStringFromSelector(@selector(streamVisualColor))
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [streamView addObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(isSelectable))
                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [streamView addObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(isVisible))
                    options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [stream addObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(streamInterpolationType))
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [stream addObserver:streamView forKeyPath:NSStringFromSelector(@selector(streamInterpolationType))
                options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    
    [self.sceneView.scene.rootNode addChildNode:streamView];
    [[self selectionHandles] removeFromParentNode];
}

-(void)streamWasDeleted:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    FLStream *deletedStream = [userInfo objectForKey:NSStringFromClass([FLStream class])];
    FLStreamView *streamViewToBeDeleted = [self viewForStream:deletedStream];
    
    FLUtilityPaneStreamsViewController *streamsViewController = self.appFrameController.utilityPanelController.streamsPropertiesController;
    
    [deletedStream removeObserver:streamViewToBeDeleted forKeyPath:NSStringFromSelector(@selector(streamType))];
    [deletedStream removeObserver:streamViewToBeDeleted forKeyPath:NSStringFromSelector(@selector(streamVisualType))];
    [deletedStream removeObserver:streamViewToBeDeleted forKeyPath:NSStringFromSelector(@selector(streamVisualColor))];
    [streamViewToBeDeleted removeObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(isSelectable))];
    [streamViewToBeDeleted removeObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(isVisible))];
    [deletedStream removeObserver:streamsViewController forKeyPath:NSStringFromSelector(@selector(streamInterpolationType))];
    [deletedStream removeObserver:streamViewToBeDeleted forKeyPath:NSStringFromSelector(@selector(streamInterpolationType))];
    
    [streamViewToBeDeleted removeFromParentNode];
    streamViewToBeDeleted = nil;
    
    [[self selectionHandles] removeFromParentNode];
}

-(void)anchorPointWasAdded:(NSNotification*)notification
{
    FLStream *stream = self.appFrameController.model.streams.selectedStream;
    FLStreamView *streamView = [self viewForStream:stream];
    
    FLAnchorPoint *anchorPoint = self.appFrameController.model.streams.selectedStream.anchorPointsCollection.selectedAnchorPoint;
    FLAnchorPointView *anchorPointView = [[FLAnchorPointView alloc]initWithAnchorPoint:anchorPoint];
    
    [streamView addChildNode:anchorPointView];
    
    [anchorPoint addObserver:anchorPointView forKeyPath:NSStringFromSelector(@selector(position))
                     options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
    [self.sceneView.scene.rootNode addChildNode:[anchorPointView getSelectionHandles]];
}

-(void)anchorPointWasDeleted:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    FLAnchorPoint *deletedAnchorPoint = [userInfo objectForKey:NSStringFromClass([FLAnchorPoint class])];
    FLAnchorPointView *viewToBeDeleted = [self viewForAnchorPoint:deletedAnchorPoint];
    
    [deletedAnchorPoint removeObserver:viewToBeDeleted forKeyPath:NSStringFromSelector(@selector(position))];
    
    [viewToBeDeleted removeFromParentNode];
    [[self selectionHandles] removeFromParentNode];
}

-(void)anchorPointSelectedChanged:(NSNotification*)notification
{
    FLAnchorPoint *anchorPoint = self.appFrameController.model.streams.selectedStream.anchorPointsCollection.selectedAnchorPoint;
    FLAnchorPointView *anchorPointView = [self viewForAnchorPoint:anchorPoint];
    
    [[self selectionHandles] removeFromParentNode];
    [self.sceneView.scene.rootNode addChildNode:[anchorPointView getSelectionHandles]];
}

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

-(void)startCameraPOVSimulationWithCompletionHandler:(FLCameraSimulationCompletionHandler)completionHandler
{
    id<FLCurrentSimulatorProtocol> simulator = _appFrameController.model.simulator;
    NSMutableArray *visualizationPoints = [NSMutableArray new];
    NSMutableArray *simulationPoints = [NSMutableArray new];
    
    [simulator.visualizationStream.anchorPointsCollection.anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<FLAnchorPointProtocol> anchorPoint = obj;
        [visualizationPoints addObject:[NSValue valueWithSCNVector3:anchorPoint.position]];
    }];
    [simulator.simulationStream.anchorPointsCollection.anchorPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<FLAnchorPointProtocol> anchorPoint = obj;
        [simulationPoints addObject:[NSValue valueWithSCNVector3:anchorPoint.position]];
    }];
    
    _streamPOVCamera = [SCNNode node];
    _streamPOVCamera.camera = [SCNCamera camera];
    _streamPOVCamera.camera.usesOrthographicProjection = NO;
    _streamPOVCamera.camera.xFov = 90;
    _streamPOVCamera.camera.yFov = 90;
    _streamPOVCamera.camera.zFar = 1000;
    _streamPOVCamera.position = [[simulator.visualizationStream.anchorPointsCollection anchorPointForId:1] position];
    [self.sceneView.scene.rootNode addChildNode:_streamPOVCamera];
    self.sceneView.pointOfView = _streamPOVCamera;
    
    double maxTime = MAX([[simulator.visualizationStream.anchorPointsCollection.anchorPoints lastObject] sampleTime],
                             [[simulator.simulationStream.anchorPointsCollection.anchorPoints lastObject] sampleTime]);
    
    CAKeyframeAnimation *visualizationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CAKeyframeAnimation *simulationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSMutableArray *visualizationAnimationPoints = [NSMutableArray new];
    NSMutableArray *simulationAnimationPoints = [NSMutableArray new];
    FLStreamView *visualizationView = [self viewForStream:simulator.visualizationStream];
    FLStreamView *simulationView = [self viewForStream:simulator.simulationStream];
    
    for(NSUInteger i = 0; i < ceil(maxTime * 24); i++)
    {
        double sampleTime = (double) i / 24;
        double visualizationSampleTime = [self lerpVisualizationSampleTime:sampleTime];
        SCNVector3 interpolatedPosition = [visualizationView.curveInterpolator interpolatePoints:visualizationPoints atTime:visualizationSampleTime];
        [visualizationAnimationPoints addObject:[NSValue valueWithSCNVector3:interpolatedPosition]];
        
        double simulationSampleTime = [self lerpSimulationSampleTime:sampleTime];
        interpolatedPosition = [simulationView.curveInterpolator interpolatePoints:simulationPoints atTime:simulationSampleTime];
        [simulationAnimationPoints addObject:[NSValue valueWithSCNVector3:interpolatedPosition]];
    }
    
    visualizationAnimation.values = visualizationAnimationPoints;
    visualizationAnimation.duration = maxTime;
    visualizationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    simulationAnimation.values = simulationAnimationPoints;
    simulationAnimation.duration = maxTime;
    simulationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    _streamPOVLookAt = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:0 height:0 length:0 chamferRadius:0]];
    _streamPOVLookAt.position = [[simulator.simulationStream.anchorPointsCollection anchorPointForId:1] position];
    _streamPOVLookAt.name = @"lookAtObject";
    [self.sceneView.scene.rootNode addChildNode:_streamPOVLookAt];
    
    SCNConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:_streamPOVLookAt];
    _streamPOVCamera.constraints = @[constraint];
    
    [SCNTransaction begin];
    self.sceneView.allowsCameraControl = NO;
    [SCNTransaction setCompletionBlock:^{
        self.sceneView.pointOfView = _defaultCamera;
        [_streamPOVCamera removeFromParentNode];
        [_streamPOVLookAt removeFromParentNode];
        self.sceneView.allowsCameraControl = YES;
        
        if(completionHandler != NULL)
            completionHandler();
    }];
    [_streamPOVCamera addAnimation:visualizationAnimation forKey:@"position"];
    [_streamPOVLookAt addAnimation:simulationAnimation forKey:@"lookAt"];
    [SCNTransaction commit];
}

-(void)stopCameraPOVSimulation
{
    self.sceneView.pointOfView = _defaultCamera;
    [_streamPOVCamera removeFromParentNode];
    [_streamPOVLookAt removeFromParentNode];
    self.sceneView.allowsCameraControl = YES;
}

#pragma mark - Anchor Points add/delete

-(void)deleteAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.appFrameController.model.streams.selectedStream;
    [selectedStream.anchorPointsCollection deleteSelectedAnchorPoint];
}

-(void)pushAnchorPoint:(id)sender
{
    FLStream *selectedStream = self.appFrameController.model.streams.selectedStream;
    FLAnchorPointsCollection *anchorPointsCollection = selectedStream.anchorPointsCollection;
    
    FLAnchorPoint *anchorPoint = [[FLAnchorPoint alloc]initWithStream:selectedStream];

    NSArray *result = [self.sceneView hitTest:lastClickedPoint options:nil];
    SCNHitTestResult *hitResult = [result objectAtIndex:0];
    
    SCNVector3 localPoint = hitResult.localCoordinates;
    SCNVector4 cameraRotation = self.sceneView.pointOfView.rotation;
    CATransform3D transform = CATransform3DMakeRotation(cameraRotation.w, cameraRotation.x, cameraRotation.y, cameraRotation.z);
    transform = CATransform3DTranslate(transform, localPoint.x, localPoint.y, localPoint.z);
    
    SCNVector3 position = SCNVector3Make(transform.m41, transform.m42, transform.m43);
    [anchorPoint setPosition:position];
    [anchorPointsCollection appendAnchorPoint:anchorPoint];
}

#pragma mark - Mouse events

-(void)mouseDown:(NSEvent *)theEvent
{
    lastClickedPoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    NSArray *hitItems = [self.sceneView hitTest:lastClickedPoint options:nil];
    SCNHitTestResult *firstHitItem = [self firstSelectableHitTestResult:hitItems];
    
    if(firstHitItem == nil)
    {
        _deSelectClickedItem = YES;
        return;
    }
    SCNNode *selectionNode = [self selectionHandles];
    if(selectionNode != nil)
    {
        if([selectionNode childNodeWithName:firstHitItem.node.name recursively:YES] != nil)
        {
            _isDraggingSelectionHandles = YES;
            _selectionHandleInDrag = firstHitItem.node;
            return;
        }
    }

    FLAnchorPointView *anchorPoint = (FLAnchorPointView*)firstHitItem.node;
    FLStreamView *streamView = (FLStreamView*)anchorPoint.parentNode;
    
    FLStream *selectedStream = [self.appFrameController.model.streams streamForId:streamView.stream.streamId];
    FLAnchorPoint *selectedAnchorPoint = [selectedStream.anchorPointsCollection anchorPointForId:anchorPoint.anchorPoint.anchorPointID];
    
    self.appFrameController.model.streams.selectedStream = selectedStream;
    selectedStream.anchorPointsCollection.selectedAnchorPoint = selectedAnchorPoint;
    self.selectionMode = FLSelectionModeAnchorPoint;
}

-(BOOL)mouseDragged:(NSEvent *)theEvent
{
    _deSelectClickedItem = NO;
    NSPoint newMousePoint = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    if(_isDraggingSelectionHandles)
    {
        FLAnchorPointsCollection *anchorPointsCollection = self.appFrameController.model.streams.selectedStream.anchorPointsCollection;
        FLAnchorPoint *selectedAnchorPoint = anchorPointsCollection.selectedAnchorPoint;
        
        SCNHitTestResult *hitPlaneResult = [self hitTestForNode:[self hitPlane] atPoint:lastClickedPoint];
        SCNVector3 oldWorldCoord = hitPlaneResult.worldCoordinates;
        
        hitPlaneResult = [self hitTestForNode:[self hitPlane] atPoint:newMousePoint];
        SCNVector3 newWorldCoord = hitPlaneResult.worldCoordinates;

        SCNVector3 oldPosition = selectedAnchorPoint.position;
        SCNNode *selectionHandles = [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
        if([_selectionHandleInDrag.name isEqualToString:@"xAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.x - oldWorldCoord.x;
            oldPosition.x += distanceDragged;
            selectedAnchorPoint.position = oldPosition;
            
            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, distanceDragged, 0, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"yAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.y - oldWorldCoord.y;
            oldPosition.y += distanceDragged;
            selectedAnchorPoint.position = oldPosition;

            [selectionHandles setTransform:CATransform3DTranslate(selectionHandles.transform, 0, distanceDragged, 0)];
        }
        else if([_selectionHandleInDrag.name isEqualToString:@"zAxisTranslate"])
        {
            double distanceDragged = newWorldCoord.z - oldWorldCoord.z;
            oldPosition.z += distanceDragged;
            selectedAnchorPoint.position = oldPosition;

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
    _isDraggingSelectionHandles = NO;
    if(_deSelectClickedItem == YES)
    {
        self.selectionMode = FLSelectionModeNone;
        FLStreamsCollection *streams = self.appFrameController.model.streams;
        FLAnchorPointsCollection *anchorPoints = streams.selectedStream.anchorPointsCollection;

        anchorPoints.selectedAnchorPoint = nil;
        streams.selectedStream = nil;
    }
    _deSelectClickedItem = NO;
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
        FLAnchorPointsCollection *anchorPointsCollection = streamCollection.selectedStream.anchorPointsCollection;
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

-(FLStreamView*)viewForStream:(FLStream*)stream
{
    NSArray *childNodes = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop)
    {
        if([child isKindOfClass:[FLStreamView class]] == NO) return NO;
        FLStreamView *streamView = (FLStreamView*)child;
        
        if(streamView.stream == stream)
        {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if(childNodes.count == 0) return nil;
    
    return [childNodes objectAtIndex:0];
}

-(FLAnchorPoint*)anchorPointForView:(FLAnchorPointView*)view
{
    FLStreamView *streamView = (FLStreamView*)view.parentNode;
    FLStream *stream = [self.appFrameController.model.streams streamForId:streamView.stream.streamId];
    return [stream.anchorPointsCollection anchorPointForId:view.anchorPoint.anchorPointID];
}

-(FLAnchorPointView*)viewForAnchorPoint:(FLAnchorPoint*)anchorPoint
{
    NSArray *childNodes = [self.sceneView.scene.rootNode childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop)
   {
       if([child isKindOfClass:[FLAnchorPointView class]] == NO) return NO;
       FLAnchorPointView *anchorPointView = (FLAnchorPointView*) child;
       
       if(anchorPointView.anchorPoint == anchorPoint)
       {
           *stop = YES;
           return YES;
       }
       return NO;
   }];
    if(childNodes.count == 0) return nil;
    
    return [childNodes objectAtIndex:0];
}

-(SCNHitTestResult*)firstSelectableHitTestResult:(NSArray*)hitItems
{
    NSUInteger hitIndex = [hitItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        SCNNode *node = [obj node];
        BOOL isASelectionHandle = NO;
        SCNNode *selectionHandles = [self selectionHandles];
        if(selectionHandles != nil)
        {
            isASelectionHandle = ([selectionHandles childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
                if(child == node)
                {
                    *stop = YES;
                    return YES;
                }
                return NO;
            }].count > 0);
        }
        if(isASelectionHandle == YES)
        {
            *stop = YES;
            return YES;
        }
        if([node isKindOfClass:[FLAnchorPointView class]] == YES)
        {
            FLStreamView *streamView = (FLStreamView*)node.parentNode;
            if(streamView.isSelectable)
            {
                *stop = YES;
                return YES;
            }
        }
        return NO;
    }];
    if(hitIndex == NSNotFound)return nil;
    
    return [hitItems objectAtIndex:hitIndex];
}

-(SCNHitTestResult*)hitTestForNode:(SCNNode*)node atPoint:(NSPoint)point
{
    NSArray *hitItems = [self.sceneView hitTest:point options:nil];
    NSUInteger hitIndex =[hitItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            if([obj node] == node)
            {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if(hitIndex == NSNotFound) return NO;
    return [hitItems objectAtIndex:hitIndex];
}

-(SCNNode*)hitPlane
{
    return [self.sceneView.scene.rootNode childNodeWithName:@"hitplane" recursively:YES];
}

-(SCNNode*)selectionHandles
{
    return [self.sceneView.scene.rootNode childNodeWithName:@"selectionHandles" recursively:YES];
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

#pragma mark - Private Helpers

-(double)lerpVisualizationSampleTime:(double)sampleTime
{
    id<FLCurrentSimulatorProtocol> simulator = _appFrameController.model.simulator;
    NSUInteger visAnchorPointsCount = simulator.visualizationStream.anchorPointsCollection.anchorPoints.count;
    
    NSUInteger visAnchorPointAhead = [simulator.visualizationStream.anchorPointsCollection.anchorPoints indexOfObjectPassingTest:
                                      ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                      {
                                          id<FLAnchorPointProtocol> anchorPoint = obj;
                                          if (anchorPoint.sampleTime > sampleTime)
                                          {
                                              *stop = YES;
                                              return YES;
                                          }
                                          return NO;
                                      }];
    if(visAnchorPointAhead == NSNotFound) return 1 - DBL_EPSILON;
    if(visAnchorPointAhead == 0) return 0;
    
    NSUInteger visAnchorPointBehind = MAX(0, (NSInteger)visAnchorPointAhead - 1);
    double visAnchorPointAheadSampleTime = [[simulator.visualizationStream.anchorPointsCollection
                                             anchorPointForIndex:visAnchorPointAhead] sampleTime];
    double visAnchorPointBehindSampleTime = (visAnchorPointAhead == 0) ? 0 : [[simulator.visualizationStream.anchorPointsCollection
                                                                               anchorPointForIndex:visAnchorPointBehind] sampleTime];
    
    double lerpedPercent = (sampleTime - visAnchorPointBehindSampleTime) / (visAnchorPointAheadSampleTime - visAnchorPointBehindSampleTime);
    return (double)visAnchorPointBehind / (visAnchorPointsCount - 1) + lerpedPercent / (visAnchorPointsCount - 1);
}

-(double)lerpSimulationSampleTime:(double)sampleTime
{
    id<FLCurrentSimulatorProtocol> simulator = _appFrameController.model.simulator;
    NSUInteger simAnchorPointsCount = simulator.simulationStream.anchorPointsCollection.anchorPoints.count;
    
    NSUInteger simAnchorPointAhead = [simulator.simulationStream.anchorPointsCollection.anchorPoints indexOfObjectPassingTest:
                                      ^BOOL(id obj, NSUInteger idx, BOOL *stop)
                                      {
                                          id<FLAnchorPointProtocol> anchorPoint = obj;
                                          if (anchorPoint.sampleTime > sampleTime)
                                          {
                                              *stop = YES;
                                              return YES;
                                          }
                                          return NO;
                                      }];
    if(simAnchorPointAhead == NSNotFound) return 1 - DBL_EPSILON;
    if(simAnchorPointAhead == 0) return 0;
    
    NSUInteger simAnchorPointBehind = MAX(0, (NSInteger)simAnchorPointAhead - 1);
    double simAnchorPointAheadSampleTime = [[simulator.simulationStream.anchorPointsCollection
                                             anchorPointForIndex:simAnchorPointAhead] sampleTime];
    double simAnchorPointBehindSampleTime = (simAnchorPointAhead == 0) ? 0 : [[simulator.simulationStream.anchorPointsCollection
                                                                               anchorPointForIndex:simAnchorPointBehind] sampleTime];
    
    double lerpedPercent = (sampleTime - simAnchorPointBehindSampleTime) / (simAnchorPointAheadSampleTime - simAnchorPointBehindSampleTime);
    return (double)simAnchorPointBehind / (simAnchorPointsCount - 1) + lerpedPercent / (simAnchorPointsCount - 1);
}

@end
