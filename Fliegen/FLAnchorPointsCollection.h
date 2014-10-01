//
//  FLAnchorPointsCollection.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 3/29/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLAnchorPoint;

@interface FLAnchorPointsCollection : NSObject
{
    NSMutableArray *_anchorPoints;
}

@property (readwrite) FLAnchorPoint *selectedAnchorPoint;

-(FLAnchorPoint*)anchorPointForId:(NSUInteger)anchorPointId;

-(FLAnchorPoint*)anchorPointForIndex:(NSUInteger)index;

-(void)appendAnchorPoint:(FLAnchorPoint*)anchorPoint;

-(BOOL)deleteSelectedAnchorPoint;

-(NSUInteger)anchorPointsCount;

@end
