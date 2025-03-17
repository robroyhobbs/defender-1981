#!/bin/bash

# Create js directory if it doesn't exist
mkdir -p js

# Download JSMESS
echo "Downloading JSMESS..."
curl -L https://github.com/jsmess/jsmess/raw/master/dist/jsmess.js -o js/jsmess.js

# Download JSMESS dependencies
echo "Downloading JSMESS dependencies..."
curl -L https://github.com/jsmess/jsmess/raw/master/dist/jsmess.wasm -o js/jsmess.wasm
curl -L https://github.com/jsmess/jsmess/raw/master/dist/jsmess.data -o js/jsmess.data

echo "Download complete!" 