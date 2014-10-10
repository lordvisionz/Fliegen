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

#import "FLAnchorPointProtocol.h"

@interface FLAnchorPoint : NSObject<FLAnchorPointProtocol>

-(id)initWithStream:(id<FLStreamProtocol>)stream;

@end
