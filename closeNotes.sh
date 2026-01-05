#!/bin/bash 

ACTION='\033[1;90m'
FINISHED='\033[1;96m'
READY='\033[1;92m'
NOCOLOR='\033[0m' # No Color
ERROR='\033[0;31m'

show_help() {
    cat <<'HELP'
Usage: ./closeNotes.sh [--help]

Compresses and encrypts ./notes into split archives, then commits and pushes.

Environment:
  NOTES_DIR   Notes directory to create/use (default: ./notes)
HELP
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ "$#" -gt 0 ]; then
    echo "Unknown option: $1"
    show_help
    exit 1
fi

ensure_cmd() {
    local cmd="$1"
    local pkg="$2"

    if ! command -v "$cmd" &> /dev/null; then
        if ! command -v sudo &> /dev/null; then
            echo -e "${ERROR}Missing sudo; cannot install $pkg.${NOCOLOR}"
            exit 1
        fi
        if ! command -v apt &> /dev/null; then
            echo -e "${ERROR}Missing apt; cannot install $pkg.${NOCOLOR}"
            exit 1
        fi
        sudo apt update -y
        sudo apt install "$pkg" -y
        exit 0
    fi
}

# Install needed dependencies if not installed

ensure_cmd git git
ensure_cmd 7z p7zip-full

NOTES_DIR="${NOTES_DIR:-./notes}"

echo
echo -e ${ACTION}Checking Git repo
echo -e =======================${NOCOLOR}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e ${ERROR}Not inside a git repo. Aborting.${NOCOLOR}
    echo
    exit 1
fi

if [ ! -d "$NOTES_DIR" ]; then
    echo -e ${ERROR}Missing $NOTES_DIR directory. Aborting.${NOCOLOR}
    exit 1
fi

if [ ! -s "password.txt" ]; then
    echo -e ${ERROR}Missing or empty password.txt. Aborting.${NOCOLOR}
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" != "master" ] && [ "$BRANCH" != "main" ]; then
    echo -e ${ERROR}Not on main or master. Aborting. ${NOCOLOR}
    echo
    exit 0 
fi 

if [ -f compressed.zip.001 ]; then
    echo "removing existing compressed files." 
    rm -f compressed.zip.*;
    echo "removed existing compressed files."
fi

7z a -tzip -v50M -mx=9 ./compressed "$NOTES_DIR" -p"$(cat password.txt)" -aoa;

git add 'compressed.zip.*';
if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

git commit -m "Compressed some files";
git push origin "$BRANCH";
