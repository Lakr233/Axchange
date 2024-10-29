#!/bin/zsh

set -e

source $(dirname $0)/define.sh

SCRIPT_PATH=$(dirname $0)
SCRIPT_PATH=$(realpath $SCRIPT_PATH)

BEGIN_TIME=$(date +%s)
echo "========================================"
echo "[*] starting build $BEGIN_TIME"
echo "========================================"

SOURCE_DIR=$1
SDK_PLATFORM=$2
PLATFORM=$3
EFFECTIVE_PLATFORM_NAME=$4
ARCHS=$5
MIN_VERSION=$6
INSTALL_PREFIX=$7

rm -rf "$INSTALL_PREFIX" || true
mkdir -p "$INSTALL_PREFIX" || true

echo "[*] source dir: $SOURCE_DIR"
echo "[*] sdk platform: $SDK_PLATFORM"
echo "[*] platform: $PLATFORM"
echo "[*] effective platform name: $EFFECTIVE_PLATFORM_NAME"
echo "[*] archs: $ARCHS"
echo "[*] min version: $MIN_VERSION"
echo "[*] install prefix: $INSTALL_PREFIX"

DELIVERED_PREFIXS=()

ARCHS_LIST=()
IFS=' ' read -r -A ARCHS_LIST <<<"$ARCHS"
echo "[*] building for ${#ARCHS_LIST[@]} archs" 

ORIGINAL_PATH=$PATH

for ARCH in $ARCHS_LIST; do
    export PREFIX_DIR="$INSTALL_PREFIX.$ARCH"
    export CFLAGS=""
    export MIN_VERSION=""
    export CROSS_TOP="$(xcode-select --print-path)/Platforms/$PLATFORM.platform/Developer"
    export CROSS_SDK="$PLATFORM.sdk"
    export SDKROOT="$CROSS_TOP/SDKs/$CROSS_SDK"
    export CC="$(xcrun --find clang)"
    export CXX="$(xcrun --find clang++)"
    export PATH=$PREFIX_DIR/bin:$ORIGINAL_PATH
    export ARCH=$ARCH

    echo "========================================"
    echo "==> $SDK_PLATFORM $ARCH $EFFECTIVE_PLATFORM_NAME"
    echo "========================================"

    DELIVERED_SOURCE=$PREFIX_DIR.src
    rm -rf $DELIVERED_SOURCE || true
    mkdir -p $DELIVERED_SOURCE
    echo "[+] copying source to temp dir: $DELIVERED_SOURCE"
    mkdir -p $DELIVERED_SOURCE || true
    echo "[*] transferring..."
    pushd $SOURCE_DIR >/dev/null
    tar cf - * | (
        cd $DELIVERED_SOURCE
        tar xf -
    )

    rm -rf "$PREFIX_DIR" || true
    mkdir -p "$PREFIX_DIR" || true

    USE_MIN_VERSION=true
    if [[ "$EFFECTIVE_PLATFORM_NAME" == "MAC_CATALYST_13_1" ]]; then
        export CFLAGS="-target $ARCH-apple-ios13.1-macabi -Wno-overriding-t-option"
    fi
    if [[ "$EFFECTIVE_PLATFORM_NAME" == "VISION_NOT_PRO" ]]; then
        export CFLAGS="-target $ARCH-apple-xros$MIN_VERSION"
        USE_MIN_VERSION=false
    fi
    if [[ "$EFFECTIVE_PLATFORM_NAME" == "VISION_NOT_PRO_SIMULATOR" ]]; then
        export CFLAGS="-target $ARCH-apple-xros$MIN_VERSION-simulator"
        USE_MIN_VERSION=false
    fi

    if [[ "$USE_MIN_VERSION" == "true" ]]; then
        export MIN_VERSION=$MIN_VERSION
    fi

    if [[ ! -z "${CFLAGS}" ]]; then
        echo "    CFLAGS: $CFLAGS"
    fi
    export CFLAGS=$CFLAGS

    pushd $DELIVERED_SOURCE >/dev/null

    for source in $SOURCE_LIST; do
        IFS='@' read -r -A source_info <<<$source
        url=${source_info[1]}
        version=${source_info[2]}
        name=$(basename $url)

        echo "[*] building $name @ $version"
        BUILD_SCRIPT_PATH=$SCRIPT_PATH/build-$name.sh

        if [ -f $BUILD_SCRIPT_PATH ]; then
            echo "[+] running $BUILD_SCRIPT_PATH"
            pushd $DELIVERED_SOURCE/$name >/dev/null
            $BUILD_SCRIPT_PATH
            popd >/dev/null
        else
            echo "[-] $BUILD_SCRIPT_PATH not found"
        fi
    done

    popd >/dev/null

    DELIVERED_PREFIXS+=("$PREFIX_DIR")
done
