//
//  FLStream.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLStreamProtocol.h"

@class FLAnchorPointsCollection;

@interface FLStream : NSObject<FLStreamProtocol>

@property (readwrite, retain) FLAnchorPointsCollection *anchorPoints;

@end
