org 0x500
bits 16
cpu 8086

LINE_SIZE equ 40
CODE_START equ 0x2000
MAX_CODEOF equ 0xA000
VAR_OFFSET equ 0xB000
GOSUB_SPSP equ 0x2000
mov ax,0x03
int 0x10

mov ax,0x0500
int 0x20

xor bx,bx
mov ds,bx
mov es,bx
mov ss,bx

cli
mov word [0x1b*4],ctrlc
mov word [0x1b*4+2],cs
sti

mov sp,0xFE00
mov si,intro
call __print

cld
mov di,CODE_START
mov si,CODE_START
.m:
	xor al,al
	stosb
	cmp di,MAX_CODEOF
	je _start
	jmp .m

_start:
	mov ax,0x0e3e
	int 0x10
	mov si,cmd
	call readln
	mov si,cmd
	cmp byte [si],0x00
	je _start
	call getnumb
	cmp dx,0x00
	je .iti
.done0:
	call ts
	mov ax,LINE_SIZE
	mul dx
	add ax,CODE_START
	mov di,ax
	mov cx,LINE_SIZE
	rep movsb
	mov di,cmd
	jmp _start
.iti:
	call exec
	jmp _start

clr:
	mov di,CODE_START
.main:
	mov byte [di],0x00
	inc di
	cmp di,0xFFFF
 	jne .main
 	ret

getnumb:
	xor bx,bx
	xor ch,ch
.loop0:
	lodsb
	cmp al,'$'
	je variable
	cmp al,'0'
	jl .done
	cmp al,'9'
	jg .done
	sub al,'0'
	mov cl,al
	mov ax,0x0a
	mul bx
	mov bx,ax
	add bx,cx
	jmp .loop0
.done:
	dec si
	mov dx,bx
	ret


readln:
	xor cx,cx
.m:
	xor ax,ax
	int 0x16
	cmp al,0x08
	je .back
		cmp ah,0x0e
		je .back
	cmp al,0x0d
	je .enter
	mov ah,0x0e
	int 0x10
	mov [si],al
		inc si
	inc cx
	jmp .m
.back:
	cmp cx,0x00
	je .m
	dec cx
	dec si
	mov ax,0x0e08
	int 0x10
	mov ax,0x0e20
	int 0x10
	mov ax,0x0e08
	int 0x10
	jmp .m
.enter:
	mov ax,0x0e0d
	int 0x10
	mov ax,0x0e0a
	int 0x10
	mov byte [si],0
	ret


outnumb:
	mov ax,dx
.main:
	xor dx,dx
	mov cx,10
	div cx
	or ax,ax
	push dx
	je .c
	call .main
.c:
	pop ax
	add al,'0'
	push ax
	mov ah,0x0e
	int 0x10
	pop ax
	ret

__print:
	lodsb
	test al,al
	jz .done
	mov ah,0x0e
	int 0x10
	jmp __print
.done:
	ret

pshrt:
	sub si,3
_print_c:
	add si,5
	call ts
.print:
	lodsb
	cmp al,'"'
	je .string
	cmp al,0
	je .done
	cmp al,';'
	je .print
	cmp al,'c'
	je .char
	cmp al,','
	je .print
	dec si
	mov ax,0x0e20
	int 0x10
	call calc
	call outnumb
	jmp .print
.string:
	lodsb
	cmp al,0
	je syntaxerror
	cmp al,'"'
	je .print
.c0:
	mov ah,0x0e
	int 0x10
	jmp .string
.done:
	;cmp byte [si-2],';'
	;je comment
	mov ax,0x0e0a
	int 0x10
	mov ax,0x0e0d
	int 0x10
	ret
.char:
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	cmp dx,0xFF
	jg numbertoobigerror
	mov al,dl
	mov ah,0x0e
	int 0x10
	lodsb
	cmp al,','
	jne syntaxerror
	jmp .print

calc:
	call getnumb
	mov [.temp0],dx
.loop0:
	lodsb
	cmp al,0
	je comment
	cmp al,','
	je comment
	cmp al,'='
	je comment
	cmp al,' '
	je .loop0
	cmp al,'+'
	je .add_
	cmp al,'-'
	je .sub_
	cmp al,'*'
	je .mul_
	jmp syntaxerror
