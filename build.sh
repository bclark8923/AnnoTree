#!/usr/bin/env sh

# One step build script
# Steps are:
# 1) update repo
# 2) refresh db
# 3) start development (morbo) server

usage() {
    echo "Usage: build.sh ENV GIT-REMOTE"
    echo "\tENV: matt aws-dev1"
    echo "\t GIT-REMOTE: the name of remote repo"
    exit
}

build() {
    git stash
    git pull $2 master
    cd Database
    ./install.py
    cd ..
    nohup morbo WebServices/anno_tree/script/anno_tree &
}

if [ -z $1 || -z $2 ]; then
    usage
fi

if [ $1 = "aws-dev1" ] || [ $1 = "matt" ]; then
    build
#elif [ $1 = "matt" ]; then
#    build
else 
    usage
fi
