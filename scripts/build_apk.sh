#!/bin/bash
set -e

BUILD_VARIANT=${1:-debug}
APP_NAME=${2:-ClipBoardVault}

echo "=========================================="
echo "📱 Anti-Gravity APK Builder Engine"
echo "Variant: ${BUILD_VARIANT}"
echo "App Name: ${APP_NAME}"
echo "=========================================="

mkdir -p build/outputs/apk/${BUILD_VARIANT}

if [ -f "./gradlew" ]; then
    echo "🔨 Found Gradle Wrapper. Building Signed Android APK..."
    chmod +x gradlew
    ./gradlew assembleDebug
elif [ -f "./index.html" ]; then
    echo "🌐 Found Single Page Web App (index.html). Packaging into Native Android APK via Capacitor..."
    
    # Prepare web assets directory
    mkdir -p www
    cp -r index.html www/ 2>/dev/null || true
    cp -r assets www/ 2>/dev/null || true
    cp -r css www/ 2>/dev/null || true
    cp -r js www/ 2>/dev/null || true
    
    # Initialize Capacitor project with www web-dir
    npm init -y
    npm install @capacitor/core @capacitor/cli @capacitor/android
    
    npx cap init "${APP_NAME}" "com.antigravity.vault" --web-dir "www"
    npx cap add android
    npx cap sync android
    
    echo "🔨 Building Signed Android APK with Gradle..."
    cd android
    chmod +x gradlew
    # Build assembleDebug so APK is automatically signed with debug keystore
    ./gradlew assembleDebug
    cd ..
    
    # Copy signed debug build artifact (excluding unsigned)
    FOUND_APK=$(find android/app/build/outputs/apk -name "*debug*.apk" -o -name "app-*.apk" | grep -v "unsigned" | head -n 1)
    if [ -z "${FOUND_APK}" ]; then
        FOUND_APK=$(find android/app/build/outputs/apk -name "*.apk" | grep -v "unsigned" | head -n 1)
    fi
    
    if [ -n "${FOUND_APK}" ]; then
        cp "${FOUND_APK}" "build/outputs/apk/${BUILD_VARIANT}/${APP_NAME}.apk"
        cp "${FOUND_APK}" "build/outputs/apk/${BUILD_VARIANT}/${APP_NAME}-${BUILD_VARIANT}.apk"
        echo "✅ Signed APK generated successfully: build/outputs/apk/${BUILD_VARIANT}/${APP_NAME}.apk"
    fi
else
    echo "📦 Custom Build Execution Strategy..."
    if [ -f "./build.sh" ]; then
        chmod +x ./build.sh
        ./build.sh ${BUILD_VARIANT}
    fi
fi

echo "✅ Build script execution complete."
