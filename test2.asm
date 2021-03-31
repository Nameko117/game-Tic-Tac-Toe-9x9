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

print		PROTO, source:PTR BYTE, sLength:DWORD
drawLine	PROTO
drawData	PROTO
input		PROTO

x0 = 5
y0 = 3

.data
blank	BYTE "■"
		BYTE "□"
mark	BYTE "Ｏ"
		BYTE "Ｘ"
line0	BYTE " ＡＢＣ  ＤＥＦ  ＧＨＩ"
line1	BYTE "1", 3 DUP("□"), "│ ", 3 DUP("□"), "│ ", 3 DUP("□")
line2	BYTE " ", 6 DUP("─"), "┼ ", 6 DUP("─"), "┼ ", 6 DUP("─")
inputMsg	BYTE "請輸入想畫Ｏ或Ｘ的位置（Ex.F5）：", 0
errorMsg	BYTE "錯誤的輸入格式", 0

; 全形符號佔3個BYTE
data	BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		BYTE 9 DUP("■")
		
buffer BYTE 2 DUP(0), 0
byteCount DWORD ?

outputHandle DWORD 0
bytesWritten DWORD 0
count DWORD 0
xyPosition COORD <x0, y0>

.code
main PROC
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE ; Get the console ouput handle
    mov outputHandle, eax ; save console handle
	mov eax , black + ( white*16 )    ; 黑字白底
    call SetTextColor
	call Clrscr ; 清空螢幕
	
	; 畫線
	INVOKE drawLine
	INVOKE drawData
	
	; 提示輸入
	mov	edx, OFFSET inputMsg
	call WriteString    

	; 輸入
	INVOKE input
	
	call WaitMsg
    call Clrscr
main ENDP

input PROC
L1:
	mov edx, OFFSET buffer			; 指定緩衝區 
    mov ecx, ( SIZEOF buffer ) - 1	; 扣掉null，指定最大讀取字串長度
    call ReadString					; 輸入字串
    mov byteCount, eax				; 字串的長度
ret
input ENDP

print PROC, source:PTR BYTE, sLength:DWORD
	INVOKE WriteConsoleOutputCharacter,
       outputHandle,
       source,
       sLength,
       xyPosition,
       ADDR count
	ret
print ENDP

drawLine PROC USES ecx esi
	; 座標設置原點
	mov xyPosition.x, x0-1
	mov xyPosition.y, y0-1
	
	; 畫線
	INVOKE print, ADDR line0, LENGTHOF line0
	inc xyPosition.y
	mov ecx, 2
L2:
	push ecx
	mov ecx, 3
	L1:
		push ecx
		INVOKE print, ADDR line1, LENGTHOF line1
		inc line1
		inc xyPosition.y
		pop ecx
	LOOP L1
	INVOKE print, ADDR line2, LENGTHOF line2
	inc xyPosition.y
	pop ecx
LOOP L2

	mov ecx, 3
L3:
	push ecx
	INVOKE print, ADDR line1, LENGTHOF line1
	inc line1
	inc xyPosition.y
	pop ecx
LOOP L3
ret
drawLine ENDP

drawData PROC USES ecx esi eax
	; 座標設置原點
	mov xyPosition.x, x0
	mov xyPosition.y, y0
	
	; 設置讀取data位置
	mov esi, OFFSET data[0]
	
	mov ecx, 3
L1:
	push ecx
	mov ecx, 3
	L2:
		push ecx
		mov ecx, 3
		L3:
			push ecx
			INVOKE print, esi, 9
			add esi, 9
			inc xyPosition.y
			pop ecx
		LOOP L3
		add xyPosition.x, 8
		sub xyPosition.y, 3
		pop ecx
	LOOP L2
	mov xyPosition.x, x0
	add xyPosition.y, 4
	pop ecx
LOOP L1
ret
drawData ENDP

END main