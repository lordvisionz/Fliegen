//
//  FLStreamProtocol.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/9/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned short, FLStreamType)
{
    FLStreamTypePosition = 0,
    FLStreamTypeLookAt = 1
};

typedef NS_ENUM(unsigned short, FLStreamVisualType)
{
    FLStreamVisualTypeSphere = 0,
    FLStreamVisualTypeCone = 1
};

@protocol FLStreamProtocol <NSObject>

@property (readwrite, assign) NSUInteger streamId;

@property (readwrite, assign) FLStreamType streamType;

@property (readwrite, assign) FLStreamVisualType streamVisualType;

@end