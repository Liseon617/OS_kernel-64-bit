mov ah, 0x0e
mov al, 65
int 0x10

mov ah, 0x0e
mov al, 0x41
int 0x10

mov ah, 0x0e
mov al, 0b01000001
int 0x10

jmp $ ;ef fd ff

times 510 - ($ - $$) db 0; $$ is beginning of current section; $ is current address
db 0x55, 0xaa