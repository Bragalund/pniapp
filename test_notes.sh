#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing required command: $cmd" >&2
        exit 1
    fi
}

require_cmd git
require_cmd 7z
require_cmd mktemp
require_cmd diff

REPO_ROOT=$(cd "$(dirname "$0")" && pwd)

TMP_BASE="${TMPDIR:-/tmp}"
if [ ! -w "$TMP_BASE" ]; then
    TMP_BASE="$REPO_ROOT"
fi

TMP_ROOT=$(mktemp -d "$TMP_BASE/pniapp-test.XXXXXXXXXX")
cleanup() {
    rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

REMOTE="$TMP_ROOT/remote.git"
WORK="$TMP_ROOT/work"
BACKUP="$TMP_ROOT/backup"

mkdir -p "$WORK"

git init --bare "$REMOTE" >/dev/null

git init "$WORK" >/dev/null
cd "$WORK"

git config user.email "test@example.com"
git config user.name "Test Runner"

git checkout -b main >/dev/null

touch README.md
git add README.md
git commit -m "init" >/dev/null

git remote add origin "$REMOTE"

git push -u origin main >/dev/null

cp "$REPO_ROOT/openNotes.sh" "$WORK/openNotes.sh"
cp "$REPO_ROOT/closeNotes.sh" "$WORK/closeNotes.sh"
chmod +x "$WORK/openNotes.sh" "$WORK/closeNotes.sh"

printf 'test-pass' > "$WORK/password.txt"

mkdir -p "$WORK/test-notes/subdir"
cat <<'NOTE' > "$WORK/test-notes/note1.txt"
Hello notes
Line two
NOTE

echo "Another file" > "$WORK/test-notes/subdir/note2.txt"

cp -a "$WORK/test-notes" "$BACKUP"

NOTES_DIR=./test-notes ./closeNotes.sh >/dev/null

if [ ! -f "$WORK/compressed.zip.001" ]; then
    echo "Archive not created" >&2
    exit 1
fi

if 7z x "$WORK/compressed.zip.001" -o"$TMP_ROOT/wrong" -pwrongpass >/dev/null 2>&1; then
    echo "Archive decrypted with wrong password" >&2
    exit 1
fi

rm -rf "$WORK/test-notes"

NOTES_DIR=./test-notes ./openNotes.sh >/dev/null

if [ ! -d "$WORK/test-notes" ]; then
    echo "Notes not restored" >&2
    exit 1
fi

if ! diff -r "$BACKUP" "$WORK/test-notes" >/dev/null; then
    echo "Restored notes do not match original" >&2
    exit 1
fi

echo "Test passed"
