//
//  FLConstants.h
//  Fliegen
//
//  Created by Abhishek Moothedath on 10/7/14.
//  Copyright (c) 2014 Abhishek Moothedath. All rights reserved.
//

#ifndef Fliegen_FLConstants_h
#define Fliegen_FLConstants_h

#define FL_GRIDLINES_WIDTH 20
#define FL_VIEWPORT_AXES_LENGTH FL_GRIDLINES_WIDTH

#define FL_PROPERTIES_TAB_WIDTH 300

#define FL_SIMULATION_VISUALIZATION_HEIGHT 200
#define FL_SIMULATION_VISUALIZATION_WIDTH_BETWEEN_POINTS 100

#define FL_VISUALIZATION_START_TIME_DEFAULT 0
#define FL_MIN_VISUALIZATION_TIME_DURATION 30

#define FL_SIMULATION_START_TIME_DEFAULT 0
#define FL_MIN_SIMULATION_TIME_DURATION 30

typedef NS_ENUM(unsigned short, FLVisualizationSimulationScaleFactor)
{
    FLVisualizationSimulationScaleFactor25Pixels = 0,
    FLVisualizationSimulationScaleFactor50Pixels = 1,
    FLVisualizationSimulationScaleFactor100Pixels = 2,
    FLVisualizationSimulationScaleFactor200Pixels = 3
};

#endif
