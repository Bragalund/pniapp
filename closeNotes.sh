#!/bin/bash 

ACTION='\033[1;90m'
FINISHED='\033[1;96m'
READY='\033[1;92m'
NOCOLOR='\033[0m' # No Color
ERROR='\033[0;31m'

echo
echo -e ${ACTION}Checking Git repo
echo -e =======================${NOCOLOR}

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" != "master" ]; then
	echo -e ${ERROR}Not on master. Aborting. ${NOCOLOR}
	echo
	exit 0 
fi 

if [ -f compressed.zip.001 ]; then
	echo "removing existing compressed files." 
	rm compressed.zip.*;
	echo "removed existing compressed files."
fi

7z a -tzip -v50M -mx=9 ./compressed ./notes -p$(cat password.txt) -aoa;
git add 'compressed.zip.*';
git commit -m "Compressed some files";
git push origin master;
