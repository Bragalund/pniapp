#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

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

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    show_help
    exit 0
fi

if [ "$#" -gt 0 ]; then
    printf 'Unknown option: %s\n' "$1"
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
    printf 'Created a file called: password.txt\n'
    printf 'open it and paste your password for decrypting/encrypting your files into it.\n'
    printf 'Then rerun this script.\n'
    exit 0;
fi

if [ ! -f "compressed.zip.001" ]
then
    printf 'First time? No files/archives to decrypt.\n'
    if [ ! -d "$NOTES_DIR" ]
    then
        printf 'Creating notes-folder.\n'
        mkdir -p "$NOTES_DIR"
        printf 'Open your favourite note-taking application and start taking notes.\n'
    fi
    printf 'Run closeNotes.sh to upload your notes :)\n'
    exit 0
fi

git fetch
HEADHASH=$(git rev-parse HEAD)
if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1
then
    UPSTREAMHASH=$(git rev-parse "@{u}")
else
    UPSTREAMHASH=""
fi

if [ "$HEADHASH" != "$UPSTREAMHASH" ] || [ ! -d "$NOTES_DIR" ]
then
	git pull origin main;
	PASSWORD=$(<password.txt)
	7z x compressed.zip.* -o"$NOTES_DIR" -p"$PASSWORD";
	exit 0
else 
    printf 'Notes up to date :)\n'
fi
