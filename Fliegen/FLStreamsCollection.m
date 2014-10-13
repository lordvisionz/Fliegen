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

@synthesize selectedStream = _selectedStream;
@synthesize streams = _streams;

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
    stream.streamId = _streams.count + 1;
    stream.streamType = FLStreamTypePosition;
    stream.streamVisualType = FLStreamVisualTypeSphere;
    
    [_streams addObject:stream];
    self.selectedStream = stream;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLStreamAddedNotification object:self];
}

-(BOOL)deleteSelectedStream
{
    if(_selectedStream == nil) return NO;
    
    FLStream *oldSelectedStream = self.selectedStream;
    
    self.selectedStream = nil;
    [_streams removeObject:oldSelectedStream];
    
    [_streams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FLStream *stream = obj;
        if(stream.streamId > oldSelectedStream.streamId)
            stream.streamId -= 1;
    }];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:oldSelectedStream, NSStringFromClass([FLStream class]), nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLStreamDeletedNotification object:self userInfo:userInfo];
    return YES;
}

-(NSUInteger)count
{
    return _streams.count;
}

@end
