global ASM_linearZoom
extern C_linearZoom

%define pixel_size 4

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

	pxor xmm15, xmm15
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

		pshufd xmm2, xmm0, 11_11_00_00b
		movq [rbx + r12 * 2 * pixel_size], xmm2; me guardo el pixel original duplicado

		punpcklbw xmm0, xmm15
		punpcklbw xmm1, xmm15 ; desempaqueto los pixeles

		paddw xmm1, xmm0
		psrlw xmm1, 1 ; |(A+C)/2| en cada componente

		packuswb xmm1, xmm15
		pshufd xmm1, xmm1, 11_11_00_00b
		movq [rdx +  r12 * 2 * pixel_size], xmm1 ; guardo el pixel intermedio duplicado

		.columnaLoop:
			dec r12

			movq xmm0, [rax + r12 * pixel_size] ; cargo 2 pixeles
			movq xmm1, [rcx + r12 * pixel_size] ; cargo 2 pixeles

			pxor xmm2, xmm2
			pblendw xmm2, xmm0, 00_00_00_11b ; me guardo el pixel original para despues

			punpcklbw xmm0, xmm15
			punpcklbw xmm1, xmm15

			pshufd xmm3, xmm0, 01_00_01_00b ; xmm3 = |A|A|

			pshufd xmm4, xmm0, 11_10_11_10b ; xmm4 = |B|B|
			pshufd xmm5, xmm1, 01_00_01_00b ; xmm5 = |C|C|
			pblendw xmm4, xmm5, 1111_0000b ; xmm4 = |C|B|

			paddw xmm3, xmm4
			psrlw xmm3, 1 ; xmm3 = |(A+C)/2|(A+B)/2|

			packuswb xmm3, xmm3 ; xmm3 = |(A+C)/2|(A+B)/2|(A+C)/2|(A+B)/2|
			pshufd xmm3, xmm3, 11_01_00_11b ; xmm3 = |0|(A+C)/2|(A+B)/2|0|
			pblendw xmm2, xmm3, 00_11_11_00b ; xmm2 = |0|(A+C)/2|(A+B)/2|A|

			paddw xmm1, xmm0 ; xmm1 = |(B+D)|(A+C)|
			pshufd xmm0, xmm1, 01_00_11_10b ; xmm0 = |(A+C)|(B+D)|
			paddw xmm1, xmm0 ; xmm1 = |(A+B+C+D)|(A+B+C+D)|
			psrlw xmm1, 2 ; xmm1 = |(A+B+C+D)/4|(A+B+C+D)/4|

			packuswb xmm1, xmm1 ; xmm1 = |(A+B+C+D)/4|(A+B+C+D)/4|(A+B+C+D)/4|(A+B+C+D)/4|

			pblendw xmm2, xmm1, 11_00_00_00b ; xmm2 = |(A+B+C+D)/4|(A+C)/2|(A+B)/2|A|

			movq [rbx +  r12 * 2 * pixel_size], xmm2 ; guardo los pixeles superiores
			movhps [rdx +  r12 * 2 * pixel_size], xmm2 ; guardo los pixeles inferiores

			cmp r12, 0
			ja .columnaLoop

		cmp r11, 1
		ja .filaLoop

	lea r12, [rsi - 1] ; R12 (Columna indice) = srcw - 1

	lea rbx, [r10 + r15]
	lea rdx, [r10]

	movd xmm15, [rdi + r12 * pixel_size]

	pshufd xmm15, xmm15, 11_11_00_00b

	movq [rbx + r12 * 2 * pixel_size], xmm15
	movq [rdx + r12 * 2 * pixel_size], xmm15 ; copio el pixel de la esquina

	.ultimaFila:
		sub r12, 1

		movq xmm0, [rdi + r12 * pixel_size]

		pxor xmm15, xmm15
		punpcklbw xmm0, xmm15 ; xmm0 = |B|A|
		pshufd xmm1, xmm0, 01_00_01_00b ; xmm1 = |A|A|
		paddw xmm0, xmm1 ; xmm0 =  |A+B|A+A|
		psrlw xmm0, 1 ; xmm0 = |(A+B)/2|A|
		packuswb xmm0, xmm15

		; XMM0 = |0|0|(A+B)/2|A|

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