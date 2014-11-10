//
//  FLUtilities.m
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/19/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLConstants.h"

NS_INLINE double FLEditorScaleFactorToPixels(FLVisualizationSimulationScaleFactor scaleFactor)
{
    switch(scaleFactor)
    {
        case FLVisualizationSimulationScaleFactor25Pixels:
            return 25;
        case FLVisualizationSimulationScaleFactor50Pixels:
            return 50;
        case FLVisualizationSimulationScaleFactor100Pixels:
            return 100;
        case FLVisualizationSimulationScaleFactor200Pixels:
            return 200;
    }
}