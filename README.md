# MCS2000SL Bare Metal Floppy Loader

A bare-metal toolchain and loader for the SUN MCS2000SL automotive analyzer, allowing you to compile and run your own Motorola 68k programs from a custom floppy image.

## Overview

This project reverse engineers the SUN MCS2000SL boot ROM and creates custom floppy images that the device will boot and execute.  
It automates the entire process from compiling C code to generating a bootable floppy image.

## Features

- Compile Motorola 68k C code with `m68k-elf-gcc`
- Convert ELF to raw binary
- Patch a floppy header with the correct sector count for the boot ROM
- Build a full floppy image ready to write to disk

## Requirements

- `m68k-elf-gcc` toolchain  
- `m68k-elf-objcopy`  
- `dd`, `rm`, `stat` on a Unix-like system  
- A SUN MCS2000SL or compatible environment to run the floppy

## Usage

1. Write your C code in the `src/` directory.
2. Run `make` to compile and build `build/floppy.img`.
3. Write `build/floppy.img` to a physical floppy disk or emulator.
4. Boot the MCS2000SL from your custom floppy!

```sh
make
