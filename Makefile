# Makefile for M68k bare metal floppy image with header

# Tools
CC       := m68k-elf-gcc
OBJCOPY  := m68k-elf-objcopy
DD       := dd
RM       := rm -f
MKDIR    := mkdir -p

# Paths
SRC_DIR     := src
INC_DIR     := header
BUILD_DIR   := build

# Files
SRC         := $(SRC_DIR)/new_main.c $(SRC_DIR)/screen.c
ELF         := $(BUILD_DIR)/main.elf
BIN         := $(BUILD_DIR)/main.bin
HEADER_SRC  := $(INC_DIR)/header.bin   # stays in repo
HEADER      := $(BUILD_DIR)/header.bin # patched copy
FLOPPY      := $(BUILD_DIR)/floppy.img
LINKER      := linker.ld

# Floppy layout
SECTOR_SIZE          := 512
HEADER_OFFSET        := 9216   # 0x2400
PROGRAM_OFFSET       := 18432  # 0x2A00
HEADER_SECTOR_OFFSET := 54     # 0x36

# Compiler / Linker flags
CFLAGS  := -mcpu=68000 -m68000 -nostdlib -nostartfiles -ffreestanding -ffunction-sections -Wall -Wextra -I$(INC_DIR)
LDFLAGS := -T $(LINKER) -e main

all: $(FLOPPY)

# Main floppy image build
$(FLOPPY): $(BIN) $(HEADER)
	@echo "[*] Calculating program size in sectors..."
	$(eval BIN_SIZE := $(shell stat -c%s $(BIN)))
	$(eval SECTOR_COUNT := $(shell echo $$((($(BIN_SIZE) + $(SECTOR_SIZE) - 1)/$(SECTOR_SIZE)))))

	@echo "[*] Patching header with sector count (big-endian: $(SECTOR_COUNT))..."
	printf "%02X%02X" $(shell echo $(SECTOR_COUNT) | awk '{ printf "%d %d", int($$1 / 256), $$1 % 256 }') | \
	xxd -r -p | dd of=$(HEADER) bs=1 seek=$(HEADER_SECTOR_OFFSET) conv=notrunc status=none

	@echo "[*] Creating blank floppy image..."
	$(DD) if=/dev/zero of=$(FLOPPY) bs=512 count=2880 status=none

	@echo "[*] Writing header to offset 0x$(shell printf "%X" $(HEADER_OFFSET))..."
	$(DD) if=$(HEADER) of=$(FLOPPY) bs=1 seek=$(HEADER_OFFSET) conv=notrunc status=none

	@echo "[*] Writing program binary to offset 0x$(shell printf "%X" $(PROGRAM_OFFSET))..."
	$(DD) if=$(BIN) of=$(FLOPPY) bs=1 seek=$(PROGRAM_OFFSET) conv=notrunc status=none
	
	@echo "[+] Build completed successfully!"
	@echo "[+] Final floppy image: $(FLOPPY) — ready to write to your floppy disk"

# Build binary
$(BIN): $(ELF)
	@echo "[*] Converting ELF to binary..."
	$(OBJCOPY) -O binary $(ELF) $(BIN)

# Build ELF
$(ELF): $(SRC) $(LINKER) | $(BUILD_DIR)
	@echo "[*] Compiling and linking..."
	$(CC) $(CFLAGS) -o $(ELF) $(SRC) $(LDFLAGS)

# Copy header from source to build dir
$(HEADER): $(HEADER_SRC) | $(BUILD_DIR)
	cp $(HEADER_SRC) $(HEADER)

# Ensure build dir exists
$(BUILD_DIR):
	$(MKDIR) $(BUILD_DIR)

clean:
	$(RM) -r $(BUILD_DIR)/*
	@echo "[*] Cleaned build artifacts."

.PHONY: all clean
