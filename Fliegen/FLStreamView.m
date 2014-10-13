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
    _isVisible = YES;
    _isSelectable = YES;
    return self;
}

#pragma mark - Property setters

-(void)setIsVisible:(BOOL)isVisible
{
    if(_isVisible == isVisible) return;
    
    _isVisible = isVisible;
    if(_isVisible == NO)
        self.isSelectable = NO;
    
    [self setHidden:!isVisible];
}

-(void)setIsSelectable:(BOOL)isSelectable
{
    if(isSelectable == _isSelectable) return;
    
    _isSelectable = isSelectable;
    if(_isSelectable == YES)
        self.isVisible = YES;
    
    
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
    else if([keyPath isEqualToString:NSStringFromSelector(@selector(streamVisualColor))] == YES)
    {
        [self.childNodes makeObjectsPerformSelector:@selector(updateAnchorPointColor)];
    }
}

@end
