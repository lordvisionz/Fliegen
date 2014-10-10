//
//  FLStreamView.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <SceneKit/SceneKit.h>

#import "FLStreamProtocol.h"

@interface FLStreamView : SCNNode

-(id)initWithStream:(id<FLStreamProtocol>)stream;

@property (readonly, assign) id<FLStreamProtocol> stream;

@end