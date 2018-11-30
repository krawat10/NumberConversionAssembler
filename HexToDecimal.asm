.686

.model flat

extern _ExitProcess@4  : PROC
extern __read : PROC
extern __write : PROC

public _main
public _saveHexToEAX

.data
OUTChars db 12 dup (?)
.code
_main PROC
		call _saveHexToEAX
		call _showEAX
		push 0 
		call _ExitProcess@4
_main ENDP

_saveHexToEAX PROC
		push ebx
		push ecx
		push edx
		push esi
		push edi
		push ebp ; pusha without eax

		sub esp, 12 ; reserve 12 bytes on stack
		mov esi, esp ;save adress of reserved 12 bytes on stack

		push dword PTR 12 ; 1 arg, number of elements
		push esi ; adress where symbols from console will be saved
		push dword PTR 0 ; device
		call __read 
		add esp, 12 ; removes args from stack

		mov eax, 0 ;reset place where number will be saved
	parse:
		mov dl, [esi] ;get value from pointing on adress where value is ([0x123])
		inc esi ; increment adress (like index)
		cmp dl, 10 ; check if ENTER is pressed
		je finish
		cmp dl, '0'
		jb parse ; go to next number (illegal character)
		cmp dl, '9'
		ja notDecSymbol
		sub dl, '0' ; change ASCII to number (like sub cl, 30H)
	appendChar:
		shl eax, 4 ; rotate left (00001010 -> 10100000)
		or al, dl ; write on al dl (al(0000) OR dl(1101) -> al(1101))
		jmp parse
	notDecSymbol:
		cmp dl, 'A'
		jb parse
		cmp dl, 'F'
		ja notUpperAlphaSymbol 
		sub dl, 'A' - 10 ; dl - 41H
		jmp appendChar
	notUpperAlphaSymbol:
		cmp dl, 'a'
		jb parse
		cmp dl, 'f'
		ja parse
		sub dl, 'a' - 10
		jmp appendChar
	finish:
		add esp, 12 ;clear stack where tmp hex number is
		
		pop ebp ; return register before return to main
		pop edi
		pop esi
		pop edx
		pop ecx
		pop ebx
		ret
_saveHexToEAX ENDP


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