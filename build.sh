#!/bin/bash

# MatrixLocker Build Script
# This script builds the MatrixLocker macOS application

set -e

echo "🚀 Building MatrixLocker..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker clean

# Build the project
echo "🔨 Building project..."
xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker -configuration Release build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ MatrixLocker built successfully!"
    echo "📁 Application can be found in: build/Release/MatrixLocker.app"
    echo ""
    echo "🔧 To run the application:"
    echo "   1. Open Finder and navigate to the build/Release folder"
    echo "   2. Double-click MatrixLocker.app"
    echo "   3. Or run from Terminal: open build/Release/MatrixLocker.app"
    echo ""
    echo "⚙️ First-time setup:"
    echo "   - Configure inactivity timeout in General settings"
    echo "   - Set your preferred Matrix color"
    echo "   - Enable 'Launch at Login' if desired"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi
