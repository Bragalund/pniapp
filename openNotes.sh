#!/bin/bash

ACTION='\033[1;90m'
FINISHED='\033[1;96m'
READY='\033[1;92m'
NOCOLOR='\033[0m' # No Color
ERROR='\033[0;31m'

show_help() {
    cat <<'HELP'
Usage: ./openNotes.sh [--help]

Fetches and decrypts the latest notes archive.
Creates ./notes on first run if no archive exists.

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

if [ ! -f "password.txt" ]
then
    touch password.txt;
    echo "Created a file called: password.txt" 
    echo "open it and paste your password for decrypting/encrypting your files into it."
    echo "Then rerun this script."
    exit 0;
fi

if [ ! -f "compressed.zip.001" ]
then
    echo "First time? No files/archives to decrypt. "
    if [ ! -d "$NOTES_DIR" ]
    then
        echo "Creating notes-folder."
        mkdir -p "$NOTES_DIR"
        echo "Open your favourite note-taking application and start taking notes."
    fi
    echo "Run closeNotes.sh to upload your notes :)"
    exit 0
fi

git fetch
HEADHASH=$(git rev-parse HEAD)
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1
then
    UPSTREAMHASH=$(git rev-parse @{u})
else
    UPSTREAMHASH=""
fi

if [ "$HEADHASH" != "$UPSTREAMHASH" ] || [ ! -d "$NOTES_DIR" ]
then
	git pull origin main;
	7z e compressed.zip.* -o"$NOTES_DIR" -p"$(cat password.txt)";
	exit 0
else 
    echo "Notes up to date :)";
fi
