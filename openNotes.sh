#!/bin/bash

ACTION='\033[1;90m'
FINISHED='\033[1;96m'
READY='\033[1;92m'
NOCOLOR='\033[0m' # No Color
ERROR='\033[0;31m'

# Install needed dependencies if not installed

if ! command -v git &> /dev/null
then
    sudo apt update -y;
    sudo apt install git -y;
    exit;
fi  

if ! command 7z &> /dev/null
then
    sudo apt update -y;
    sudo apt install p7zip-full -y;
    exit 0;
fi

git fetch
HEADHASH=$(git rev-parse HEAD)
UPSTREAMHASH=$(git rev-parse master@{upstream})

if [ ! -f "password.txt" ]
then
    touch password.txt;
    echo "Created a file called: password.txt" 
    echo "open it and paste your password for decrypting/encrypting your files into it."
    echo "Then rerun this script."
    exit 1;
fi

if [ "$HEADHASH" != "$UPSTREAMHASH" ] || [ ! -d "./notes" ]
then
	git pull origin master;
	7z e "compressed.zip.*" -onotes -p$(cat password.txt);
	exit 0
else 
    echo "Notes up to date :)";
fi



