//
//  FLAnchorPointsCollection.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLStreamProtocol.h"
#import "FLAnchorPointsCollectionProtocol.h"

@class FLAnchorPoint;

@interface FLAnchorPointsCollection : NSObject<FLAnchorPointsCollectionProtocol>

-(id)initWithStream:(id<FLStreamProtocol>)stream;

@end
