//
//  FLStreamsCollection.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLStreamsCollection.h"
#import "FLStream.h"

NSString *const FLStreamAddedNotification = @"FLStreamAddedNotification";
NSString *const FLStreamDeletedNotification = @"FLStreamDeletedNotification";

@interface FLStreamsCollection()
{
    NSMutableArray *_streams;

}
@end

@implementation FLStreamsCollection

-(id)init
{
    self = [super init];
    
    _streams = [[NSMutableArray alloc]init];
    _selectedStream = nil;
    return self;
}

-(FLStream *)streamForId:(NSUInteger)streamId
{
    if(streamId > _streams.count) return nil;
    return [_streams objectAtIndex:(streamId - 1)];
}

-(FLStream *)streamForIndex:(NSUInteger)index
{
    if(index >= _streams.count) return nil;
    return [_streams objectAtIndex:index];
}

-(void)appendStream
{
    FLStream *stream = [[FLStream alloc]init];
    [_streams addObject:stream];
    stream.streamId = _streams.count;
    
    self.selectedStream = stream;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLStreamAddedNotification object:self];
}

-(BOOL)deleteSelectedStream
{
    if(_selectedStream == nil) return NO;
    
    NSUInteger oldSelectedStreamID = self.selectedStream.streamId;
    
    [_streams removeObject:self.selectedStream];
    self.selectedStream = nil;
    
    [_streams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FLStream *stream = obj;
        if(stream.streamId > oldSelectedStreamID)
            stream.streamId -= 1;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLStreamDeletedNotification object:self];
    return YES;
}

-(NSUInteger)streamsCount
{
    return _streams.count;
}

@end
