%define loc 0x1000
%define drive 0x80
%define os_sect 3
%define ftable 0x2000
%define ftabsect 2
[bits 16]
[org 0]

jmp 0x7c0:start
	; bootloader begin
start:
	mov ax,cs
	mov ds,ax
	mov es,ax
	
	call kernel_main


	
	mov ax,loc
	mov es,ax
	mov cl,os_sect
	mov al,2

	call loadsector

	mov ax,ftable
	mov es,ax
	mov cl,ftabsect
	mov al,1
	call loadsector
	
	jmp loc:0000

	; bootloader end
	
kernel_main:
	mov ah,0
	mov al,03h
	int 10h			; setting up video mode
	call cursor_newline
	
	mov si,msg
	call write_string
	
	call start_input
	ret
	
loadsector:
	mov ah,02h
	mov bx,0
	mov ch,0
	mov dh,0
	mov dl,drive
	int 13h
	ret
	
write_char:
	mov ah,09h
	mov bh,0
	mov cx,1
	int 10h
	ret

cursor_pos:
	mov ah,3
	mov bh,0
	int 10h
	ret
	
cursor_next:
	mov ah,2
	mov bh,0
	inc dl
	int 10h
	ret

cursor_prev:
	mov ah,2
	mov bh,0
	dec dl
	int 10h
	ret

waitforkey:
	mov ah,0
	int 16h
	ret
	
start_input:
	call waitforkey
	mov bl,2
	cmp al,13
	je keyboard_enter
	jne input_letter
	
	jmp start_input
	
input_letter:
	call write_char
	call cursor_pos
	call cursor_next
	jmp start_input

keyboard_enter:
	call cursor_newline
	jmp start_input
	
cursor_newline:			; Sets cursor to a new line
	pusha
	call cursor_pos
	mov ah,2
	mov bh,0
	inc dh
	mov dl,0
	int 10h
	popa
	ret
	
reset_color:
	mov bl,9
switch_color:
	cmp bl,14
	je reset_color
	inc bl
	ret
	
write_string:
	mov bl,9
loop: 
	lodsb

	cmp al,0xa
	je string_newline
	jz end

	
	call switch_color
	call write_char
	call cursor_pos
	call cursor_next
	
	jmp loop
end:
	ret

string_newline:
	call cursor_newline
	ret
	
msg db 'Welcome to FantikOS!',0xa,0
debugmsg db 'Debug message here!',0xa,0
	
times 510-($-$$) db 0
dw 0xAA55