.add_:
	push si
	call getnumb
	pop ax
	cmp si,ax
	je syntaxerror
	add dx,[.temp0]
	mov [.temp0],dx
	jmp .loop0
.sub_:
	push si
	call getnumb
	pop ax
	cmp si,ax
	je syntaxerror
	sub [.temp0],dx
	mov dx,[.temp0]
	jmp .loop0
.mul_:
	push si
	call getnumb
	pop ax
	cmp si,ax
	je syntaxerror
	mov ax,[.temp0]
	mul dx
	mov [.temp0],ax
	mov dx,ax
	jmp .loop0

.temp0: dw 0x00


variable:
	cmp byte [si],'$'
	je syntaxerror
	push si
	call getnumb
	pop ax
	cmp si,ax
	je syntaxerror	
	mov bx,dx
	add bx,VAR_OFFSET
	jo memoryerror
	mov dx,[bx]
	ret

memoryerror:
	mov si,nomem
	call __print
	jmp _start
syntaxerror:
	mov si,error
	call __print
	add sp,0x04
	jmp _start

ts:
.loop0:
	lodsb
	cmp al,' '
	jne .done0
	jmp .loop0
.done0:
	dec si
	ret

fwtu:
	push si
.main:
	lodsb
	cmp al,0
	je .done
	cmp al,' '
	je .done
	cmp al,'a'
	jl .main
	cmp al,'z'
	jg .main
	sub byte [si-1],0x20 
	jmp .main
.done:
	pop si
	ret

exec:
	call fwtu
	mov ah,0x01
	int 0x16
	cmp ax,0x2e03
	je break
	call ts
	cmp byte [si],0x00
	je comment
	mov di,table
	xor ax,ax
.loop1:
	mov al,[di]
	xor cx,cx
	mov cx,ax
	inc di
	push di
	push si
	repe cmpsb
	pop si
	pop di
	jne .next
	xor ah,ah
	add di,ax
	mov dx,[di]
	jmp dx
.next:
	xor ah,ah
	add di,ax
	add di,2
	cmp byte [di], 0
	je syntaxerror
	jmp .loop1

break:
	xor ax,ax
	int 0x16
	mov si,ctrlc
	call __print
	jmp _start


var:
	add si,0x03
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	mov [.loc],dx
	call ts
	lodsb
	cmp al,'='
	jne syntaxerror
	call ts
	call calc
	mov bx,[.loc]
	add bx,VAR_OFFSET
	jo memoryerror
	mov [bx],dx
	ret
.loc: dw 0x0000
ishrt:
	sub si,0x03
input:
	add si,0x05
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	lodsb
	cmp al,';'
	jne .n0
	mov ah,';'
	lodsb
.n0:
	cmp al,0
	jne syntaxerror
	mov [.loc],dx
	cmp ah,';'
	je .n1
	mov si,inmrk
	call __print
.n1:
	mov si,cmd
	call readln
	mov si,cmd
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov bx,[.loc]
	add bx,VAR_OFFSET
	jo memoryerror
	mov [bx],dx
	ret

.loc: dw 0x0000

if:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov [.first],dx
	call ts
	cmp word [si],0x3d3d ; ==
	je .cmpequ
	cmp word [si],0x3d21 ; !=
	je .cmpnotequ
	cmp byte [si],0x3c ; <
	je .cmpgrt
	cmp byte [si],0x3e ; >
	je .cmplow
	jmp syntaxerror
.cmplow:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov ax,[.first]
	cmp dx,ax
	jg comment
	call ts
	jmp exec
.cmpgrt:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov ax,[.first]
	cmp dx,ax
	jl comment
	call ts
	jmp exec
.cmpequ:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov ax,[.first]
	cmp dx,ax
	jne comment
	call ts
	jmp exec

.cmpnotequ:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	mov ax,[.first]
	cmp dx,ax
	je comment
	call ts
	jmp exec

.first: dw 0x00

rnd:
	add si,4
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	cmp byte [si],0x00
	jne syntaxerror
comment:
	ret
_inc:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	cmp byte [si],0
	jne syntaxerror
	mov bx,dx
	add bx,VAR_OFFSET
	jo memoryerror
	inc word [bx]
	ret

_dec:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	cmp byte [si],0
	jne syntaxerror
	mov bx,dx
	add bx,VAR_OFFSET
	jo memoryerror
	dec word [bx]
	ret

