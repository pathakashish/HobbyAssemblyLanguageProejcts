;Program :- To write device driver for printer.
;Class :- T.E. Computer.	Roll number :- 5.
;Programmer :- Pathak Ashish Vikas.

.model tiny
.code
	org 0000h ;Device driver has origin as zero.

	DeviceHeader:
		dd -1 ;Link to next device driver. Upper two bytes hold offset & lower two bytes hold segment base address.
		dw 0c000h ;Device attribute word.
		dw StrategyRoutine ;It specifies offset of strategy routine.
		dw InterruptRoutine ;It specifies offset of interrupt routine.
		db 'HLLabPrinter' ;Logical name given to device.
	RequestHeaderPtr dd ? ;Pointer to request header, passed by MS-DOS kernel to strategy routine.

	Msg db 10, 13, 'Duplicate driver : EPSON$'

	StrategyRoutine proc far
	;Device driver strategy routine called by MS-DOS kernel with ES:BX = address of request header.
		mov word ptr cs:RequestHeaderPtr, bx ;[Save the,
		mov word ptr cs:RequestHeaderPtr + 2, es ; pointer to request header.]
		ret ;Back to MS-DOS kernel.
	StrategyRoutine endp

	InterruptRoutine proc far
	;Device driver interrupt routine called by MS-DOS kernel immediately after call to strategy routine.
		push ax
		push bx
		push cx
		push dx
		push ds
		push es
		push di
		push si
		push bp

		push cs ;[Make local data accessible
		pop ds ; by setting DS = CS.]

		mov bx, word ptr RequestHeaderPtr ;BX = Offset address of request header.
		mov es, word ptr RequestHeaderPtr + 2 ;ES = Base address of request header.
		mov al, es:[bx+2]
		cmp al, 00h
		jne JVL
			call Initialize
		JVL:
		cmp al, 08h
		jne SKIP
			call Write
		SKIP:
		or ax, 0100h ;[Merge done bit into status word,
		mov es:[bx+3], ax ; & store status into request header.]

		push bp
		push si
		push di
		push es
		push ds
		push dx
		push cx
		push bx
		push ax
		ret ;Back to MS-DOS kernel.
	InterruptRoutine endp

	Write proc near
		mov si, es:[bx+14]
		mov ds, es:[bx+16]
		mov cx, es:[bx+18]
		JAG:
			mov ah, 00h
			mov al, [si]
			mov dx, 00h
			int 17h
			inc si
			loop JAG
			xor ax, ax
			ret
	Write endp
	
	Initialize proc near
		mov ah, 09h
		lea dx, Msg
		int 21h
		mov word ptr es:[bx+14], offset Initialize ;[Set address of free memory above
		mov word ptr es:[bx+16], cs ; driver (break address).
		mov ah, 01h
		mov dx, 00h
		int 17h
		xor ax, ax
		ret
	Initialize endp
end