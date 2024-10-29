#!/bin/zsh

source $(dirname $0)/define.sh

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
        echo "[i] $name already exists, skip cloning"
    else
        echo "[+] cloning $name"
        git clone $url $name
    fi

    pushd $name >/dev/null
    git clean -fdx
    git reset --hard
    git submodule update --init --recursive --checkout

    if [ $version = '*' ]; then
        echo "[i] skip checkout"
    else
        echo "[+] checking out $version"
        git checkout $version
    fi
    popd >/dev/null
done

echo "[+] done $(basename $0)"
