global start
extern long_mode_start

section .text
bits 32 ; Specify 32-bit instruction set
start:
    ; esp register to determine current stack frame addr
    mov esp, stack_top

    call check_multiboot
    call check_cpuid
    call check_long_mode

    call setup_page_tables
    call enable_paging

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:long_mode_start
    
    ; Halt the processor
    hlt

check_multiboot:
    cmp eax, 036d76289
    jne .no_mulitboot
    ret

.no_mulitboot:
    mov al, "M"; error code into al register, M for multiboot
    jmp error

check_cpuid:
    pushfd ; push flag register onto stack
    pop eax ; popping off the stack into eax register
    move ecx, eax ; copy made in ecx register
    xor eax, 1 << 21 ; flip bit 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cupid
    ret

.no_cupid
    mov al, "C" ; error code into al register, C for cpuid
    jmp error


check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    move eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode

    ret

.no_long_mode
    mov al, "L"
    jmp error

; subroutine to set up page tables; identity mapping
setup_page_tables:
    mov eax, page_table_l3
    or eax, 0b11 ; present, writable
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11 ; present, writable
    mov [page_table_l3], eax

    mov ecx, 0 ; counter in for loop
.loop:
    mov eax, 0x200000 ; 2Mib
    mul ecx
    or eax, 0b10000011 ; present, writable, huge page
    mov [page_table_l2 + ecx * 8], eax

    inc ecx ; increment counter
    cmp ecx, 512 ; checks if the whole table is mapped
    jne .loop ; if not, continue

    ret

enable_paging:
    ; pass page table location to cpu
    mov eax, page_table_l4
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; enable long mode
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    move eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

error:
    ; print "ERR: X" where X is the error code
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

; stack storing function call variables with local function variables and return mem addr
section .bss
align 4096 ; each page table is 4 kilobytes
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

; enter 64 bit mode
section .rodata
gdt64:
    dq 0 ; zero entry

.code_segment: equ $ - gdt64
    dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53) ; code segment

.pointer:
    dw $ - gdt64 - 1
    dq gdt64
