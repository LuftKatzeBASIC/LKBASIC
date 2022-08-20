org 0x7c00
cpu 8086
bits 16

mov [0x7e00],dx

int 0x12
cmp ax,64
jl nomem

loop0:
	xor ax,ax
	int 0x13
	mov ax,0x0204
	xor bx,bx
	mov es,bx
	mov bx,0x500
	mov cx,0x0002
	mov dx,[0x7e00]
	int 0x13
	jc loop0
	jmp 0x500

nomem:
	mov si,nomemory
	call __print
	xor dx,dx
	int 0x19

__print:
	lodsb
	test al,al
	jz .done
	mov ah,0x0e
	int 0x10
	jmp __print
.done:
	ret

nomemory: db "LK-BASIC requires 64kB of memory.",13,10,0

times (510-($-$$)) db 0
dw 0xaa55
