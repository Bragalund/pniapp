#!/bin/bash 

set -euo pipefail
IFS=$'\n\t'

ACTION='\033[1;90m'
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

echo
printf '%bChecking Git repo\n' "$ACTION"
printf '=======================%b\n' "$NOCOLOR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf '%bNot inside a git repo. Aborting.%b\n' "$ERROR" "$NOCOLOR"
    echo
    exit 1
fi

if [ ! -d "$NOTES_DIR" ]; then
    printf '%bMissing %s directory. Aborting.%b\n' "$ERROR" "$NOTES_DIR" "$NOCOLOR"
    exit 1
fi

if [ ! -s "password.txt" ]; then
    printf '%bMissing or empty password.txt. Aborting.%b\n' "$ERROR" "$NOCOLOR"
    exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" != "master" ] && [ "$BRANCH" != "main" ]; then
    printf '%bNot on main or master. Aborting.%b\n' "$ERROR" "$NOCOLOR"
    echo
    exit 1 
fi 

if [ -f compressed.zip.001 ]; then
    printf 'removing existing compressed files.\n'
    rm -f compressed.zip.*;
    printf 'removed existing compressed files.\n'
fi

PASSWORD=$(<password.txt)
OUTPUT_ARCHIVE="$PWD/compressed"

(cd "$NOTES_DIR" && 7z a -tzip -v50M -mx=9 "$OUTPUT_ARCHIVE" . -p"$PASSWORD" -aoa)

git add 'compressed.zip.*';
if git diff --cached --quiet; then
    printf 'No changes to commit.\n'
    exit 0
fi

git commit -m "Compressed some files";
git push origin "$BRANCH";
