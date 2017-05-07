global ASM_fourCombine
extern C_fourCombine

%define CERO_FFS_LOW   0x00000000FFFFFFFF
%define CERO_FFS_HIGH  0x00000000FFFFFFFF

%define CERO_FFS2_LOW   0xFFFFFFFF00000000
%define CERO_FFS2_HIGH  0xFFFFFFFF00000000

%define SHUFFLE 11011000b

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

mov rax, rcx 
shl r15, 2
mov rcx, r15

shr r14, 1; w/2
.move_fila:
	add rax, r14 ; ancho columna * alto / 2 * pixel
	loop .move_fila
mov r10, rax; c3
mov r11, rax; c3

mov rcx, r14

.move_columna:
	add r9, PIXEL_OFFSET
	add r11, PIXEL_OFFSET
	loop .move_columna

shr rsi, 2 ; w/4
mov rax, rsi ;
shr rsi, 1 ; w/8
mov rcx, rsi


shl r14, 2

shr rdx, 1
mov r13, rdi
add r13, r14
add r13, r14
;mov rdx, 2
.row:
		.column:
		movdqu xmm1,[rdi];[4_F1,3_F1,2_F1,1_F1]
		add rdi, FOUR_PIXELS_OFFSET
		movdqu xmm2,[rdi];[8_F1,7_F1,6_F1,5_F1]
		add rdi, FOUR_PIXELS_OFFSET
		movdqu xmm5, xmm1 ; copy
		movdqu xmm6, xmm2 ; copy

		pand xmm1,xmm9;xmm2 = [0, 3, 0, 1] filtro [00,FF,00,FF]
		pand xmm2,xmm9;xmm3 = [0, 7, 0, 5] filtro [00,FF,00,FF]
		pslldq xmm2, PIXEL_OFFSET
					
		pand xmm5,xmm14;xmm4 = [4, 0, 2, 0] filtro [FF,00,FF,00]
		pand xmm6,xmm14;xmm5 = [8, 0, 6, 0] filtro [FF,00,FF,00]
		psrldq xmm5, PIXEL_OFFSET

		por xmm1, xmm2;xmm1 o xmm5 = xmm1
		por xmm5, xmm6;xmm2 o xmm6 = xmm2

		;tengo mis dos registros en xmm1 y xmm2 [8, 3, 6, 1] [4, 7, 2, 5] 
		pshufd xmm1, xmm1, SHUFFLE; aplico shuffle [7, 3, 5, 1] -> [7, 5, 3, 1]
		pshufd xmm2, xmm5, SHUFFLE; aplico shuffle [8, 4, 6, 2] -> [8, 6, 4, 2]

		movdqu xmm3,[r13];[4_F2,3_F2,2_F2,1_F2]
		add r13, FOUR_PIXELS_OFFSET
		movdqu xmm4,[r13];[8_F2,7_F2,6_F2,5_F2]
		add r13, FOUR_PIXELS_OFFSET
		movdqu xmm5, xmm3 ; copy
		movdqu xmm6, xmm4 ; copy

		

		pand xmm3,xmm9;xmm2 = [0, 3, 0, 1] filtro [00,FF,00,FF]
		pand xmm4,xmm9;xmm3 = [0, 7, 0, 5] filtro [00,FF,00,FF]
		pslldq xmm4, PIXEL_OFFSET
					
		pand xmm5,xmm14;xmm4 = [4, 0, 2, 0] filtro [FF,00,FF,00]
		pand xmm6,xmm14;xmm5 = [8, 0, 6, 0] filtro [FF,00,FF,00]
		psrldq xmm5, PIXEL_OFFSET

		por xmm3, xmm4;xmm1 o xmm5 = xmm1
		por xmm5, xmm6;xmm2 o xmm6 = xmm2

		;tengo mis dos registros en xmm1 y xmm2 [8, 3, 6, 1] [4, 7, 2, 5] 
		pshufd xmm3, xmm3, SHUFFLE; aplico shuffle [7, 3, 5, 1] -> [7, 5, 3, 1]
		pshufd xmm4, xmm5, SHUFFLE; aplico shuffle [8, 4, 6, 2] -> [8, 6, 4, 2]

		movdqu [r8], xmm1 ; write 4 pixels in c1
		movdqu [r9], xmm2 ; write 4 pixels in c2
		movdqu [r10], xmm3 ; write 4 pixels in c3
		movdqu [r11], xmm4 ; write 4 pixels in c4
		add r8, FOUR_PIXELS_OFFSET
		add r9, FOUR_PIXELS_OFFSET
		add r10, FOUR_PIXELS_OFFSET
		add r11, FOUR_PIXELS_OFFSET
		sub rcx, 1
		cmp rcx, 0
		je .row_after
		jmp .column
		;loop .column
	.row_after:	
	sub rdx, 1;
	cmp rdx, 0
	je .end	

	add rdi, r14
	add rdi, r14
	add r13, r14
	add r13, r14

	mov r8, r9; 
	add r9, r14; 

	mov r10, r11
	add r11, r14

	mov rcx, rsi ; vuelvo el conteo para la prox columna
	jmp .row

.end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret