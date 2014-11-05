//
//  FLModel.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLStreamsCollectionProtocol.h"

@interface FLModel : NSObject

@property (readonly, retain) id<FLStreamsCollectionProtocol> streams;

@end
