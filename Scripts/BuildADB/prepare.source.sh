#!/bin/zsh

set -e
set -o pipefail

source $(dirname $0)/define.sh

PATCHES_DIR=$(realpath $(dirname $0)/patches)

# android.googlesource.com resets connections now and then, retry transfers
retry() {
    local attempt=1
    while ! "$@"; do
        if [ $attempt -ge 3 ]; then
            echo "[-] failed after $attempt attempts: $@"
            return 1
        fi
        attempt=$((attempt + 1))
        echo "[!] retrying ($attempt/3): $@"
        sleep 5
    done
}

TARGET_DIR=$1
if [ -z $TARGET_DIR ]; then
    echo "[-] target directory is not specified"
    exit 1
fi
TARGET_DIR=$(realpath $TARGET_DIR)
cd $TARGET_DIR

for source in $SOURCE_LIST; do
    IFS='@' read -r -A source_info <<<$source
    url=${source_info[1]}
    version=${source_info[2]}
    name=$(basename $url)

    echo "[+] downloading to $name @ $version"

    if [ -d $name ]; then
        echo "[i] $name already exists, fetching updates"
        retry git -C $name fetch --tags
    else
        echo "[+] cloning $name"
        retry git clone $url $name
    fi

    pushd $name >/dev/null
    git clean -fdx
    git reset --hard

    if [ $version = '*' ]; then
        echo "[i] skip checkout"
    else
        echo "[+] checking out $version"
        git checkout $version
    fi

    # force keeps the submodules pristine so patches apply cleanly on re-run
    retry git submodule update --init --recursive --checkout --force

    # android-tools applies patches/<vendor>/*.patch with git am at configure
    # time, ours slot in through the same mechanism
    if [ $name = 'android-tools' ]; then
        for patch_file in $PATCHES_DIR/adb/*.patch; do
            echo "[+] staging $(basename $patch_file) into patches/adb"
            cp $patch_file patches/adb/
        done
    fi
    popd >/dev/null
done

echo "[+] done $(basename $0)"
