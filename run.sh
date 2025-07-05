#!/bin/bash

# Unified script for building, running, and managing the MatrixLocker project.
set -e

# --- Configuration ---
PROJECT_NAME="MatrixLocker"
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd)
XCODE_PROJECT="$PROJECT_DIR/$PROJECT_NAME.xcodeproj"
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"

# --- Helper Functions ---
print_usage() {
    echo "Usage: ./run.sh [command]"
    echo ""
    echo "Commands:"
    echo "  run (default)   Builds and launches the application."
    echo "  build           Builds the application without launching."
    echo "  clean           Cleans the build directory and rebuilds."
    echo "  xcode           Opens the project in Xcode."
    echo "  help            Displays this help message."
    echo ""
    echo "Example: ./run.sh clean"
}

build_project() {
    local action="$1" # "build" or "clean build"
    echo "🚀 Starting build ($action)..."
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode command line tools are not installed. Please install Xcode."
        exit 1
    fi
    xcodebuild -project "$XCODE_PROJECT" -scheme "$PROJECT_NAME" -configuration Debug $action
    if [ $? -ne 0 ]; then
        echo "❌ Build failed. Please check the output for errors."
        exit 1
    fi
    echo "✅ Build successful!"
}

run_app() {
    echo "🔍 Finding built application..."
    # Find the most recently built .app file in DerivedData
    APP_PATH=$(find "$DERIVED_DATA_PATH" -name "$PROJECT_NAME.app" -path "*/Build/Products/Debug/*" -print0 | xargs -0 ls -td | head -n 1)

    if [ -d "$APP_PATH" ]; then
        echo "🚀 Launching $PROJECT_NAME from: $APP_PATH"
        open "$APP_PATH"
    else
        echo "❌ Could not find the built application. Please run the build command first."
        exit 1
    fi
}

# --- Main Logic ---
COMMAND=${1:-run} # Default to 'run' if no command is provided

case "$COMMAND" in
    run)
        build_project "build"
        run_app
        ;;
    build)
        build_project "build"
        ;;
    clean)
        echo "🧹 Cleaning project..."
        build_project "clean build"
        ;;
    xcode)
        echo "🧑‍💻 Opening project in Xcode..."
        open "$XCODE_PROJECT"
        ;;
    help)
        print_usage
        ;;
    *)
        echo "❌ Unknown command: $COMMAND"
        print_usage
        exit 1
        ;;
esac

echo "✅ Done."
