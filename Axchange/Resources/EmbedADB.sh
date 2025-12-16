#!/bin/zsh

set -e
set -o pipefail

echo "    EXPANDED_CODE_SIGN_IDENTITY: $EXPANDED_CODE_SIGN_IDENTITY"
echo "    EXPANDED_CODE_SIGN_IDENTITY_NAME: $EXPANDED_CODE_SIGN_IDENTITY_NAME"
echo "    CODESIGNING_FOLDER_PATH: $CODESIGNING_FOLDER_PATH"

cd "$(dirname "$0")"
ENTITLEMENT_PATH="$(pwd)/Entitlements-Subprocess.entitlements"

echo "[*] using entitlements: $ENTITLEMENT_PATH"

APP_PATH="$CODESIGNING_FOLDER_PATH"
cp -f ./adb "$APP_PATH/Contents/MacOS/adb"

cd "$APP_PATH/Contents/MacOS"
codesign --force --deep --sign $EXPANDED_CODE_SIGN_IDENTITY \
    --entitlements $ENTITLEMENT_PATH \
    -o runtime \
    ./adb

echo "[*] done $0"
