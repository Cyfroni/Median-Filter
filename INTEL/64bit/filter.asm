;=====================================================================
; ARKO - Projekt na laboratorium intel x86
;
; Autor: Karol Orowski
; Opis:  funkcja filtruje medianowo obrazek
;         void filter(char* buffer, char* picture, char* result); 
;	   
;
;=====================================================================

section	.text
global  filter

filter:
	push	rbp
	mov	rbp, esp
	
	push	DWORD[rbp+16]
	push	DWORD[rbp+12]

	mov	eax, [rbp+12]
	push	DWORD[eax+18]
	push	DWORD[eax+22]

	mov	ebx, [rbp-12]
	add	[rbp-12], ebx
	add	[rbp-12], ebx

	;copy header
	mov	ecx, 54
	mov	esi, [rbp-8]
	mov	edi, [rbp-4]
	rep movsb
	mov	[rbp-8], esi
	mov	[rbp-4], edi

	;calculate padding 
	mov	eax, [eax+34]
	cdq
	div	DWORD[rbp-16]
	push	eax	
	mov	ebx, [rbp-12]
	sub	[rbp-20], ebx
	mov	ebx, [rbp-20]
	add	[rbp-12], ebx
	dec	DWORD[rbp-16]

	;write 1st and 2nd row to buffer
	mov	ecx, [rbp-12]
	add	ecx, [rbp-12]
	mov	esi, [rbp-8]
	mov	edi, [rbp+8]
	rep movsb
	mov	[rbp-8], esi

	;write 1st row to result
	mov	ecx, [rbp-12]
	mov	esi, [rbp+8]
	mov	edi, [rbp-4]
	rep movsb
	mov	[rbp-4], edi
	
	;initiate counters
	push 	1	;row counter 			ebp-24
	push	0	;column counter			ebp-28
	push	0	;bit counter			ebp-32
	
add_new_row:
	inc  	DWORD[rbp-24]

	;find place for new row in buffer
    	mov      eax, [rbp-24]
   	cdq
    	mov      ecx, 3
    	idiv     ecx

    	imul      edx, [rbp-12]

	;write row to buffer
	mov	edi, [rbp+8]
	mov	esi, [rbp-8]
	mov 	ecx, [rbp-12]
	add	edi, edx
	rep movsb
	mov	[rbp-8], esi

	;find previous "new row"
	mov      eax, [rbp-24]
	dec	 eax
    	cdq
    	mov      ecx, 3
    	idiv     ecx

	imul     edx, [rbp-12]
	
	;write first pixel of previous "new row" to result
	mov	esi, [rbp+8]
	add	esi, edx
	push	esi		;ebp-36
	mov	ecx, 3
	mov	edi, [rbp-4]
	rep movsb
	mov	[rbp-4], edi
	
	;column counter
	mov	DWORD[rbp-28], 3
	
writing:
	;find pixel's column position in buffer
	mov	eax, [rbp+8]
	add	eax, [rbp-28]
	push	eax		;ebp-40
	add	DWORD[rbp-28], 3

	mov	BYTE[rbp-32], 0
next_bit:
	mov	eax, [rbp-40]
	add	eax, [rbp-32]
	mov	ebx, 0

	;put 9 bytes on stack
	mov	bl, [eax-3]
	push	ebx
	mov	bl, [eax]
	push	ebx
	mov	bl, [eax+3]
	push	ebx
	add	eax, [rbp-12]
	mov	bl, [eax-3]
	push	ebx
	mov	bl, [eax]
	push	ebx
	mov	bl, [eax+3]
	push	ebx
	add	eax, [rbp-12]
	mov	bl, [eax-3]
	push	ebx
	mov	bl, [eax]
	push	ebx
	mov	bl, [eax+3]
	push	ebx
	
	;find_median
	push	0		;counter to 5 (5th smallest is median) ebp-80
	push	0		;counter to 8 (9 bytes to compare)     ebp-84

next_smallest:
	inc	BYTE[rbp-80]

	mov	eax, rbp	;buffer
	sub	eax, 80 	
	mov	bl, 255		;smallest
	mov	BYTE[rbp-84], 0

find_smallest:
	cmp	BYTE[rbp-84], 9	
	je	smallest_found

	inc	BYTE[rbp-84]
	add	eax, 4  
	cmp	bl, BYTE[eax]
	jb	find_smallest

	mov	bl, [eax]	;smallest's value
	mov	edx, eax	;smallest's address
	jmp	find_smallest

smallest_found:
	mov	BYTE[edx], 255	;replace smallest with biggest
	cmp	BYTE[rbp-80], 4
	jbe	next_smallest

	;median is in bl
	mov	eax, [rbp-4]
	mov	[eax], bl
	inc	DWORD[rbp-4]
	add	esp, 44

	inc	BYTE[rbp-32]
	cmp	BYTE[rbp-32], 3
	jne	next_bit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	add	esp, 4
	mov	eax, [rbp-28]
	add	eax, 3
	add	eax, [rbp-20]
	cmp	[rbp-12], eax
	jne	writing

	;write last pixel and padding to result
	pop	esi
	add	esi, [rbp-12]
	mov	ecx, [rbp-20]
	add	ecx, 3
	sub	esi, ecx
	mov	edi, [rbp-4]
	rep	movsb	
	mov	[rbp-4], edi
	
	mov 	eax, [rbp-24]
	cmp 	[rbp-16], eax
	jne	add_new_row

	;find last row in buffer
	mov      eax, [rbp-24]
    	cdq
    	mov      ecx, 3
    	idiv     ecx

    	imul      edx, [rbp-12]

	;write last row to result
	mov	esi, [rbp+8]
	mov	edi, [rbp-4]
	mov 	ecx, [rbp-12]
	add	esi, edx
	rep movsb
	mov	[rbp-4], edi
ending:

	;mov	rax, rsp
	;sub	rax, rbp

	;mov	rsp, rbp
	add	esp, 32
	pop	rbp
	ret

;============================================
; STACK
;============================================
;
; 
;  |                             |
;  | return address              | RBP+8
;  -------------------------------
;  | previous rbp                | RBP
;  -------------------------------
;  | *result		         | RBP-8
;  -------------------------------
;  | *picture			 | RBP-16
;  -------------------------------
;  | 3*width+padding		 | RBP-24
;  -------------------------------
;  | height-1			 | RBP-32
;  -------------------------------
;  | padding			 | RBP-40
;  -------------------------------
;  | row counter 		 | RBP-48
;  -------------------------------
;  | column counter 		 | RBP-56
;  -------------------------------
;  | bit counter 		 | RBP-64
;  -------------------------------
;  | first and last pix		 | RBP-72
;  -------------------------------
;  | pixel position		 | RBP-80
;  -------------------------------
;  | bytes to calculate median	 | RBP-(88:152)
;  -------------------------------
;  | counter to 5 		 | RBP-160
;  -------------------------------
;  | counter to 8		 | RBP-168
;  |				 |
;============================================





