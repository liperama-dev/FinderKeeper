#!/bin/bash

# Exit on error
set -e

# Configuration
PRODUCT_NAME="FinderKeeper"
BUILD_DIR="build/Release"
DIST_DIR="dist"
APP_PATH="$DIST_DIR/$PRODUCT_NAME.app"

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Build the project
echo "Building $PRODUCT_NAME..."
xcodebuild \
    -scheme "$PRODUCT_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    build

# Create the .app bundle
echo "Creating .app bundle..."
APP_BUNDLE="$BUILD_DIR/Build/Products/Release/$PRODUCT_NAME.app"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: App bundle not found at $APP_BUNDLE"
    exit 1
fi

# Copy to dist directory
cp -R "$APP_BUNDLE" "$DIST_DIR/"

# Create a zip for distribution
ZIP_PATH="$DIST_DIR/$PRODUCT_NAME.zip"
(cd "$DIST_DIR" && zip -r -X "$PRODUCT_NAME.zip" "$PRODUCT_NAME.app")

echo "\n🎉 Build complete!"
echo "App bundle: $APP_PATH"
echo "Distribution zip: $ZIP_PATH"
