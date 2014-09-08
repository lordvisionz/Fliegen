//
//  FLModel.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FLAnchorPointsCollection;

@interface FLModel : NSObject

@property (readonly, retain) FLAnchorPointsCollection *anchorPointsCollection;

@end
