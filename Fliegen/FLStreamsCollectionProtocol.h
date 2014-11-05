//
//  FLStreamsCollectionProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/13/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLStreamProtocol.h"
@protocol FLStreamsCollectionProtocol <NSObject>


@property (readwrite) id<FLStreamProtocol> selectedStream;

@property(readonly) NSUInteger count;

@property(readonly) NSArray *streams;

-(id<FLStreamProtocol>)streamForId:(NSUInteger)streamId;

-(id<FLStreamProtocol>)streamForIndex:(NSUInteger)index;

-(void)appendStream;

-(BOOL)deleteSelectedStream;

-(NSArray*)streamsWithStreamType:(FLStreamType)streamType;

@end
