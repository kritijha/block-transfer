;Block transfer overlapped(positive and negative) and non overlapped with and without using string instructions

section .data
	msg1 db 10,'Enter a choice', 10
	msg1Len: equ $-msg1
	msg2 db 10,'1.non overlapped without string', 10
	msg2Len: equ $-msg2
	msg3 db 10,'2.non overlapped with string', 10
	msg3Len: equ $-msg3
	msg4 db 10,'3.overlapped without string positive', 10
	msg4Len: equ $-msg4
	msg5 db 10,'4.overlapped with string positive', 10
	msg5Len: equ $-msg5
	msg6 db 10,'5.overlapped without string negative', 10
	msg6Len: equ $-msg6
	msg7 db 10,'6.overlapped with string negative', 10			;different destination, destination pointing to source
	msg7Len: equ $-msg7
	msg8 db 2Ch
	msg8Len: equ $-msg8
	msg9 db 10,'The original source is',10
	msg9Len: equ $-msg9
	msg10 db 10,'The original destination is',10
	msg10Len: equ $-msg10
	msg11 db 10,'The new source is',10
	msg11Len: equ $-msg11
	msg12 db 10,'The new destination is',10
	msg12Len: equ $-msg12
	msg13 db 10,'How many two digit numbers?,10
	msg13Len: equ $-msg13
	msg14 db 10,'Enter the numbers',10
	msg14Len: equ $-msg14
	
	;source db 21h, 22h, 23h, 24h, 25h
	destn times 7 db 00h
section .bss
	choice resb 1
	digit_cnt resb 1
	temp resd 1
	count resb 1
	num resb 3
	cnt resb 3
	
%macro disp 2
	mov eax,4
	mov ebx,1
	mov ecx,%1
	mov edx,%2
	int 80h
%endmacro

%macro read 2
	mov eax,3
	mov ebx,0
	mov ecx,%1
	mov edx,%2
	int 80h
%endmacro

section .text
global _start
_start:
	
	disp msg13, msg13Len
	read num, 3		;save in num
	call asciihex_proc	;convert to hex
	mov byte[cnt],bl 	;move the value to count
start1:
	disp msg14,msg14Len	;display message to take input											
	read num, 3		;read number
	call asciihex_proc	;convert to hexadecimal
	dec byte[cnt]		;decrement byte count
	mov [source],bl
	mov esi, [source]
	inc esi
	jnz start1
	



disp msg9, msg9Len	
call dispsrc
disp msg10, msg10Len
call dispdest


	
	disp msg1, msg1Len
	disp msg2, msg2Len
	disp msg3, msg3Len
	disp msg4, msg4Len
	disp msg5, msg5Len
	disp msg6, msg6Len
	disp msg7, msg7Len
	read choice, 1
	mov ah,[choice]
	
	cmp ah, '1'
	jne case2
	call nows
	disp msg11, msg11Len
	call dispsrc
	disp msg12, msg12Len
	call dispdest
	
	jmp exit
	
	case2:
		cmp ah,'2'
		jne case3
		call nos
		disp msg11, msg11Len
		call dispsrc
		disp msg12, msg12Len
		call dispdest

		
		jmp exit
	case3:
		cmp ah,'3'
		jne case4
		call owsp
		disp msg11,msg11Len
		call dispsrc
		
		jmp exit
	case4:
		cmp ah,'4'
		jne case5
		call osp1
		disp msg11,msg11Len
		call dispsrc
		
		jmp exit	
	case5:
		cmp ah,'5'
		jne case6
		call owsn
		disp msg11,msg11Len
		call dispsrc
		
		jmp exit
	case6:	
		cmp ah,'6'
		jne case7
		call osn1
		disp msg11,msg11Len
		call dispsrc
		
		jmp exit
	case7:
	exit:	
		mov eax,1
		mov ebx,0
		int 80h	
	
;1	
nows:
	mov esi,source
	mov edi,destn
	mov ecx,5
next:
	mov al,[esi]
	mov [edi],al
	inc esi
	inc edi
	dec ecx
	jnz next

ret

;2
nos:
	mov esi, source
	mov edi, destn
	mov ecx ,5
	cld
	rep movsb
ret

;3
owsp:
	mov esi, source+4
	mov edi, source+4
	add edi, 2
	mov ecx,5
	up:
	mov al,[esi]
	mov [edi],al
	dec esi
	dec edi
	dec ecx
	jnz up
	
ret

;4
osp1:
	mov esi, source+4
	mov edi, source+4
	add edi, 2
	mov ecx,5
	std
	rep movsb
ret

;5
owsn:
	mov esi, source
	mov edi, source
	sub edi,2
	mov ecx, 5
	up2:
	mov al,[esi]
	mov [edi],al
	inc esi
	inc edi
	dec ecx
	jnz up2
ret

;6
osn1:
	mov esi,source
	mov edi,source
	sub edi, 2
	mov ecx, 5
	cld
	rep movsb
ret


dispsrc:
	mov byte[count],5
	mov esi,source
	loop2:
	mov bl,[esi]
	mov byte[digit_cnt], 2
	mov edi,temp
	loop:
		rol bl,4
		mov dl,bl
		and dl, 0Fh
		cmp dl, 39h
		jbe skip
		add dl, 07h
		skip:
			add dl,30h
			mov [edi], dl
			inc edi
			dec byte[digit_cnt]
			jnz loop
			disp temp,2
			disp msg8, msg8Len
		inc esi
		dec byte[count]
		jnz loop2

ret

dispdest:
	mov byte[count],7
	mov edi, destn
	loop3:
	mov bl,[edi]
	mov byte [digit_cnt], 2		;displaying 4 digits
	mov esi,temp			;variable temp moved to edi
	loop4:
		rol  bl, 4		;1 hex bit=4 binary bits (1 hex bit rotated)
		mov al, bl		;masking. not making changes on the original number.
		and al, 0fh		;AND operation, we'll get only last bit
		cmp al, 09h		;comapring if no. is less than 9
		jbe add_30h		;add 37h to get ascii value
		add al, 07h		;else add 07h
	add_30h:
		add al, 30h		;30+7 = 37 
		mov [esi],al
		inc esi			;next digit
		dec byte [digit_cnt]	;decrement counter
		jnz loop4
		disp temp,2		;display final result
		disp msg8, msg8Len
	inc edi
	dec byte[count]
	jnz loop3
	ret
	
asciihex_proc:
	mov ebx, 0		;clear ebx
	mov ecx, 2		;2 digits to be converted
	mov esi, num		;esi points to num
	up3:
	rol bl, 4		;rotate by 4 bits
	mov al, [esi]		;al points to digit
	cmp al, 30h		;check if number is hexadecimal or not
	jb nothex		;if number is less than 30h, 40h or 
	cmp al, 40h		;greater than 46h, not a hexadecimal num
	je nothex
	cmp al, 46h
	ja nothex	
	cmp al, 39h		;compare digit with 39h
	jbe skip2		;if below or equal go to skip
	sub al, 7h		;else subtract 7h
	skip2:
	sub al, 30h		;subtract 30h		
	add al, bl		;add al and bl
	mov bl, al
	inc esi			;point to next digit
	dec ecx			;decrement counter
	jnz up3
	jmp done	
nothex:
	disp msg4, msg4Len	;message if number is not hex
	disp msg1, msg1Len	;message to input another number
	read num,3		;read the number
	call asciihex_proc	;convert to hexadecimal
done:
ret
