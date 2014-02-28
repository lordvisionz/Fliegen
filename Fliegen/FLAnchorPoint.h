//
//  FLAnchorPoint.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 2/27/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <SceneKit/SceneKitTypes.h>

@interface FLAnchorPoint : NSObject

@property (readwrite) NSUInteger anchorPointID;

@property(readwrite) SCNVector3 position;

@property(readwrite) SCNVector3 lookAt;

@end
