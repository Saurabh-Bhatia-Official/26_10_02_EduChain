#!/bin/bash
set -e

echo "=========================================="
echo " EduChain Flutter Web - Vercel Build Script"
echo "=========================================="

# 1. Resolve project root and Flutter application directory
WORKSPACE_DIR="$(pwd)"
if [ -f "$WORKSPACE_DIR/pubspec.yaml" ]; then
  FLUTTER_APP_DIR="$WORKSPACE_DIR"
elif [ -f "$WORKSPACE_DIR/frontend/pubspec.yaml" ]; then
  FLUTTER_APP_DIR="$WORKSPACE_DIR/frontend"
else
  echo "Error: pubspec.yaml could not be located in $WORKSPACE_DIR or $WORKSPACE_DIR/frontend"
  exit 1
fi

echo "Workspace directory: $WORKSPACE_DIR"
echo "Flutter app directory: $FLUTTER_APP_DIR"

# 2. Check or download Flutter SDK
FLUTTER_SDK_DIR="$WORKSPACE_DIR/.flutter-sdk"

if command -v flutter >/dev/null 2>&1; then
  echo "Using system-installed Flutter: $(which flutter)"
else
  if [ ! -d "$FLUTTER_SDK_DIR" ]; then
    echo "Cloning Flutter SDK (channel: stable, depth: 1)..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_SDK_DIR"
  else
    echo "Found existing Flutter SDK in $FLUTTER_SDK_DIR"
  fi
  export PATH="$FLUTTER_SDK_DIR/bin:$PATH"
fi

# 3. Configure Flutter
echo "Disabling analytics and enabling Web..."
flutter --disable-analytics
flutter config --no-analytics --enable-web

echo "Flutter version:"
flutter --version

# 4. Resolve dependencies and build Web release
cd "$FLUTTER_APP_DIR"
echo "Running flutter pub get..."
flutter pub get

echo "Running flutter build web --release..."
flutter build web --release --base-href "/"

# 5. Ensure output directory is populated for Vercel
# If build took place in frontend/, copy to root build/web as well
if [ "$FLUTTER_APP_DIR" != "$WORKSPACE_DIR" ]; then
  echo "Syncing build output to $WORKSPACE_DIR/build/web..."
  mkdir -p "$WORKSPACE_DIR/build"
  rm -rf "$WORKSPACE_DIR/build/web"
  cp -r "$FLUTTER_APP_DIR/build/web" "$WORKSPACE_DIR/build/web"
fi

echo "=========================================="
echo " Flutter Web Build Completed Successfully!"
echo " Output available at:"
echo " - $FLUTTER_APP_DIR/build/web"
if [ "$FLUTTER_APP_DIR" != "$WORKSPACE_DIR" ]; then
  echo " - $WORKSPACE_DIR/build/web"
fi
echo "=========================================="

