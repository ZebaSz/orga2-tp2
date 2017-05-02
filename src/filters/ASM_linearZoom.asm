global ASM_linearZoom
extern C_linearZoom

%define pixel_size 4

%define LOW64 0xFFFFFFFFFFFFFFFF

; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth)
ASM_linearZoom:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
	mov esi, esi
	mov edx, edx
	mov r8d, r8d

	lea r14, [rsi * pixel_size] ; ancho orig en pixeles, para offsets
	lea r15, [r8 * pixel_size] ; ancho dest en pixeles, para offsets

	mov r10, rcx

	mov r11, rdx ; R11 (Fila indice) = srch - 1

	.filaLoop:
		dec r11

		lea r12, [rsi - 1] ; R12 (Columna indice) = srcw - 1

		mov rax, r11
		sal rax, 1
		add rax, 1
		mul r15
		lea rbx, [r10 + rax] ; RBX: offset de fila destino

		mov rax, r11
		mul r14
		lea rax, [rdi + rax] ; RAX: offset de fila origen

		mov rcx, rax
		sub rcx, r14 ; RCX: offset de segunda fila origen

		mov rdx, rbx
		sub rdx, r15 ; RDX: offset de segunda fila destino

		movd xmm0, [rax + r12 * pixel_size] ; cargo 1 pixel
		movd xmm1, [rcx + r12 * pixel_size] ; cargo 1 pixel

		movdqu xmm2, xmm0
		pslldq xmm2, 4
		paddd xmm2, xmm0 
		movq [rbx + r12 * 2 * pixel_size], xmm2; me guardo el pixel original duplicado

		pxor xmm15, xmm15
		punpcklbw xmm0, xmm15
		punpcklbw xmm1, xmm15 ; desempaqueto los pixeles


		paddw xmm1, xmm0
		psrlw xmm1, 1 ; |(A+C)/2| en cada componente
		movdqu xmm2, xmm1
		pslldq xmm2, 8
		paddq xmm2, xmm1

		packuswb xmm2, xmm15
		movq [rdx +  r12 * 2 * pixel_size], xmm2 ; guardo el pixel intermedio duplicado


		.columnaLoop:
			dec r12

			movq xmm0, [rax + r12 * pixel_size] ; cargo 2 pixeles
			movq xmm1, [rcx + r12 * pixel_size] ; cargo 2 pixeles

			movdqu xmm2, xmm0
			movd r13d, xmm2
			movd xmm2, r13d ; me guardo el pixel original para despues

			pxor xmm15, xmm15
			movdqu xmm3, xmm2
			punpcklbw xmm3, xmm15
			movlhps xmm3, xmm3 ; copia del pixel duplicado y desempaquetado

			movdqu xmm4, xmm0
			psrldq xmm4, 4
			movdqu xmm5, xmm1
			pslldq xmm5, 4
			paddb xmm4, xmm5

			punpcklbw xmm4, xmm15 ; xmm4 = |C|B|

			paddw xmm3, xmm4
			psrlw xmm3, 1 ; xmm3 = |(A+C)/2|(A+B)/2|
			packuswb xmm3, xmm15
			pslldq xmm3, 4
			paddb xmm2, xmm3 ; xmm2 = |0|(A+C)/2|(A+B)/2|A|


			punpcklbw xmm1, xmm15
			punpcklbw xmm0, xmm15
			paddw xmm1, xmm0

			movq xmm0, xmm1
			psrldq xmm1, 8
			paddw xmm1, xmm0
			psrlw xmm1, 2 ; xmm1 = |?|(A+B+C+D)/4|

			packuswb xmm1, xmm15
			pslldq xmm1, 12 ; xmm1 = |(A+B+C+D)/4|0|0|0|

			paddb xmm2, xmm1 ; xmm2 = |(A+B+C+D)/4|(A+C)/2|(A+B)/2|A|

			movq [rbx +  r12 * 2 * pixel_size], xmm2 ; guardo los pixeles superiores
			psrldq xmm2, 8
			movq [rdx +  r12 * 2 * pixel_size], xmm2 ; guardo los pixeles inferiores


			cmp r12, 0
			ja .columnaLoop

		cmp r11, 1
		ja .filaLoop


	lea r12, [rsi - 1] ; R12 (Columna indice) = srcw - 1

	lea rbx, [r10 + r15]
	lea rdx, [r10]

	movd xmm15, [rdi + r12 * pixel_size]
	movdqu xmm14, xmm15
	pslldq xmm15, 4
	paddb xmm15, xmm14

	movq [rbx + r12 * 2 * pixel_size], xmm15
	movq [rdx + r12 * 2 * pixel_size], xmm15 ; copio el pixel de la esquina

	.ultimaFila:
		sub r12, 1

		movq xmm0, [rdi + r12 * pixel_size]

		pxor xmm15, xmm15
		punpcklbw xmm0, xmm15 ; xmm0 = |B|A|
		movdqu xmm1, xmm0
		movlhps xmm1, xmm1 ; xmm1 = |A|A|
		paddw xmm0, xmm1 ; xmm0 =  |A+B|A+A|
		psrlw xmm0, 1 ; xmm0 = |(A+B)/2|A|
		packuswb xmm0, xmm0

		; XMM0 = |(A+B)/2|A|(A+B)/2|A|

		movq [rbx + r12 * 2 * pixel_size], xmm0
		movq [rdx + r12 * 2 * pixel_size], xmm0 ; copio en la linea de abajo

		cmp r12, 0
		ja .ultimaFila


pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret