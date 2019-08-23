;Program :- WAP to perform operations as,
;           1. Create a file.
;           2. Write data in file.
;           3. Display contents of file.
;           4. Rename a file.
;           5. Delete a file.
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
.stack 100
.data
	AskFileName db 10, 13, 'Enter file name (Up to 8 characters) : $'
	AskCurrName db 10, 13, 'Enter file old name (Up to 8 characters) : $'
	AskNewName db 10, 13, 'Enter file new name (Up to 8 characters) : $'
	EnterData db 10, 13, 'Enter data for file : $'
	MenuLine db 10, 13, '----------MENU----------$'
	Msg1 db 10, 13, '1. Create a file.$'
	Msg2 db 10, 13, '2. Write data in file.$'
	Msg3 db 10, 13, '3. Display contents of file.$'
	Msg4 db 10, 13, '4. Rename a file.$'
	Msg5 db 10, 13, '5. Delete a file.$'
	Msg6 db 10, 13, '6. Exit.$'
	Line db 10, 13, '------------------------$'
	NewLine db 10, 13, '$'
	AskChoice db 10, 13, 'Enter your choice : $'
	WrongChoice db 10, 13, 'Wrong choice!!! Enter again.$'
	CreateFailed db 10, 13, 'File creation failed!!! Error code : $'
	CloseFailed db 10, 13, 'Cannot close file!!! Error code : $'
	OpenFailed db 10, 13, 'Cannot open file!!! Error code : $'
	WriteFailed db 10, 13, 'Error occured during writing data to file!!! Error code : $'
	ReadFailed db 10, 13, 'Error occured during reading data from file!!! Error code : $'
	DeleteFailed db 10, 13, 'File deletion failed!!! Error code : $'
	RenameFailed db 10, 13, 'Rename operation failed!!! Error code : $'
	Created db 10, 13, 'File created successfully!$'
	Deleted db 10, 13, 'File deleted successfully!$'
	Renamed db 10, 13, 'File renamed successfully!$'
	DataWritten db 10, 13, 'Data successfully written to file!$'
	ContentsAre db 10, 13, 'Contents of file are as follows : $'
	FileName db 1fh dup(0)
	CurrName db 1fh dup(0)
	NewName db 1fh dup(0)
	Buffer db 40h dup(0)
.code
	mov ax, @data ;[Initialization of
	mov ds, ax ; data segment &
	mov es, ax ; extra segment.]
