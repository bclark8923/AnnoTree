#!/usr/bin/env sh

# One step build script
# Steps are:
# 1) update repo
# 2) refresh db
# 3) start development (morbo) server

usage() {
    echo "Usage: build.sh ENV"
    echo "\tENV: matt aws-dev1"
    exit
}

if [ -z $1 ]; then
    usage
fi

if [ $1 = "aws-dev1" ]; then
    git stash
    git pull lots-www master
    cd Database
    ./install.py
    cd ..
    nohup morbo WebServices/anno_tree/script/anno_tree &
elif [ $1 = "matt" ]; then
    echo "matt"
else 
    usage
fi
