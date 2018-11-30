.686

.model flat

extern _ExitProcess@4 : PROC
extern __read: PROC
extern __write: PROC

public _main
public _saveToEAX
public _showEAX 

.data
INChars db 12 dup (?)
OUTChars db 12 dup (?)
ten dd 10 

.code
_main PROC
		push dword PTR 12
		push dword PTR OFFSET INChars
		push dword PTR 0
		call __read
		add esp, 12

		call _saveToEAX
		
		mul eax

		call _showEAX

		push 0
		call _ExitProcess@4
_main ENDP

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



_showEAX PROC
		pusha
		mov esi, 10 ;index
		mov ebx, 10 ;dividor
	conversion:
		mov edx, 0 ;set 0 on tmp ascii char container
		div ebx ; :10
		add dl, 30H ;change to ascii char
		mov OUTChars[esi], dl ;save ascii char to table on specific position (esi is index)
		dec esi ;decrement index
		cmp eax, 0 
		jne conversion ;if zero fill by spaces

	fill:
		or esi, esi ;if index zero
		jz show ; show result
		mov byte PTR OUTChars[esi], 20H ;move space to tab
		dec esi ; decrement index
		jmp fill ; loop

	show:
		mov byte PTR OUTChars[0], 0AH ;newline on first position
		mov byte PTR OUTChars[11], 0AH ;newline on last position

		push dword PTR 12 ;number of chars
		push dword PTR OFFSET OUTChars ;table 
		push dword PTR 1 ;device
		call __write ; show resut
		add esp, 12

		popa
		ret
		
_showEAX ENDP

END