BEGIN:
	call PrintMenu
	mov ah, 01h ;[01h function to get
	int 21h ; keystroke from keyboard.]
	Print NewLine
	cmp al, '1'
		jne NEXT1
		Print AskFileName
		mov dx, offset FileName
		call GetFileName
		call CreateFile
		jc BBB
			call CloseFile
		BBB:
		jmp BEGIN
	NEXT1:
	cmp al, '2'
		jne NEXT2
		Print AskFileName
		mov dx, offset FileName
		call GetFileName
		mov ah, 3dh ;[3dh function to open file.
		mov al, 01h ; Specify access mode.
		int 21h
		jnc NOTOPENEDW
			Print OpenFailed
			call DisplayNum
			jmp XXX
		NOTOPENEDW:
			Print EnterData
			Print NewLine
			mov bx, offset Buffer
			mov dx, bx
			mov cx, 0000h
			push ax
			GETCHAR1:
				mov ah, 01h
				int 21h
				cmp al, 13 ; Check if character is "ENTER"
				je ENDOFSTR1 ;If yes, end of strng occured.
					mov [bx], al ;[Put transfered character
					inc bx ;  in string.]
					inc cx
					jmp GETCHAR1
				ENDOFSTR1:
					mov byte ptr [bx], 00h ;Denote end of string.
			pop ax
			mov bx, ax
			call WriteData
			jc XXX
				call CloseFile
				Print DataWritten
		XXX:
		jmp BEGIN
	NEXT2:
	cmp al, '3'
		jne NEXT3
		Print AskFileName
		mov dx, offset FileName
		call GetFileName
		mov ah, 3dh ;[3dh function to open file.
		mov al, 00h ; Specify access mode.
		int 21h
		jnc NOTOPENEDR
			Print OpenFailed
			call DisplayNum
			jmp YYY
		NOTOPENEDR:
			mov bx, ax
			mov cx, 0040h
			mov dx, offset Buffer
			call ReadData
			jc YYY
				Print ContentsAre
				mov cx, ax
				mov bx, dx
				Print NewLine
				call DisplayBuffer
		YYY:
		jmp BEGIN
	NEXT3:
	cmp al, '4'
		jne NEXT4
		Print AskCurrName
		mov dx, offset CurrName
		call GetFileName
		Print AskNewName
		mov dx, offset NewName
		call GetFileName
		mov dx, offset CurrName
		mov di, offset NewName
		call RenameFile
		jmp BEGIN
	NEXT4:
	cmp al, '5'
		jne NEXT5
		Print AskFileName
		mov dx, offset FileName
		call GetFileName
		call DeleteFile
		jmp BEGIN
	NEXT5:
		cmp al, '6'
		je QUIT
	Print WrongChoice
	jmp BEGIN
QUIT:
	mov ah, 4ch ;[4ch function to terminate program &
	int 21h ; return to DOS prompt.]

GetFileName proc near
;Input :- dx = Offset of buffer in which string to be stored in.
;Function :- Accepts filename from user.
;Returns :- String in buffer whose offset is in dx.
	push ax	
	mov bx, dx ;Temporarily transfer offset of buffer in bx.
	GETCHAR:
		mov ah, 01h
		int 21h
		cmp al, 13 ; Check if character is "ENTER"
		je ENDOFSTR ;If yes, end of strng occured.
			mov [bx], al ;[Put transfered character
			inc bx ;  in string.]
			jmp GETCHAR
		ENDOFSTR:
			mov byte ptr [bx], 00h ;Denote end of string.
	pop ax
	ret
GetFilename endp
	
PrintMenu proc near
;Input :- Nothing.
;Function :- Print menu for user.
;Returns :- Nothing.
	Print NewLine
	Print MenuLine
	Print Msg1
	Print Msg2
	Print Msg3
	Print Msg4
	Print Msg5
	Print Msg6
	Print Line
	Print NewLine
	Print AskChoice
	ret
PrintMenu endp

CreateFile proc near
;Input :- Offset of filename in dx register.
;Function :- Creates file.
;Returns :- If successful then handle in ax & reset carry flag.
	push ax
	mov ah, 3ch ;[3ch function to create file.
	mov cx, 0000h ; specifies attributes.]
	int 21h
	jnc FCS ;[If no error, jump else
		Print CreateFailed ; print error message &
		call DisplayNum ; error code & return.]
		jmp CFEND
	FCS:
		mov bx, ax ;Handle in bx.
		Print Created
	CFEND:
	pop ax
	ret
CreateFile endp

CloseFile proc near
;Input :- Handle of file to be closed in bx register.
;Function :- Closes file.
;Returns :- If successful then reset carry flag.
	mov ah, 3eh ;[3eh function
	int 21h ; to close file.]
	jnc CLFEND ;[If no error, jump else
		Print CloseFailed ; display error message &
		call DisplayNum ; error code.]
	CLFEND:
	ret
closeFile endp

WriteData proc near
;Input :- BX = handle, cx = number bytes to write & dx = offset of buffer.
;Function :- Writes data to file.
;Returns :- If successful then reset carry flag.
	mov ah, 40h ;[40h functin  to
	int 21h ; write data to file.]
	jnc WDEND ;[If no error jump, else
		Print WriteFailed ; print error message &
		call Displaynum ; display error code.]
	WDEND:
	ret
WriteData endp

ReadData proc near
;Input :- BX = handle, cx = number bytes to read dx = offset of buffer.
;Function :- Reads data in buffer.
;Returns :- If successful then reset carry flag.
	mov ah, 3fh ;[3fh functin  to
	int 21h ; read data to file.]
	jnc RDEND ;[If no error jump, else
		Print ReadFailed ; print error message &
		call Displaynum ; display error code.]
	RDEND:
	ret
ReadData endp

RenameFile proc near
;Input :- Offset of current filename in DX & new filename in DI registers.
;Function :- Rename file.
;Returns :- If successful then reset carry flag.
	push ax
	mov ah, 56h ;[56h function to
	int 21h ; rename file.]
	jnc FRS ;[If no error jump else
		Print RenameFailed ; print error message &
		call DisplayNum ; error code & return.]
		jmp RFEND
	FRS:
		Print Renamed
	RFEND:
	pop ax
	ret
RenameFile endp

DeleteFile proc near
;Input :- Offset of filename to be deleted in dx register.
;Function :- Deletes file.
;Returns :- If successful then reset carry flag.
	push ax
	mov ah, 41h ;[41h funtion to
	int 21h ; delete file.]
	jnc FDS ;[If no error, jump else
		Print DeleteFailed ; print error message &
		call DisplayNum ; error code & return.]
		jmp DFEND
	FDS:
		Print Deleted
	DFEND:
	pop ax
	ret
DeleteFile endp

DisplayBuffer proc near
;Input :- cx = number of bytes to display, bx = offset of buffer.
;Function :- Displays contents in buffer.
;Returns :- Nothing.
	DISP:
		mov dl, [bx]
		mov ah, 02h ;[02h function to
		int 21h ; diplay byte in dl register.]
		inc bx
		dec cx
	jnz DISP
	ret
DisplayBuffer endp

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