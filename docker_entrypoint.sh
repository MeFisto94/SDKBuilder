#!/bin/sh
echo "Welcome to the jMonkeyEngine SDK Docker Container Build Infrastructure"


if [ "x$BUILD_X64" = "x" ]; then
    export BUILD_X64=true
fi

if [ "x$BUILD_X86" = "x" ]; then
    export BUILD_X86=true
fi

if [ "x$BUILD_OTHER" = "x" ]; then
    export BUILD_OTHER=true
fi

if [ "x$TRAVIS_TAG" != "x" ]; then
    BRANCH="$TRAVIS_TAG"
elif [ "x$BRANCH" = "x" ]; then
    BRANCH="master"
fi

echo "Downloading the SDK...."
git clone https://github.com/jMonkeyEngine/sdk
cd sdk

if [ "$AUTOUPDATE" = "true" ] || [ "$AUTOUPDATE_SDK" = "true" ]; then
    git pull && git checkout $BRANCH
fi

if [ "$AUTOUPDATE" = "true" ] || [ "$AUTOUPDATE_ENGINE" = "true" ]; then
    rm -rf engine/
fi

echo "Building the Engine...."
./build_engine.sh
echo "Patching the Engine Artifacts...."
./fix_engine.sh
echo "Building the SDK itself...."
./gradlew buildSdk
echo "Patching the JDK Downloader"
cd jdks && patch -N < ../../download-jdks.patch
echo "Downloading the JDKs...."
./download-jdks.sh && rm -rf local/*/{downloads,linux-i586,linux-x64,windows-i586,windows-x64} && cd ../
# ant -Dstorepass="$NBM_SIGN_PASS" -Dpack200.enabled=true set-spec-version build-installers unset-spec-version | awk '{printf("."); fflush(stdout)}'
ant -Dpack200.enabled=true set-spec-version build-installers unset-spec-version | awk '{printf(".");fflush(stdout)}'
mv dist/* /dist
cd ../
