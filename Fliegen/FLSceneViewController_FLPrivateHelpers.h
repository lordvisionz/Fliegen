//
//  FLSceneViewController_FLPrivateHelpers.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/12/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import "FLSceneViewController.h"

@class FLStream, FLStreamView;

@interface FLSceneViewController ()

-(FLStreamView*)viewForStream:(FLStream*)stream;

@end
