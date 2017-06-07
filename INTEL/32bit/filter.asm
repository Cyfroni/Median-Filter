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
	push	ebp
	mov	ebp, esp
	

	push	DWORD[ebp+16]
	push	DWORD[ebp+12]

	mov	eax, [ebp+12]
	push	DWORD[eax+18]
	push	DWORD[eax+22]

	mov	ebx, [ebp-12]
	add	[ebp-12], ebx
	add	[ebp-12], ebx

	;copy header
	mov	ecx, 54
	mov	esi, [ebp-8]
	mov	edi, [ebp-4]
	rep movsb
	mov	[ebp-8], esi
	mov	[ebp-4], edi

	;calculate padding 
	mov	eax, [eax+34]
	cdq
	div	DWORD[ebp-16]
	push	eax	
	mov	ebx, [ebp-12]
	sub	[ebp-20], ebx
	mov	ebx, [ebp-20]
	add	[ebp-12], ebx
	dec	DWORD[ebp-16]

	;write 1st and 2nd row to buffer
	mov	ecx, [ebp-12]
	add	ecx, [ebp-12]
	mov	esi, [ebp-8]
	mov	edi, [ebp+8]
	rep movsb
	mov	[ebp-8], esi

	;write 1st row to result
	mov	ecx, [ebp-12]
	mov	esi, [ebp+8]
	mov	edi, [ebp-4]
	rep movsb
	mov	[ebp-4], edi
	
	;initiate counters
	push 	1	;row counter 			ebp-24
	push	0	;column counter			ebp-28
	push	0	;bit counter			ebp-32
	
add_new_row:
	inc  	DWORD[ebp-24]

	;find place for new row in buffer
    	mov      eax, [ebp-24]
   	cdq
    	mov      ecx, 3
    	idiv     ecx

    	imul      edx, [ebp-12]

	;write row to buffer
	mov	edi, [ebp+8]
	mov	esi, [ebp-8]
	mov 	ecx, [ebp-12]
	add	edi, edx
	rep movsb
	mov	[ebp-8], esi

	;find previous "new row"
	mov      eax, [ebp-24]
	dec	 eax
    	cdq
    	mov      ecx, 3
    	idiv     ecx

	imul     edx, [ebp-12]
	
	;write first pixel of previous "new row" to result
	mov	esi, [ebp+8]
	add	esi, edx
	push	esi		;ebp-36
	mov	ecx, 3
	mov	edi, [ebp-4]
	rep movsb
	mov	[ebp-4], edi
	
	;column counter
	mov	DWORD[ebp-28], 3
	
writing:
	;find pixel's column position in buffer
	mov	eax, [ebp+8]
	add	eax, [ebp-28]
	push	eax		;ebp-40
	add	DWORD[ebp-28], 3

	mov	BYTE[ebp-32], 0
next_bit:
	mov	eax, [ebp-40]
	add	eax, [ebp-32]
	mov	ebx, 0

	;put 9 bytes on stack
	mov	bl, [eax-3]
	push	ebx
	mov	bl, [eax]
	push	ebx
	mov	bl, [eax+3]
	push	ebx
	add	eax, [ebp-12]
	mov	bl, [eax-3]
	push	ebx
	mov	bl, [eax]
	push	ebx
	mov	bl, [eax+3]
	push	ebx
	add	eax, [ebp-12]
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
	inc	BYTE[ebp-80]

	mov	eax, ebp	;buffer
	sub	eax, 80 	
	mov	bl, 255		;smallest
	mov	BYTE[ebp-84], 0

find_smallest:
	cmp	BYTE[ebp-84], 9	
	je	smallest_found

	inc	BYTE[ebp-84]
	add	eax, 4  
	cmp	bl, BYTE[eax]
	jb	find_smallest

	mov	bl, [eax]	;smallest's value
	mov	edx, eax	;smallest's address
	jmp	find_smallest

smallest_found:
	mov	BYTE[edx], 255	;replace smallest with biggest
	cmp	BYTE[ebp-80], 4
	jbe	next_smallest

	;median is in bl
	mov	eax, [ebp-4]
	mov	[eax], bl
	inc	DWORD[ebp-4]
	add	esp, 44

	inc	BYTE[ebp-32]
	cmp	BYTE[ebp-32], 3
	jne	next_bit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	add	esp, 4
	mov	eax, [ebp-28]
	add	eax, 3
	add	eax, [ebp-20]
	cmp	[ebp-12], eax
	jne	writing
	
	;write last pixel and padding to result
	pop	esi
	add	esi, [ebp-12]
	mov	ecx, [ebp-20]
	add	ecx, 3
	sub	esi, ecx
	mov	edi, [ebp-4]
	rep	movsb	
	mov	[ebp-4], edi
	
	mov 	eax, [ebp-24]
	cmp 	[ebp-16], eax
	jne	add_new_row

	;find last row in buffer
	
	mov      eax, [ebp-24]
    	cdq
    	mov      ecx, 3
    	idiv     ecx

    	imul      edx, [ebp-12]
	
	;write last row to result
	mov	esi, [ebp+8]
	mov	edi, [ebp-4]
	mov 	ecx, [ebp-12]
	add	esi, edx
	rep movsb
	mov	[ebp-4], edi
ending:

	;mov	eax, ecx
	;sub	eax, ebp

	mov	esp, ebp
	;add	esp, 32
	pop	ebp
	ret

;============================================
; STACK
;============================================
;
; 
;  |                             |
;  | result	                 | EBP+16
;  -------------------------------
;  | picture	                 | EBP+12
;  -------------------------------
;  | buffer	                 | EBP+8
;  -------------------------------
;  | return address              | EBP+4
;  -------------------------------
;  | previous ebp                | EBP
;  -------------------------------
;  | *result		         | EBP-4
;  -------------------------------
;  | *picture			 | EBP-8
;  -------------------------------
;  | 3*width+padding		 | EBP-12
;  -------------------------------
;  | height-1			 | EBP-16
;  -------------------------------
;  | padding			 | EBP-20
;  -------------------------------
;  | row counter 		 | EBP-24
;  -------------------------------
;  | column counter 		 | EBP-28
;  -------------------------------
;  | bit counter 		 | EBP-32
;  -------------------------------
;  | first and last pix		 | EBP-36
;  -------------------------------
;  | pixel position		 | EBP-40
;  -------------------------------
;  | bytes to calculate median	 | EBP-(44:76)
;  -------------------------------
;  | counter to 5 		 | EBP-80
;  -------------------------------
;  | counter to 8		 | EBP-84
;  |				 |
;============================================





