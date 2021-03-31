TITLE Example of ASM              (helloword.ASM)

; This program locates the cursor and displays the
; system time. It uses two Win32 API structures.
; Last update: 6/30/2005

INCLUDE Irvine32.inc

; Redefine external symbols for convenience
; Redifinition is necessary for using stdcall in .model directive 
; using "start" is because for linking to WinDbg.  added by Huang
 
main          EQU start@0

;Comment @
;Definitions copied from SmallWin.inc:

.stack 4096

drawBox PROTO

.data
box1 BYTE 3 DUP("■"), "│ ", 3 DUP("■"), "│ ", 3 DUP("■")
box2 BYTE 6 DUP("─"), "┼ ", 6 DUP("─"), "┼ ", 6 DUP("─")

outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyOriginal COORD <5, 3>
xyPosition COORD <>

.code
main PROC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
    mov outputHandle, eax ; save console handle
	mov eax , black + ( white*16 )    ; 黑字白底
    call SetTextColor
	call Clrscr ; 清空螢幕
	
	INVOKE drawBox

    call WaitMsg
    call Clrscr
main ENDP

drawBox PROC USES ecx eax
	mov ax, xyOriginal.x
	mov xyPosition.x, ax
	mov ax, xyOriginal.y
	mov xyPosition.y, ax
	call Clrscr
	mov ecx, 2
L2:
	push ecx
		mov ecx, 3
	L1:
		push ecx
		INVOKE WriteConsoleOutputCharacter,
		outputHandle,   ; console output handle
		ADDR box1,   ; pointer to the top box line
		LENGTHOF box1,   ; size of box line
		xyPosition,   ; coordinates of first char
		ADDR count    ; output count
		inc xyPosition.y   ; 座標換到下一行位置
		pop ecx
	Loop L1
		INVOKE WriteConsoleOutputCharacter,
		outputHandle,   ; console output handle
		ADDR box2,   ; pointer to the top box line
		LENGTHOF box2,   ; size of box line
		xyPosition,   ; coordinates of first char
		ADDR count    ; output count
		inc xyPosition.y   ; 座標換到下一行位置
	pop ecx
LOOP L2
	mov ecx, 3
L3:
	push ecx
	INVOKE WriteConsoleOutputCharacter,
	outputHandle,   ; console output handle
	ADDR box1,   ; pointer to the top box line
	LENGTHOF box1,   ; size of box line
	xyPosition,   ; coordinates of first char
	ADDR count    ; output count
	inc xyPosition.y   ; 座標換到下一行位置
	pop ecx
Loop L3
ret
drawBox ENDP

END main