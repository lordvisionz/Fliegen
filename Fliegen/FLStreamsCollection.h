//
//  FLStreamsCollection.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLStreamsCollectionProtocol.h"

extern NSString *const FLStreamAddedNotification;
extern NSString *const FLStreamDeletedNotification;

@interface FLStreamsCollection : NSObject<FLStreamsCollectionProtocol>



@end
