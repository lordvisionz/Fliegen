//
//  FLStreamView.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLStreamView.h"
#import "FLAnchorPointView.h"

@implementation FLStreamView

-(id)initWithStream:(id<FLStreamProtocol>)stream
{
    self = [super init];
    _stream = stream;
    return self;
}

#pragma mark - Notifications/KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:NSStringFromSelector(@selector(streamType))] == YES)
    {
        NSLog(@"stream type changed");
    }
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualType)) ] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateGeometry)];
    }
}

@end
