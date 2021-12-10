#! /bin/bash

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

BRANCH=melodic
echo "---------------------------------------------------------------------------------------------------"
echo "-------------------------------------pull vision_opencv--------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/$PROJECT/sensors/vision_opencv
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
cd ~/$PROJECT/sensors/apriltags_ros
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
cd ~/$PROJECT/sensors/realsense-ros
git checkout 2.2.15
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in realsense-ros. Aborting"
   return 1
fi

BRANCH=master
echo "---------------------------------------------------------------------------------------------------"
echo "---------------------------------------pull seadrone_base------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/$PROJECT
git checkout $BRANCH
git pull

CONFLICTS=$(git ls-files -u | wc -l)
if [ "$CONFLICTS" -gt 0 ] ; then
   echo "There is conflict in seadrone_base. Aborting"
   return 1
fi

cd ~/$REPO
return 0
