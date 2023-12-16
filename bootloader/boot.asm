[org 0x7c00]
mov bx, buffer ;pointer to the first character of the string

inp:
	mov ah, 0
	int 0x16
	cmp al, 13 ; "Enter" key
	je printString
	mov ah, 0x0e
	int 0x10
	mov [bx], al
	inc bx
	jmp inp

printString:
	mov bx, buffer
	mov ah, 0x0e ; TTY mode
	printLoop:
		mov al, [bx]
		cmp al, 0
		je exit
		int 0x10
		inc bx
		jmp printLoop

exit:
    jmp $ ; ef fd ff

buffer:
    times 10 db 0

times 510 - ($ - $$) db 0; $$ is beginning of current section; $ is current address
db 0x55, 0xaa