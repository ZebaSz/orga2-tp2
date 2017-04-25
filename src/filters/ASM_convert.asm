global ASM_convertYUVtoRGB
global ASM_convertRGBtoYUV
extern C_convertYUVtoRGB
extern C_convertRGBtoYUV

%define pixel_size 4

%define RGB_Y_MASK_TOP 0x0000004200000081
%define RGB_Y_MASK_BOT 0x0000001900000000
%define RGB_U_MASK_TOP 0xFFFFFFDAFFFFFFB6
%define RGB_U_MASK_BOT 0x0000007000000000
%define RGB_V_MASK_TOP 0x00000070FFFFFFA2
%define RGB_V_MASK_BOT 0xFFFFFFEE00000000

%define YUV_R_MASK_TOP 0x0000000000000000 ; TODO
%define YUV_R_MASK_BOT 0x0000000000000000 ; TODO
%define YUV_G_MASK_TOP 0x0000000000000000 ; TODO
%define YUV_G_MASK_BOT 0x0000000000000000 ; TODO
%define YUV_B_MASK_TOP 0x0000000000000000 ; TODO
%define YUV_B_MASK_BOT 0x0000000000000000 ; TODO


section .text

; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth)

; PRE: srcw == dstw
; PRE: srch == dsth
; PRE: srcw % 4 == 0

ASM_convertYUVtoRGB:
ret


; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth)

; PRE: srcw == dstw
; PRE: srch == dsth
; PRE: srcw % 4 == 0

; use XMMs as follows:
; xmm0: input/output pixel chain
; xmm1-4 : input pixels
; xmm5-8 : output pixels
; xmm9-11 : conversion masks
; xmm12-15 : scratch

ASM_convertRGBtoYUV:
; ARMADO DE STACKFRAME
push rbp
mov rbp, rsp
sub rsp, 8 ; necesario para alinear, modificar para agregar variables locales
push rbx
push r12
push r13
push r14
push r15
; /ARMADO DE STACKFRAME

; create masks
mov r15, RGB_Y_MASK_TOP
movq xmm9, r15
pslldq xmm9, 8
mov r15, RGB_Y_MASK_BOT
movq xmm0, r15
paddq xmm9, xmm0

mov r15, RGB_U_MASK_TOP
movq xmm10, r15
pslldq xmm10, 8
mov r15, RGB_U_MASK_BOT
movq xmm0, r15
paddq xmm10, xmm0

mov r15, RGB_V_MASK_TOP
movq xmm11, r15
pslldq xmm11, 8
mov r15, RGB_V_MASK_BOT
movq xmm0, r15
paddq xmm11, xmm0

mov eax, esi
mul edx
mov eax, eax
mov r10, rax ; multiply matrix size to get full pixel ammount

xor r11, r11 ; set index to 0
ASM_convertRGBtoYUV_loop:
    movdqu xmm0, [rdi + r11 * pixel_size] ; load 4 pixels

    pxor xmm14, xmm14

    movdqu xmm15, xmm0
    punpckhbw xmm15, xmm14 ; prepare to unpack first two pixels

    movdqu xmm1, xmm15
    punpckhwd xmm1, xmm14 ; unpack first pixel
    movdqu xmm2, xmm15
    punpcklwd xmm2, xmm14 ; unpack second pixel

    movdqu xmm15, xmm0
    punpcklbw xmm15, xmm14 ; prepare to unpack last two pixels
    movdqu xmm3, xmm15
    punpckhbw xmm3, xmm14 ; unpack third pixel
    movdqu xmm4, xmm15
    punpcklbw xmm4, xmm14 ; unpack fourth pixel

    ; CONVERSION

    ; FIRST PIXEL
    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    add eax, 128
    sar eax, 8
    add eax, 16
    movd xmm5, eax
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    ; SECOND PIXEL
    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    add eax, 128
    sar eax, 8
    add eax, 16
    movd xmm6, eax
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    ; THIRD PIXEL
    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    add eax, 128
    sar eax, 8
    add eax, 16
    movd xmm7, eax
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    ; FOURTH PIXEL
    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    add eax, 128
    sar eax, 8
    add eax, 16
    movd xmm8, eax
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    add eax, 128
    sar eax, 8
    add eax, 128
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    ; /CONVERSION

    packusdw xmm6, xmm5 ; pack first and second pixel together
    packusdw xmm8, xmm7 ; pack third and fourth pixel together

    packuswb xmm8, xmm6 ; repack all pixels
    movdqu xmm0, xmm8

    movdqu [rcx + r11 * pixel_size], xmm0 ; store 4 pixels

    add r11, 4
    cmp r10, r11 ; for index < pixel amount
    ja ASM_convertRGBtoYUV_loop

; DESARMADO DE STACKFRAME
pop r15
pop r14
pop r13
pop r12
pop rbx
add rsp, 8 ; necesario para alinear, modificar para agregar variables locales
pop rbp
; /DESARMADO DE STACKFRAME
ret