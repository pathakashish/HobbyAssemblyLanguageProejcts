;Program :- Program to interface mouse.
;Class :- T. E. Computer.		Roll number :- .
;Programmer :- Pathak Ashish Vikas.

.model small
Print macro Msg
	push ax
	push dx
	lea dx, Msg ;Offset of string.
	mov ah, 09h ;09h funtion to display string.
	int 21h
	pop dx
	pop ax
endm
.stack
.data
	InitMouseFailed db 10, 13, 'Cannot initialize mouse!$'
	Right db 'Right $'
	Left db 'Left  $'
	Blank db '      $'
	XCoord db 10, 13, 'X-coordinate : $'
	YCoord db 10, 13, 'Y-coordinate : $'
	ButtonPressed db 10, 13, 'Button Pressed : $'
	PressS db 10, 13, 'Press "S" to show mouse pointer.$'
	PressH db 10, 13, 'Press "H" to hide mouse pointer.$'
	PressQ db 10, 13, 'Press "Q" to exit.$'
.code
	mov ax, @data ;[Initialize
	mov ds, ax ; data segment.]
	mov al, 12h ;640 X 480, 16 color graphics mode.
	call SetVideoMode
	call InitMouse
	call ShowMousePtr
	AGAIN:
		mov bh, 00h
		mov dh, 00h
		mov dl, 00h
		call GoToXY
		Print PressH
		Print PressS
		Print PressQ
		call GetMousePosition
		Print XCoord
		mov ax, cx
		call DisplayNum
		Print YCoord
		mov ax, dx
		call DisplayNum
		Print ButtonPressed
		cmp bx, 0000h
		jne BELOW1
			Print Blank
		BELOW1:
		cmp bx, 0001h
		jne BELOW2
			Print Left
		BELOW2:
		cmp bx, 0002h
		jne BELOW3
			Print Right
		BELOW3:
		call Kbhit
		cmp al, 'h'
		jne BELOW4
			call HideMousePtr
		BELOW4:
		cmp al, 's'
		jne BELOW5
			call ShowMousePtr
		BELOW5:
		cmp al, 'q'
		jne BELOW6
			jmp QUIT
		BELOW6:
		cmp al, 'H'
		jne BELOW7
			call HideMousePtr
		BELOW7:
		cmp al, 'S'
		jne BELOW8
			call ShowMousePtr
		BELOW8:
		cmp al, 'Q'
		jne BELOW9
			jmp QUIT
		BELOW9:
	jmp AGAIN
	QUIT:
	mov al, 03h ; 80 X 25 16 color text mode.
	call SetVideoMode
	mov ah, 4ch ;[Terminate program &
	int 21h ; return to DOS prompt.]

SetVideoMode proc near
;Input :- Code of video mode in AL register.
;Function :- Sets video mode to one specified in al regiter.
;Returns :- Nothing.
	mov ah, 00h ;[00h function to
	int 10h ; graphics mode.]
	ret
SetVideoMode endp

GoToXY proc near
;Input :- CX = X-coordinate, DX = Y-coordinate.
;Function :- Set cursor position.
;Returns :- Nothing.
	mov ah, 02h ;[02h function to
	int 10h ; set cursor position.]
	ret
GoToXY endp

InitMouse proc near
;Input :- Nothing.
;Function :- To initialize mouse.
;Returns :- 00001 in AX register if mouse present & initialized.
	mov ax, 0000h ;[0000h to initialize
	int 33h ; mouse.]
	cmp ax, 0001h
	jne IMEND
		mov al, 03h ;80 X 25, 16 color text mode.
		call SetVideoMode
		Print InitMouseFailed
		mov ah, 4ch ;[Terminate program &
		int 21h ; return to DOS prompt.]
	IMEND:
	ret
InitMouse endp

ShowMousePtr proc near
;Input:- Nothing.
;Function :- Make mouse pointer visible.
;Returns :- Nothing.
	mov ax, 0001h ;[0001h to show
	int 33h ; mouse pointer.]
	ret
ShowMousePtr endp

HideMousePtr proc near
;Input:- Nothing.
;Function :- Make mouse pointer invisible.
;Returns :- Nothing.
	mov ax, 0002h ;[0002h to hide
	int 33h ; mouse pointer.]
	ret
HideMousePtr endp

GetMousePosition proc near
;Input :- Nothing.
;Function :- Get the mouse pointer & buttons position.
;Returns :- Cx = X-coordinate, DX = Y=coordinate & BX = button pressed.
	mov ax, 0003h ;[0003h funtion to get
	int 33h ; mouse position.]
	ret
GetMousePosition endp

Kbhit proc near
;Input :- Nothing.
;Function :- Check is key pressed.
;Returns :- Reset zero flag if key is pressed & AL = 8-bit code of key else set zero flag.
	mov ah, 06h ;[06h function for direct console I/O,
	mov dl, 0ffh ; check if any key pressed(input request).]
	int 21h
	ret
Kbhit endp

DisplayNum proc near
;Input :- 16-bit number to be displayed(in ax register).
;Function :- Print number in ax register.
;Returns :- Nothing.
	push ax
	push cx
	push dx
	mov cx, 0404h
	UP:
		ror ax,cl
		push ax
		and al,0fh
		cmp al,39h
		jbe DOWN
			add al,07h
		DOWN:
		add al,30h
		mov dl,al
		mov ah,02h
		int 21h
		pop ax
		dec ch
	jnz UP
	pop dx
	pop cx
	pop ax
	ret
DisplayNum endp
end