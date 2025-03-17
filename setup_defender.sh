#!/bin/bash

# Create directories
mkdir -p ~/.mame/roms/defender
mkdir -p web/roms

echo "Downloading Defender ROM files..."

# Download ROM files from a different source
curl -L "https://archive.org/download/mame-roms-collection/mame-roms-collection/defender.zip" -o "web/roms/defender.zip"

# Unzip the ROM files
cd web/roms
unzip defender.zip
cd ../..

# Copy ROM files to MAME directory
cp web/roms/defender/* ~/.mame/roms/defender/

echo "ROM files downloaded and installed. You can now:"
echo "1. Run the game directly with: mame defender"
echo "2. Start the web server with: cd web && python3 -m http.server 8000" 