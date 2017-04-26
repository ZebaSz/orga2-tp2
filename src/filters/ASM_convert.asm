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

%define RGB_SHF_PRE_MASK 0x0080008000800000
%define RGB_SHF_POST_MASK 0x0010008000800000

%define YUV_R_MASK_TOP 0x0000012A00000000
%define YUV_R_MASK_BOT 0x0000019900000000
%define YUV_G_MASK_TOP 0x0000012AFFFFFF9C
%define YUV_G_MASK_BOT 0xFFFFFF2F00000000
%define YUV_B_MASK_TOP 0x0000012A00000204
%define YUV_B_MASK_BOT 0x0000000000000000


section .text

; rdi(uint8_t* src), esi(uint32_t srcw), edx(uint32_t srch),
; rcx(uint8_t* dst), r8d (uint32_t dstw), r9d(uint32_t dsth)

; PRE: srcw == dstw
; PRE: srch == dsth
; PRE: srcw % 4 == 0

ASM_convertYUVtoRGB:
; create masks
mov rax, YUV_R_MASK_TOP
movq xmm9, rax
pslldq xmm9, 8
mov rax, YUV_R_MASK_BOT
movq xmm0, rax
paddq xmm9, xmm0

mov rax, YUV_G_MASK_TOP
movq xmm10, rax
pslldq xmm10, 8
mov rax, YUV_G_MASK_BOT
movq xmm0, rax
paddq xmm10, xmm0

mov rax, YUV_B_MASK_TOP
movq xmm11, rax
pslldq xmm11, 8
mov rax, YUV_B_MASK_BOT
movq xmm0, rax
paddq xmm11, xmm0

pxor xmm0, xmm0
mov rax, RGB_SHF_PRE_MASK
movq xmm12, rax
punpcklwd xmm12, xmm0

mov rax, RGB_SHF_POST_MASK
movq xmm13, rax
punpcklwd xmm13, xmm0

mov eax, esi
mul edx
mov eax, eax
mov r10, rax ; multiply matrix size to get full pixel ammount

xor r11, r11 ; set index to 0
ASM_convertYUVtoRGB_loop:
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
    psubd xmm1, xmm13 ; subtract from all components of first pixel
    psubd xmm2, xmm13 ; subtract from all components of second pixel
    psubd xmm3, xmm13 ; subtract from all components of third pixel
    psubd xmm4, xmm13 ; subtract from all components of fourth pixel

    ; FIRST PIXEL
    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm9 ; do R multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new R value
    movd xmm5, eax
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new G value
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm11 ; do B multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new B value
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    paddd xmm5, xmm12
    psrad xmm5, 8

    ; SECOND PIXEL
    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm6, eax
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    paddd xmm6, xmm12
    psrad xmm6, 8

    ; THIRD PIXEL
    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm7, eax
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    paddd xmm7, xmm12
    psrad xmm7, 8

    ; FOURTH PIXEL
    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm8, eax
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    paddd xmm8, xmm12
    psrad xmm8, 8

    ; /CONVERSION

    packusdw xmm6, xmm5 ; pack first and second pixel together
    packusdw xmm8, xmm7 ; pack third and fourth pixel together

    packuswb xmm8, xmm6 ; repack all pixels
    movdqu xmm0, xmm8

    movdqu [rcx + r11 * pixel_size], xmm0 ; store 4 pixels

    add r11, 4
    cmp r10, r11 ; for index < pixel amount
    ja ASM_convertYUVtoRGB_loop
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
; xmm9-13 : conversion masks
; xmm14-15 : scratch

ASM_convertRGBtoYUV:
; create masks
mov rax, RGB_Y_MASK_TOP
movq xmm9, rax
pslldq xmm9, 8
mov rax, RGB_Y_MASK_BOT
movq xmm0, rax
paddq xmm9, xmm0

mov rax, RGB_U_MASK_TOP
movq xmm10, rax
pslldq xmm10, 8
mov rax, RGB_U_MASK_BOT
movq xmm0, rax
paddq xmm10, xmm0

mov rax, RGB_V_MASK_TOP
movq xmm11, rax
pslldq xmm11, 8
mov rax, RGB_V_MASK_BOT
movq xmm0, rax
paddq xmm11, xmm0

pxor xmm0, xmm0
mov rax, RGB_SHF_PRE_MASK
movq xmm12, rax
punpcklwd xmm12, xmm0

mov rax, RGB_SHF_POST_MASK
movq xmm13, rax
punpcklwd xmm13, xmm0

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
    movd xmm5, eax
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    movdqu xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm5, xmm15
    pslldq xmm5, 4

    paddd xmm5, xmm12
    psrad xmm5, 8
    paddd xmm5, xmm13

    ; SECOND PIXEL
    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm6, eax
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    movdqu xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm6, xmm15
    pslldq xmm6, 4

    paddd xmm6, xmm12
    psrad xmm6, 8
    paddd xmm6, xmm13

    ; THIRD PIXEL
    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm7, eax
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new u value
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    movdqu xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm7, xmm15
    pslldq xmm7, 4

    paddd xmm7, xmm12
    psrad xmm7, 8
    paddd xmm7, xmm13

    ; FOURTH PIXEL
    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm9 ; do Y multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm8, eax
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new y value
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    movdqu xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm11 ; do V multiplications
    phaddd xmm15, xmm15
    phaddd xmm15, xmm15 ; add components
    movd eax, xmm15 ; get dword with new v value
    movd xmm15, eax
    paddd xmm8, xmm15
    pslldq xmm8, 4

    paddd xmm8, xmm12
    psrad xmm8, 8
    paddd xmm8, xmm13

    ; /CONVERSION

    packusdw xmm6, xmm5 ; pack first and second pixel together
    packusdw xmm8, xmm7 ; pack third and fourth pixel together

    packuswb xmm8, xmm6 ; repack all pixels
    movdqu xmm0, xmm8

    movdqu [rcx + r11 * pixel_size], xmm0 ; store 4 pixels

    add r11, 4
    cmp r10, r11 ; for index < pixel amount
    ja ASM_convertRGBtoYUV_loop
ret