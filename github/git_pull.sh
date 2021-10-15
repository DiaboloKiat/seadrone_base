#! /bin/bash

# echo "password: $2"
git checkout master
BRANCH=master
if [ ! -z "$1" ]; then
    echo "pull branch: $1"
    BRANCH=$1
fi

echo "---------------------------------------------------------------------------------------------------"
echo "---------------------------------------pull seadrone_base------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in seadrone_base. Aborting"
   return 1
fi

BRANCH=melodic
echo "---------------------------------------------------------------------------------------------------"
echo "-------------------------------------pull vision_opencv--------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/seadrone_base/sensors/vision_opencv
git checkout $BRANCH
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in vision_opencv. Aborting"
   return 1
fi

BRANCH=indigo-devel
echo "---------------------------------------------------------------------------------------------------"
echo "-------------------------------------pull apriltags-ros--------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/seadrone_base/sensors/apriltags-ros
git checkout $BRANCH
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in apriltags-ros. Aborting"
   return 1
fi

echo "---------------------------------------------------------------------------------------------------"
echo "-------------------------------------pull realsense-ros--------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/seadrone_base/sensors/realsense-ros
git checkout 2.2.15
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in realsense-ros. Aborting"
   return 1
fi

cd ~/seadrone_base
return 0
