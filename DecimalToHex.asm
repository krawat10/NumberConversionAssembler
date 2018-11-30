.686

.model flat

extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC

public _main
public _showHexFromEAX
public _saveToEAX

.data
decoder db '0123456789ABCDEF'
ten dd 10
INChars db 12 dup (?)
.code
_showHexFromEAX PROC
		pusha

		sub esp, 12 ;register 12 bytes for hex number to show
		mov edi, esp ;save adress of registered 12 bytes
		mov ecx, 8 ;loop number
		mov esi, 1 ;start index (0 is reserved for newline character)
		mov ebp, 1 ;indicates space region 
	hexLoop:
		rol eax, 4 ;rotate bytes (31-28 -> 3-0)
		mov ebx, eax ;copy rotated eax to ebx
		and ebx, 0000000FH ; set 0 on 31-4 positions (0 AND 1 -> 0 ...)
		cmp ebx, 0 ;check if number to check is zero (possible space if it is one of the first zero numbers)
		jne decodeNumber
		cmp ebp, 1 ;check boolean to indicate if this zero number are after some non-zero character(to prevent saving space char)
		jne decodeNumber
		mov byte PTR [edi][esi], 32 ; move space to registered space on stack on specific index ([0xABC][1] = ' ') 
		inc esi ; increment index 
		loop hexLoop ;back to hexLoop (ecx--)
		
	decodeNumber:
		mov ebp, 0 ;first non-zero number appears, skip next space-setting region
		mov dl, decoder[ebx] ; get character from decoder table using index (decoder[10] -> 'A')
		mov [edi][esi], dl ; move hex number to registered space on stack on specific index ([0xABC][1]) 
		inc esi ; increment index 
		loop hexLoop ;back to hexLoop (ecx--)

		mov byte PTR [edi][0], 10 ;add newlines on start and end of tab
		mov byte PTR [edi][9], 10

		push 10 ;number of characters (8 + 2 newlines)
		push edi ;adress to number (refers to stack)
		push 1 ;number of device
		call __write 

		add esp, 24 ;clear stack (12 bytes reserved for hex number + 3 pushes)
		popa ;return all generic-registers
		ret
_showHexFromEAX ENDP

_saveToEAX PROC
		push ebx
		push ecx
		push edx
		push esi
		push edi
		push ebp 

		mov eax, 0
		mov ebx, OFFSET INChars ; move INChars's adress to ebx 

	getCharacters:
		mov cl, [ebx] ; mov INChars's value to cl
		inc ebx ; increment INChars's adress (go to next index)

		cmp cl, 10 ; check if passed value is enter symbol
		je wasEnter
		sub cl, 30H ; subtract 30H from passed value (ASCII number -> number)
		movzx ecx, cl ; move passes value to ecx (8bit -> 32bit movement)
		
		mul dword PTR ten
		add eax, ecx
		jmp getCharacters

	wasEnter:
		pop ebx
		pop ecx
		pop edx
		pop esi
		pop edi
		pop ebp 
		
		ret
_saveToEAX ENDP



_main PROC
		push dword PTR 12
		push dword PTR OFFSET INChars
		push dword PTR 0
		call __read
		add esp, 12

		call _saveToEAX	

		call _showHexFromEAX

		push 0
		call _ExitProcess@4
_main ENDP
END
