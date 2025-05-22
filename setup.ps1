# Make sure directories exist
if (-not (Test-Path -Path "assets")) {
    New-Item -Path "assets" -ItemType Directory
}
if (-not (Test-Path -Path "assets\images")) {
    New-Item -Path "assets\images" -ItemType Directory
}
if (-not (Test-Path -Path "assets\icons")) {
    New-Item -Path "assets\icons" -ItemType Directory
}
if (-not (Test-Path -Path "assets\animations")) {
    New-Item -Path "assets\animations" -ItemType Directory
}

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome 