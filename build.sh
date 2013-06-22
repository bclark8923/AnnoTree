#!/usr/bin/env sh

# One step build script
# Steps are:
# 1) update repo
# 2) refresh db
# 3) start development (morbo) server

usage() {
    echo "Usage: build.sh ENV [GIT-REMOTE]" # [PUSH|PULL]"
    echo "\tENV: matt aws-dev1"
    echo "\tGIT-REMOTE: the name of remote repo (optional in some cases)"
    # echo "\t:PUSH|PULL push/pull from the remote repo (optional in some cases)"
    exit
}

build() {
    sudo chown -R matt:dev ,git
    git stash
    git pull $1 master
    cd Database
    ./install.py
    cd ..
    nohup morbo WebServices/anno_tree/script/anno_tree &
}

if [ -z $1 ]; then
    usage
fi

if [ $1 = "aws-dev1" ]; then #|| [ $1 = "matt" ]
    if [ -z $2 ]; then
        usage
    else
        sudo chown -R matt:dev ,git
        git stash
        git pull $2 master
        cd Database
        ./install.py
        cd ..
        nohup morbo WebServices/anno_tree/script/anno_tree &
    fi
    #build $2
elif [ $1 = "matt" ]; then
    git pull lots-annotree-ssh master
    cd Database
    ./install.py
    cd ..
    nohup morbo WebServices/anno_tree/script/anno_tree &
else 
    usage
fi
