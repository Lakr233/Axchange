#!/bin/zsh

set -e
set -o pipefail

echo "    PROJECT_DIR: $PROJECT_DIR"
echo "    CONFIGURATION: $CONFIGURATION"
echo "    CODE_SIGN_IDENTITY: $CODE_SIGN_IDENTITY"
echo "    DEVELOPMENT_TEAM: $DEVELOPMENT_TEAM"

cd "$(dirname "$0")"

codesign --force --sign "$CODE_SIGN_IDENTITY" \
    --entitlements "./Entitlements-Subprocess.entitlements" \
    -o runtime \
    ./adb

echo "[*] done $0"
