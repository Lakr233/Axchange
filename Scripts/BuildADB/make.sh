#!/bin/zsh

cd $(dirname $0)

SOURCE_DIR="$(pwd)/build_source"
if [ ! -d $SOURCE_DIR ]; then
    mkdir -p $SOURCE_DIR
fi
./prepare.source.sh $SOURCE_DIR

BUILD_DIR="$(pwd)/build"
if [ ! -d $BUILD_DIR ]; then
    mkdir -p $BUILD_DIR
fi

DEST_PREFIX=$BUILD_DIR

./compile.sh $SOURCE_DIR "macosx" "MacOSX" "" "x86_64 arm64" "10.15" "$DEST_PREFIX/macosx"
