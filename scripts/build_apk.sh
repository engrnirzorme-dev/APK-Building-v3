#!/bin/bash
set -e

BUILD_VARIANT=${1:-release}
APP_NAME=${2:-AntigravityApp}

echo "=========================================="
echo "📱 Anti-Gravity APK Builder"
echo "Variant: ${BUILD_VARIANT}"
echo "App Name: ${APP_NAME}"
echo "=========================================="

# Check if Gradle project exists
if [ -f "./gradlew" ]; then
    echo "🔨 Found Gradle Wrapper. Building Android APK..."
    chmod +x gradlew
    if [ "${BUILD_VARIANT}" = "release" ]; then
        ./gradlew assembleRelease
    else
        ./gradlew assembleDebug
    fi
elif command -v antigravity.google &> /dev/null; then
    echo "⚡ Found Antigravity CLI. Invoking build..."
    antigravity.google build apk --${BUILD_VARIANT}
else
    echo "📦 Standard Build Execution Strategy..."
    # Custom build script logic for project sources
    OUTPUT_DIR="build/outputs/apk/${BUILD_VARIANT}"
    mkdir -p "${OUTPUT_DIR}"
    
    if [ -f "./build.sh" ]; then
        chmod +x ./build.sh
        ./build.sh ${BUILD_VARIANT}
    fi
fi

echo "✅ Build script execution complete."
