mov ah, 0x0e
mov dx, 25
mov cx, 0
mov al, 65 + 32; print 'a'
int 0x10

loop: 
    inc al
    cmp cx, dx
    je $
    sub al, 32
    int 0x10
    inc cx

    inc al
    cmp cx, dx
    je $
    add al, 32
    int 0x10
    inc cx

    jmp loop ;loop


jmp $ ;ef fd ff

times 510 - ($ - $$) db 0; $$ is beginning of current section; $ is current address
db 0x55, 0xaa