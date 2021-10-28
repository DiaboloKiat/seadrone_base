#!/bin/bash

git checkout master

cd ~/seadrone_base/sensors/vision_opencv
git checkout melodic

cd ~/seadrone_base/sensors/apriltags_ros
git checkout indigo-devel

cd ~/seadrone_base/sensors/realsense-ros
git checkout 2.2.15

cd ~/seadrone_base