#!/bin/zsh

set -e
set -o pipefail

echo "    CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY"
echo "    EXPANDED_CODE_SIGN_IDENTITY_NAME: $EXPANDED_CODE_SIGN_IDENTITY_NAME"
echo "    CODESIGNING_FOLDER_PATH: $CODESIGNING_FOLDER_PATH"

cd "$(dirname "$0")"
ENTITLEMENT_PATH="$(pwd)/Entitlements-Subprocess.entitlements"

APP_PATH="$CODESIGNING_FOLDER_PATH"
cp -f ./adb "$APP_PATH/Contents/MacOS/adb"

if [ -n "$EXPANDED_CODE_SIGN_IDENTITY_NAME" ]; then
    echo "[*] overwrite CODE_SIGN_IDENTITY to $EXPANDED_CODE_SIGN_IDENTITY_NAME"
    CODE_SIGN_IDENTITY="$EXPANDED_CODE_SIGN_IDENTITY_NAME"
fi

cd "$APP_PATH/Contents/MacOS"
codesign --force --sign $CODE_SIGN_IDENTITY \
    --entitlements $ENTITLEMENT_PATH \
    -o runtime \
    ./adb

echo "[*] done $0"
