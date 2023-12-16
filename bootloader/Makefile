# Define the nasm assembler and qemu emulator
NASM=nasm
QEMU=qemu-system-x86_64

# Define the source file and output file
SOURCE=boot.asm
OUTPUT=boot.bin

# Rule to assemble the source file
$(OUTPUT): $(SOURCE)
	$(NASM) -f bin $< -o $@

# Rule to run the QEMU emulator with the binary file
run: $(OUTPUT)
	$(QEMU) $<
