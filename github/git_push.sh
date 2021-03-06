#!/bin/bash

git config --global user.name "DiaboloKiat"
git config --global user.email "DiaboloKiat@gmail.com"

git status
git checkout master
echo "Enter your message"
read message

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

BRANCH=master
echo "---------------------------------------------------------------------------------------------------"
source ~/$PROJECT/github/git_branch.sh $1
echo "---------------------------------------------------------------------------------------------------"
source ~/$PROJECT/github/git_pull.sh $1

PULLSTAT=$?
if [ "$PULLSTAT" -gt 0 ] ; then
   echo "There is conflict. Aborting"
   cd $cur_path/
   return
fi
echo "---------------------------------------------------------------------------------------------------"
echo "-------------------------------------------pull success--------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"


# push master

echo "---------------------------------------------------------------------------------------------------"
echo "------------------------------------------push seadrone_base---------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
cd ~/$PROJECT
git add -A
git commit -m "${message} on seadrone_base"
git push


cd ~/$REPO