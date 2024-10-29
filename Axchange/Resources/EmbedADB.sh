#!/bin/zsh

set -e
set -o pipefail

echo "    PROJECT_DIR: $PROJECT_DIR"
echo "    CONFIGURATION: $CONFIGURATION"
echo "    CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY"
echo "    DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM"
echo "    CODESIGNING_FOLDER_PATH: $CODESIGNING_FOLDER_PATH"

cd "$(dirname "$0")"
ENTITLEMENT_PATH="$(pwd)/Entitlements-Subprocess.entitlements"

APP_PATH="$CODESIGNING_FOLDER_PATH"
cp -f ./adb "$APP_PATH/Contents/MacOS/adb"

cd "$APP_PATH/Contents/MacOS"
codesign --force --sign $CODE_SIGN_IDENTITY \
    --entitlements $ENTITLEMENT_PATH \
    -o runtime \
    ./adb

echo "[*] done $0"
