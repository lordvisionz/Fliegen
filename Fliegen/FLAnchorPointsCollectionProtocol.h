//
//  FLAnchorPointsCollectionProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/13/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLAnchorPointProtocol.h"

@protocol FLAnchorPointsCollectionProtocol <NSObject>

@property (readonly) id<FLStreamProtocol> stream;

@property(readonly) NSArray *anchorPoints;

@property (readwrite, nonatomic) id<FLAnchorPointProtocol> selectedAnchorPoint;

-(id<FLAnchorPointProtocol>)anchorPointForId:(NSUInteger)anchorPointId;

-(id<FLAnchorPointProtocol>)anchorPointForIndex:(NSUInteger)index;

-(void)appendAnchorPoint:(id<FLAnchorPointProtocol>)anchorPoint;

-(BOOL)deleteSelectedAnchorPoint;

@end
