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
				xor xmm1, xmm1
				mov r10, kernelOffset
				.buscarMax:
											 ; No se si es Valido
					movdqu xmm2, [rdi + esi * (r11 + r10)  * pixel_size + (r12 - kernelOffset) * pixel_size] ; Agarro los 4 pixeles de la izq de la fila que estamos viendo del kernel
					pmaxub xmm1, xmm2 ; Me quedo con los mayores
					movdqu xmm2, [rdi + esi * (r11 + r10)  * pixel_size + r12 * pixel_size] ; Ahora agarramos los de la derecha
					pmaxub xmm1, xmm2 ; De vuelta nos quedamos con los mayores
					inc r10
					cmp r10, kernelMaxOffset
					jle .buscarMax

				; XMM1 = |Max1|Max2|Max3|Max4|
				movdqu xmm2, xmm1 
				psrldq xmm2, 8 ; XMM2 = |0|0|Max1|Max2|
				pmaxub xmm1, xmm2 ; XMM1 = |Max1|Max2|Max3v1|Max4v2|
				movdqu xmm2, xmm1 
				psrldq xmm2, 4 ; XMM2 = |0|Max1|Max2|Max3v1|
				movdqu xmm1, xmm2 ; XMM1 = |?|?|?|MAX| MAX=|R|G|B|A|
				
				pxor xmm15, xmm15
				punpcklbw xmm1, xmm15 
				punpcklwd xmm1, xmm15 
				mulps xmm1, xmm7 ; xmm7 = val

				;???
				movdqu xmm2, [rdi + esi * r11 * pixel_size + r12 * pixel_size], pixelBlanco ; Pintamos de blanco
				punpcklbw xmm2, xmm15 
				punpcklwd xmm2, xmm15 
				mulps xmm2, xmm6 ; xmm6 = val

				addps xmm2, xmm1
				
				cvtps2dq xmm2, xmm2 ;paso a dword

				;pasar a dword a byte
				;guardar en memoria

			.aumentarColumna:
				inc r12 
				cmp r12, esi
				jle .filaNormal
		.aumentarFila:
			inc r11
			cmp r11, edx
			jle .filaLoop
ret