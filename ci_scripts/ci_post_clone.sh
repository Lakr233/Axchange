#!/bin/zsh

# Xcode Cloud post-clone script.
# Prepares everything the build phases need but is not checked into git:
# - node (Scripts/BuildDocs runs npm/vitepress)
# - cmake (Scripts/BuildADB builds adb and its dependencies)
# - the adb binary itself, built from source into Axchange/Resources/adb

set -e
set -o pipefail

cd "$(dirname "$0")/.."

if ! command -v node >/dev/null 2>&1; then
    echo "[*] installing node"
    brew install node
fi
node --version
npm --version

if ! command -v cmake >/dev/null 2>&1; then
    echo "[*] installing cmake"
    brew install cmake
fi
cmake --version | head -1

echo "[*] building adb from source"
./Scripts/BuildADB/make.sh

echo "[+] done $0"
