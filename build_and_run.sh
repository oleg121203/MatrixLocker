#!/bin/bash

# MatrixLocker Quick Build & Run Script
# Usage: ./build_and_run.sh [clean]

set -e  # Exit on any error

PROJECT_NAME="MatrixLocker"
PROJECT_DIR="/Users/dev/Documents/NIMDA/MATRIX"
BUILD_OUTPUT="/Users/dev/Library/Developer/Xcode/DerivedData"

echo "🔨 Building $PROJECT_NAME..."

cd "$PROJECT_DIR"

# Check if clean build is requested
if [ "$1" == "clean" ]; then
    echo "🧹 Performing clean build..."
    xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" clean build
else
    echo "🔄 Performing incremental build..."
    xcodebuild -project "$PROJECT_NAME.xcodeproj" -scheme "$PROJECT_NAME" build
fi

if [ $? -eq 0 ]; then
    echo "✅ Build succeeded!"
    
    # Find the built app
    APP_PATH=$(find "$BUILD_OUTPUT" -name "$PROJECT_NAME.app" -path "*/Debug/*" | head -1)
    
    if [ -n "$APP_PATH" ]; then
        echo "🚀 Launching $PROJECT_NAME..."
        echo "📍 App location: $APP_PATH"
        open "$APP_PATH"
    else
        echo "❌ Could not find built app"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
