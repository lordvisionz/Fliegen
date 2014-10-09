//
//  FLStreamsCollection.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLStream;

extern NSString *const FLStreamAddedNotification;
extern NSString *const FLStreamDeletedNotification;

@interface FLStreamsCollection : NSObject

@property (readwrite) FLStream *selectedStream;

-(FLStream*)streamForId:(NSUInteger)streamId;

-(FLStream*)streamForIndex:(NSUInteger)index;

-(void)appendStream;

-(BOOL)deleteSelectedStream;

-(NSUInteger)streamsCount;

@end
