global ASM_fourCombine
extern C_fourCombine

%define CERO_FFS_LOW   0x00000000FFFFFFFF
%define CERO_FFS_HIGH  0x00000000FFFFFFFF

%define CERO_FFS2_LOW   0xFFFFFFFF00000000
%define CERO_FFS2_HIGH  0xFFFFFFFF00000000

%define SHUFFLE 11011000b

%define ODD_CHECK 00000001b 

%define FOUR_PIXELS_OFFSET 16
%define PIXEL_OFFSET 4
 

section .text


ASM_fourCombine:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15

mov rax, CERO_FFS_LOW
movq xmm9, rax
pslldq xmm9, 8
mov rax, CERO_FFS_HIGH
movq xmm0, rax
paddq xmm9, xmm0

mov rax, CERO_FFS2_LOW
movq xmm14, rax
pslldq xmm14, 8
mov rax, CERO_FFS2_HIGH
movq xmm0, rax
paddq xmm14, xmm0

xor r14, r14
xor r14, r15

mov r14, rsi;w
mov r15, rdx;h

mov r8, rcx ; c1
mov r9, rcx ; c1

shl r15, 2
mov rcx, r15

shr r14, 1; w/2

push rcx
push rdx
mov rax, r14
mul r15
pop rdx
pop rcx
add rax, r8

mov r10, rax; c3
mov r11, rax; c3

mov rcx, r14

push rcx
push rdx
mov rax, r14
mov ebx, PIXEL_OFFSET
mul ebx
pop rdx
pop rcx
add r9, rax
add r11, rax

shr rsi, 2 ; w/4
mov rax, rsi ;
shr rsi, 1 ; w/4

mov rcx, rsi

shl r14, 2
mov r12, rdi

mov rax, rdx; x = a
mov rdx, rcx; a = c
mov rcx, rax; c = x


push r11
push r10
push r9
push r8

mov r13, rcx

.row:
	.column:
			movdqu xmm2, [rdi]
			movdqu xmm3, [rdi + FOUR_PIXELS_OFFSET]
			movdqu xmm4, xmm2
			movdqu xmm5, xmm3

			pand xmm2,xmm9;xmm2 = [0, 3, 0, 1] filtro [00,FF,00,FF]
			pand xmm3,xmm9;xmm3 = [0, 7, 0, 5] filtro [00,FF,00,FF]
			pslldq xmm3, PIXEL_OFFSET
			
			pand xmm4,xmm14;xmm4 = [4, 0, 2, 0] filtro [FF,00,FF,00]
			pand xmm5,xmm14;xmm5 = [8, 0, 6, 0] filtro [FF,00,FF,00]
			psrldq xmm4, PIXEL_OFFSET

			por xmm2, xmm3;xmm2 o xmm3 = xmm0
			por xmm4, xmm5;xmm3 o xmm5 = xmm1

			;tengo mis dos registros en xmm0 y xmm1 [8, 3, 6, 1] [4, 7, 2, 5] 
			pshufd xmm2, xmm2, SHUFFLE; aplico shuffle [7, 3, 5, 1] -> [7, 5, 3, 1]
			pshufd xmm4, xmm4, SHUFFLE; aplico shuffle [8, 4, 6, 2] -> [8, 6, 4, 2]

			movdqu [r8], xmm2 ; guarda 4 pixeles en el cuadrante 1 o 3
			movdqu [r9], xmm4 ; guarda 4 pixeles en el cuadrante 2 o 4 
			
			sub rcx, 1;
			cmp rcx, 0
			je .after_column

			add r8, r14
			add r8, r14
			add r9, r14
			add r9, r14

			mov rax, r8; x = a
			mov r8, r10; a = c
			mov r10, rax; c = x
			mov rax, r9; x = b
			mov r9, r11; b = d
			mov r11, rax; d = x 

			

			add rdi, r14
			add rdi, r14

			jmp .column
		.after_column:	
		sub rdx, 1;
		cmp rdx, 0
		je .end	

		pop r8
		pop r9
		pop r10
		pop r11

		add r8, FOUR_PIXELS_OFFSET

		add r9, FOUR_PIXELS_OFFSET

		add r10, FOUR_PIXELS_OFFSET

		add r11, FOUR_PIXELS_OFFSET

		push r11
		push r10
		push r9
		push r8

		mov rdi, r12
		add rdi, FOUR_PIXELS_OFFSET
		add rdi, FOUR_PIXELS_OFFSET
		mov r12, rdi

		mov rcx, r13 ; vuelvo el conteo para la prox columna
		jmp .row

.end:
	pop rdi
	pop rdi
	pop rdi
	pop rdi

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret