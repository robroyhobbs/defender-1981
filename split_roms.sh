#!/bin/bash
dd if=defender.bin of=web/roms/defend.1 bs=2048 count=1
dd if=defender.bin of=web/roms/defend.2 bs=2048 count=1 skip=1
dd if=defender.bin of=web/roms/defend.3 bs=2048 count=1 skip=2
dd if=defender.bin of=web/roms/defend.4 bs=2048 count=1 skip=3
dd if=defender.bin of=web/roms/defend.6 bs=2048 count=1 skip=4
dd if=defender.bin of=web/roms/defend.7 bs=2048 count=1 skip=5
dd if=defender.bin of=web/roms/defend.8 bs=2048 count=1 skip=6
dd if=defender.bin of=web/roms/defend.9 bs=2048 count=1 skip=7
dd if=defender.bin of=web/roms/defend.10 bs=2048 count=1 skip=8
dd if=defender.bin of=web/roms/defend.11 bs=2048 count=1 skip=9
dd if=defender.bin of=web/roms/defend.12 bs=2048 count=1 skip=10 