//
//  FLAnchorPointProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@protocol FLStreamProtocol;

@protocol FLAnchorPointProtocol <NSObject>

@property (readonly) id<FLStreamProtocol> stream;

@property (readwrite) NSUInteger anchorPointID;

@property(readwrite) SCNVector3 position;

@property(readwrite) double sampleTime;

@end
