#!/bin/bash

if [ "$1" = "base" ]
then
    PROJECT=seadrone_base
    REPO=seadrone_base
elif [ "$1" = "project_seadrone" ]
then
    PROJECT=project_seadrone/catkin_ws/src/seadrone_base
    REPO=project_seadrone
else
    echo "Please enter your project"
    return 0
fi

cd ~/$PROJECT
git checkout master

############################## submodules ####################################
cd ~/$PROJECT/sensors/vision_opencv
git checkout melodic

cd ~/$PROJECT/sensors/apriltags_ros
git checkout indigo-devel

cd ~/$PROJECT/sensors/realsense-ros
git checkout 2.2.15

cd ~/$REPO