instr:
	add si,5
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	mov si,dx
	add si,VAR_OFFSET
	jo memoryerror
	call readln
	ret

cls:
	mov ax,0x03
	int 0x10
	ret

list:
	add si,0x04
	call ts
	cmp byte [si],0x00
	je .here
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	mov [.d],dx
	mov ax,LINE_SIZE
	mul dx
	add ax,CODE_START
	mov di,ax
	cmp byte [di],0
	je _start
	mov dx,[.d]
	call outnumb
	mov ax,0x0e20
	int 0x10
	mov si,di
	call __print
	mov si,endln
	call __print
	jmp _start
.here:
	mov di,CODE_START
.loop0:
	cmp di,MAX_CODEOF
	jl _start
	cmp byte [di],0x20
	jl .next

	mov ax,di
	xor dx,dx
	sub ax,CODE_START
	mov cx,LINE_SIZE
	div cx
	mov dx,ax
	call outnumb
	mov ax,0x0e20
	int 0x10

	push di
	mov si,di
	call __print
	pop di
	mov si,endln
	call __print
.next:
	add di,LINE_SIZE
	jmp .loop0

.d: dw 0x0000

goto:
	add si,0x05
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	mov ax,LINE_SIZE
	mul dx
	add ax,CODE_START
	mov [nxtip],ax
	ret

continue:
	mov si,[nxtip]
	ret

run:
	mov ax,CODE_START
	mov si,ax
.loop0:
	cmp si,MAX_CODEOF
	jl _start
	mov [nxtip],si
	add word [nxtip],LINE_SIZE
	call exec
	mov si,[nxtip]
	jmp .loop0

gosub:
	add si,0x05
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror

	mov [.oldsp],sp
	mov bx,[subsp]
	mov sp,[bx]
	push word [nxtip]
	mov [bx],sp
	mov sp,[.oldsp]

	mov ax,LINE_SIZE
	mul dx
	add ax,CODE_START
	mov [nxtip],ax
	ret

.oldsp: dw 0x0000

return:
	mov [gosub.oldsp],sp
	mov bx,[subsp]
	mov sp,[bx]
	pop word [nxtip]
	mov [bx],sp
	mov sp,[gosub.oldsp]
	ret

xy:
	add si,0x02
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	cmp dx,79
	jg syntaxerror
	mov [.x],dl
	call ts
	cmp byte [si],','
	jne syntaxerror
	inc si
	call ts
	push si
	call getnumb
	pop ax
	cmp ax,si
	je syntaxerror
	cmp dx,24
	jg syntaxerror
	mov ah,0x02
	xor bh,bh
	mov dh,dl
	mov dl,[.x]
	int 0x10
	ret

.x: db 0x00

numbertoobigerror:
	mov si,bnerr
	call __print
	jmp _start

table:
	db 6,"PRINT "
	dw _print_c
	db 4,"REM "
	dw comment
	db 4,"VAR "
	dw var
	db 6,"INPUT "
	dw input
	db 5,"STOP",0
	dw _start
	db 3,"IF "
	dw if
	db 4,"RND "
	dw rnd
	db 2,"++"
	dw _inc
	db 2,"--"
	dw _dec
	db 6,"INSTR "
	dw instr
	db 4,"CLS",0
	dw cls
	db 4,"NEW",0
	dw clr
	db 4,"LIST"
	dw list
	db 5,"GOTO "
	dw goto
	db 5,"BACK",0
	dw continue
	db 4,"RUN",0
	dw run
	db 6,"GOSUB "
	dw gosub
	db 7,"RETURN",0
	dw return
	db 3,"XY "
	dw xy
	db 4,"PTR "
	dw var
	db 2,"? "
	dw pshrt
	db 2,"IN"
	dw ishrt
	db 0

bnerr: db "?Number too big error",13,10,0
inmrk: db "? ",0
nomem: db "?Memory error",13,10,0
ctrlc: db "^C",13,10,0
error: db "?Syntax error"
endln: db 13,10,0
intro: db 13,10," Luftkatze's Standalone BASIC v1.15 | 3",13,10," 2022, Luftkatze   github.com/LuftkatzeBASIC",13,10,10,0
nxtip: dw CODE_START
subsp: dw GOSUB_SPSP
times (2048-($-$$)) db 0
cmd equ $
