#!/bin/zsh

set -e

rm -rf build_googletest || true
mkdir -p build_googletest || true

pushd build_googletest

cmake .. \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_STATIC_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX_DIR \
    -DCMAKE_PREFIX_PATH=$PREFIX_DIR \
    -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF \
    -DCMAKE_OSX_ARCHITECTURES=$ARCH \
    -DCMAKE_OSX_SYSROOT=$SDKROOT \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=$MIN_VERSION \
    -DCMAKE_C_COMPILER="$CC" \
    -DCMAKE_CXX_COMPILER="$CXX"

make -j$(nproc)
make install

popd

echo "========================================"
echo "[*] finished build $(basename $0)"
echo "========================================"

