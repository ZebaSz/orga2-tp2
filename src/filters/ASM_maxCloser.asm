global ASM_maxCloser
extern C_maxCloser

%define PIXEL_WHITE 0x00FFFFFF
%define PIXEL_WHITE_D 0x00FFFFFF00FFFFFF

%define VAL_CMPL 0x0001000100010001

%define pixel_size 4
%define kernel_offset 3
%define kernel_height 7

; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth), xmm0(float val)

ASM_maxCloser:
	mov esi, esi
	mov edx, edx

	mov r15, rsi
	sub r15, 4 ; Ancho - 4
	mov r14, rdx
	sub r14, 4 ; Altura - 4
	
	xor r11, r11 ; R11 (Fila indice) = 0

	movdqu xmm6, xmm0
	pslldq xmm6, 4
	paddd xmm6, xmm0
	pslldq xmm6, 4
	paddd xmm6, xmm0 ; xmm6 = |0|val|val|val|

	mov rax, VAL_CMPL
	movq xmm7, rax
	pxor xmm15, xmm15
	punpcklwd xmm7, xmm15
	cvtdq2ps xmm7, xmm7
	subps xmm7, xmm6 ; xmm7 = |1|1-val|1-val|1-val|

	mov rax, PIXEL_WHITE_D
	movq xmm8, rax
	pslldq xmm8, 8
	movq xmm15, rax
	paddq xmm8, xmm15 ; xmm8 = |PixelBlanco|PixelBlanco|PixelBlanco|PixelBlanco|

	.filaLoop:
		xor r12, r12 ; R12 (Columna indice) = 0

		; if (Fila < 3 || Fila > Altura - 4 ) {Pinto Fila de Blanco} else {Pinto fila normal}
		cmp r11, 3
		jl .filaBlanca
		cmp r11, r14
		jle .filaNormal
		
		.filaBlanca:
			mov rax, rsi
			mul r11
			lea rax, [rcx + rax * pixel_size]
			movdqu [rax + r12 * pixel_size], xmm8 ; Agregar en la imagen 4 pixeles blancos (contiguos) ya que estamos en las primeras filas o las ultimas(y sabemos que toda la fila es blanca)
			cmp r12, rsi
			jge .aumentarFila
			add r12, 4 ; Aumentos en 4 el indice de columna (ya rellenamos 4 pixeles)
			jmp .filaBlanca

		.filaNormal:

			; if (Columna < 3 || Columna > Ancho - 4) {Pinto Blanco} else {Calculo con el Maximo}
			cmp r12, 3
			jl .pintaBlanco
			cmp r12, r15
			jle .pintaMax

			.pintaBlanco:
				mov rax, rsi
				mul r11
				lea rax, [rcx + rax * pixel_size]
				mov dword [rax + r12 * pixel_size], PIXEL_WHITE ; Pintamos de blanco
				jmp .aumentarColumna

			.pintaMax:
				; TODO: podriamos fijarnos si val es 0 en cuyo caso van los mismos pixeles en toda la imagen
				pxor xmm1, xmm1
				xor r10, r10
				.buscarMax:
					mov rax, r10
					add rax, r11
					mul rsi
					lea rax, [rdi + rax * pixel_size]

					mov rbx, r12
					sub rbx, kernel_offset

					movdqu xmm2, [rax + rbx * pixel_size] ; Agarro los 4 pixeles de la izq de la fila que estamos viendo del kernel
					pmaxub xmm1, xmm2 ; Me quedo con los mayores
					movdqu xmm2, [rax + r12 * pixel_size] ; Ahora agarramos los de la derecha
					pmaxub xmm1, xmm2 ; De vuelta nos quedamos con los mayores
					inc r10
					cmp r10, kernel_height
					jle .buscarMax

				; XMM1 = |Max1|Max2|Max3|Max4|
				movdqu xmm2, xmm1 
				psrldq xmm2, 8 ; XMM2 = |0|0|Max1|Max2|
				pmaxub xmm1, xmm2 ; XMM1 = |Max1|Max2|Max3v1|Max4v2|
				movdqu xmm2, xmm1 
				psrldq xmm2, 4 ; XMM2 = |0|Max1|Max2|Max3v1|
				pmaxub xmm1, xmm2 ; XMM1 = |?|?|?|MAX|
				
				pxor xmm15, xmm15
				punpcklbw xmm1, xmm15
				punpcklwd xmm1, xmm15
				cvtdq2ps xmm1, xmm1
				mulps xmm1, xmm6 ; multiplico los maximos por val

				; Cargo el pixel original
				mov rax, rsi
				mul r11
				lea rax, [rdi + rax * pixel_size]
				mov eax, [rax + r12 * pixel_size]
				movd xmm2, eax
				punpcklbw xmm2, xmm15
				punpcklwd xmm2, xmm15
				cvtdq2ps xmm2, xmm2
				mulps xmm2, xmm7 ; multiplico los originales por 1-val

				addps xmm2, xmm1
				
				cvtps2dq xmm2, xmm2 ;paso a dword

				;pasar a dword a byte
				;guardar en memoria

			.aumentarColumna:
				inc r12 
				cmp r12, rsi
				jle .filaNormal
		.aumentarFila:
			inc r11
			cmp r11, rdx
			jle .filaLoop
ret