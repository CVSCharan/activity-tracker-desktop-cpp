#!/usr/bin/env bash
# ==============================================================================
# CVS Activity Tracker — macOS Build & Deployment Script
# Supports both Debug and Release modes:
#   ./build-macos.sh          -> Builds Release and runs macdeployqt
#   ./build-macos.sh Debug    -> Builds Debug bundle
# ==============================================================================
set -e

cd "$(dirname "$0")"

CONFIG="${1:-Release}"
BUILD_DIR="build"

echo "======================================================"
echo "   CVS Activity Tracker - macOS Build ($CONFIG)"
echo "======================================================"

# Automatically detect Homebrew Qt6 if CMAKE_PREFIX_PATH is not set
if [ -z "$CMAKE_PREFIX_PATH" ]; then
    if command -v brew &> /dev/null; then
        QT6_PATH="$(brew --prefix qt6 2>/dev/null || true)"
        if [ -n "$QT6_PATH" ] && [ -d "$QT6_PATH" ]; then
            export CMAKE_PREFIX_PATH="$QT6_PATH"
            export PATH="$QT6_PATH/bin:$PATH"
            echo "Detected Homebrew Qt 6: $QT6_PATH"
        fi
    elif [ -d "$HOME/Qt/6.9.3/macos" ]; then
        export CMAKE_PREFIX_PATH="$HOME/Qt/6.9.3/macos"
        export PATH="$HOME/Qt/6.9.3/macos/bin:$PATH"
        echo "Detected Official Qt 6: $CMAKE_PREFIX_PATH"
    fi
fi

echo "[1/3] Configuring CMake..."
cmake -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$CONFIG" \
    ${CMAKE_PREFIX_PATH:+-DCMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH"}

echo "[2/3] Compiling Target ActivityTracker ($CONFIG)..."
cmake --build "$BUILD_DIR" --config "$CONFIG" --target ActivityTracker

if [ "$CONFIG" = "Release" ]; then
    echo "[3/3] Deploying frameworks with macdeployqt..."
    if command -v macdeployqt &> /dev/null; then
        macdeployqt "$BUILD_DIR/ActivityTracker.app" -qmldir=qml
        echo ""
        echo "======================================================"
        echo "[SUCCESS] macOS Standalone Bundle Ready!"
        echo "Location: $(pwd)/$BUILD_DIR/ActivityTracker.app"
        echo "======================================================"
    else
        echo "[WARNING] macdeployqt not in PATH. Raw bundle at $BUILD_DIR/ActivityTracker.app"
    fi
else
    echo "======================================================"
    echo "[SUCCESS] macOS Debug Bundle Ready at $BUILD_DIR/ActivityTracker.app"
    echo "======================================================"
fi

