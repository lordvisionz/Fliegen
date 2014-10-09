//
//  FLSceneKitUtilities.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 9/26/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <GLKit/GLKit.h>

NS_INLINE SCNVector4 FLRotatePointAToFacePointB(SCNVector3 A, SCNVector3 B)
{
    GLKVector3 upVector = GLKVector3Make(0, 1, 0);
    GLKVector3 directionOfLookAt = GLKVector3Make(B.x - A.x, B.y - A.y, B.z - A.z);
    directionOfLookAt = GLKVector3Normalize(directionOfLookAt);
    
    float angle = acosf(GLKVector3DotProduct(upVector, directionOfLookAt));
    GLKVector3 rotationVector = GLKVector3CrossProduct(upVector, directionOfLookAt);
    
    if(rotationVector.x == 0 && rotationVector.y == 0 && rotationVector.z == 0)
        rotationVector = GLKVector3Make(0, 0, 1);

    rotationVector = GLKVector3Normalize(rotationVector);
    
    return SCNVector4Make(rotationVector.x, rotationVector.y, rotationVector.z, angle);
}
