#!/bin/bash

# Create a temporary directory for ROM files
mkdir -p ~/.mame/roms/defender

# Copy ROM files to MAME's ROM directory
cp roms/defend.* ~/.mame/roms/defender/

# Launch MAME with Defender
mame defender 