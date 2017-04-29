global ASM_maxCloser
extern C_maxCloser

%define pixel_size 4

; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth), xmm0(float val)

ASM_maxCloser:

	mov r15, rsi 
	sub r15, 4 ; Ancho - 4
	mov r14, rdx
	sub r14, 4 ; Altura - 4
	
	xor r11, r11 ; R11 (Fila indice) = 0

	.filaLoop:
		xor r12, r12 ; R11 (COLUMN indice) = 0

		; if (Fila < 3 || Fila > Altura - 4 ) {Pinto Fila de Blanco} else {Pinto fila normal}
		cmp r11, 3
		jl .filaBlanca
		cmp r11, r14
		jle .filaNormal
		
		.filaBlanca:
			mov dq [rcx + esi * r11 * pixel_size + r12 * pixel_size], cuatroPixelsBlancos ; Agregar en la imagen 4 pixeles blancos (contiguos) ya que estamos en las primeras filas o las ultimas(y sabemos que toda la fila es blanca)
			cmp r12, esi
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
				mov dw [rcx + esi * r11 * pixel_size + r12 * pixel_size], pixelBlanco ; Pintamos de blanco
				jmp .aumentarColumna

			.pintaMax:
				; TODO: podriamos fijarnos si val es 0 en cuyo caso van los mismos pixeles en toda la imagen
				xor xmm0, xmm0
				mov r10, kernelOffset
				.buscarMax:
											 ; No se si es Valido
					movdqu xmm1, [rcx + esi * (r11 + r10)  * pixel_size + (r12 - kernelOffset) * pixel_size] ; Agarro los 4 pixeles de la izq de la fila que estamos viendo del kernel
					pmaxub xmm0, xmm1 ; Me quedo con los mayores
					movdqu xmm1, [rcx + esi * (r11 + r10)  * pixel_size + r12 * pixel_size] ; Ahora agarramos los de la derecha
					pmaxub xmm0, xmm1 ; De vuelta nos quedamos con los mayores
					inc r10
					cmp r10, kernelMaxOffset
					jle .buscarMax

				; XMM0 = |Max1|Max2|Max3|Max4|
				movdqu xmm1, xmm0 
				psrldq xmm1, 8 ; XMM1 = |0|0|Max1|Max2|
				pmaxub xmm0, xmm1 ; XMM0 = |Max1|Max2|Max3v1|Max4v2|
				movdqu xmm1, xmm0 
				psrldq xmm1, 4 ; XMM1 = |0|Max1|Max2|Max3v1|
				movdqu xmm0, xmm1 ; XMMP = |?|?|?|MAX|









			.aumentarColumna:
				inc r12 
				cmp r12, esi
				jle .filaNormal
		.aumentarFila:
			inc r11
			cmp r11, edx
			jle .filaLoop

		; if (Fila < 3 || COLUMN < 3 || Fila > Ancho - 4 || COLUMN > Altura - 4) {Pinto Blanco} else {Calculo con el Maximo}
		cmp r12, 3
		jl .blanco
		cmp r11, r15
		jg .blanco
		cmp r12, 3
		jle .calcularMax
		.blanco:
			mov dq [rcx + esi * r11 * pixel_size + r12 * pixel_size], blanco
			jmp 
		.calcularMax:
			mov r15, [rdi + esi * r11 * pixel_size + r12 * pixel_size]


		.aumentarColumna:
			add r11, 4
			jmp .filaLoop 





ret