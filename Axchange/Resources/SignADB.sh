#!/bin/zsh

set -e
set -o pipefail

cd "$(dirname "$0")"

APP_PATH="$CODESIGNING_FOLDER_PATH"
cp -f ./adb "$APP_PATH/Contents/MacOS/adb"
