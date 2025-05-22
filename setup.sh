#!/bin/bash

# Make sure directories exist
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/animations

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome 