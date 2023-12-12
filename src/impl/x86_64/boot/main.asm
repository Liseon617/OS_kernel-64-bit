global start

section .text
bits 32 ; Specify 32-bit instruction set
start:
    ;print 'OK' -- writing to video memory
    mov dword [0xb8000], 0x2f4b2f4f
    ; Halt the processor
    hlt
