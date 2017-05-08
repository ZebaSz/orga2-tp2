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
    movdqu xmm4, [rdi + r11 * pixel_size] ; load 4 pixels

    movdqa xmm2, xmm4
    punpckhbw xmm2, xmm0 ; prepare to unpack first two pixels

    movdqa xmm1, xmm2
    punpckhwd xmm1, xmm0 ; unpack first pixel
    punpcklwd xmm2, xmm0 ; unpack second pixel

    punpcklbw xmm4, xmm0 ; prepare to unpack last two pixels

    movdqa xmm3, xmm4
    punpckhbw xmm3, xmm0 ; unpack third pixel
    punpcklbw xmm4, xmm0 ; unpack fourth pixel

    ; CONVERSION
    psubd xmm1, xmm13 ; subtract from all components of first pixel
    psubd xmm2, xmm13 ; subtract from all components of second pixel
    psubd xmm3, xmm13 ; subtract from all components of third pixel
    psubd xmm4, xmm13 ; subtract from all components of fourth pixel

    ; FIRST PIXEL
    movdqa xmm14, xmm1 ; get the first pixel
    pmulld xmm14, xmm9 ; do R multiplications
    ; XMM14 = |Ry|Ru|Rv|0|

    movdqa xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Ry+u|Rv|Gy+u|Gv|

    pmulld xmm1, xmm11 ; do B multiplications
    phaddd xmm1, xmm1 ; xmm1 = |By+u|Bv|By+u|Bv|

    phaddd xmm1, xmm15 ; xmm1 = |R|G|B|B|

    paddd xmm1, xmm12
    psrad xmm1, 8

    ; SECOND PIXEL
    movdqa xmm14, xmm2 ; get the second pixel
    pmulld xmm14, xmm9 ; do R multiplications
    ; XMM14 = |Ry|Ru|Rv|0|

    movdqa xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Ry+u|Rv|Gy+u|Gv|

    pmulld xmm2, xmm11 ; do B multiplications
    phaddd xmm2, xmm2 ; xmm2 = |By+u|Bv|By+u|Bv|

    phaddd xmm2, xmm15 ; xmm2 = |R|G|B|B|

    paddd xmm2, xmm12
    psrad xmm2, 8

    ; THIRD PIXEL
    movdqa xmm14, xmm3 ; get the third pixel
    pmulld xmm14, xmm9 ; do R multiplications
    ; XMM14 = |Ry|Ru|Rv|0|

    movdqa xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Ry+u|Rv|Gy+u|Gv|

    pmulld xmm3, xmm11 ; do B multiplications
    phaddd xmm3, xmm3 ; xmm3 = |By+u|Bv|By+u|Bv|

    phaddd xmm3, xmm15 ; xmm3 = |R|G|B|B|

    paddd xmm3, xmm12
    psrad xmm3, 8

    ; FOURTH PIXEL
    movdqa xmm14, xmm4 ; get the first pixel
    pmulld xmm14, xmm9 ; do R multiplications
    ; XMM14 = |Ry|Ru|Rv|0|

    movdqa xmm15, xmm4 ; get the first pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Ry+u|Rv|Gy+u|Gv|

    pmulld xmm4, xmm11 ; do B multiplications
    phaddd xmm4, xmm4 ; xmm4 = |By+u|Bv|By+u|Bv|

    phaddd xmm4, xmm15 ; xmm4 = |R|G|B|B|

    paddd xmm4, xmm12
    psrad xmm4, 8

    ; /CONVERSION

    packusdw xmm2, xmm1 ; pack first and second pixel together
    packusdw xmm4, xmm3 ; pack third and fourth pixel together

    packuswb xmm4, xmm2 ; repack all pixels

    movdqu [rcx + r11 * pixel_size], xmm4 ; store 4 pixels

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
; xmm0 : zeroes
; xmm1-4 : input/output pixels
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
    movdqu xmm4, [rdi + r11 * pixel_size] ; load 4 pixels

    movdqa xmm2, xmm4
    punpckhbw xmm2, xmm0 ; prepare to unpack first two pixels

    movdqa xmm1, xmm2
    punpckhwd xmm1, xmm0 ; unpack first pixel
    punpcklwd xmm2, xmm0 ; unpack second pixel

    punpcklbw xmm4, xmm0 ; prepare to unpack last two pixels
    movdqa xmm3, xmm4
    punpckhbw xmm3, xmm0 ; unpack third pixel
    punpcklbw xmm4, xmm0 ; unpack fourth pixel

    ; CONVERSION

    ; FIRST PIXEL
    movdqa xmm14, xmm1 ; get the first pixel
    pmulld xmm14, xmm9 ; do Y multiplications
    ; XMM14 = |Yr|Yg|Yb|0|

    movdqa xmm15, xmm1 ; get the first pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Yr+b|Yg|Ur+b|Ug|

    pmulld xmm1, xmm11 ; do V multiplications
    phaddd xmm1, xmm1 ; xmm1 = |Vr+b|Vg|Vr+b|Vg|

    phaddd xmm1, xmm15 ; xmm1 = |Y|U|V|V|

    paddd xmm1, xmm12
    psrad xmm1, 8
    paddd xmm1, xmm13

    ; SECOND PIXEL
    movdqa xmm14, xmm2 ; get the second pixel
    pmulld xmm14, xmm9 ; do Y multiplications
    ; XMM14 = |Yr|Yg|Yb|0|

    movdqa xmm15, xmm2 ; get the second pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Yr+b|Yg|Ur+b|Ug|

    pmulld xmm2, xmm11 ; do V multiplications
    phaddd xmm2, xmm2 ; xmm2 = |Vr+b|Vg|Vr+b|Vg|

    phaddd xmm2, xmm15 ; xmm2 = |Y|U|V|V|

    paddd xmm2, xmm12
    psrad xmm2, 8
    paddd xmm2, xmm13

    ; THIRD PIXEL
    movdqa xmm14, xmm3 ; get the third pixel
    pmulld xmm14, xmm9 ; do Y multiplications
    ; XMM14 = |Yr|Yg|Yb|0|

    movdqa xmm15, xmm3 ; get the third pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Yr+b|Yg|Ur+b|Ug|

    pmulld xmm3, xmm11 ; do V multiplications
    phaddd xmm3, xmm3 ; xmm3 = |Vr+b|Vg|Vr+b|Vg|

    phaddd xmm3, xmm15 ; xmm3 = |Y|U|V|V|

    paddd xmm3, xmm12
    psrad xmm3, 8
    paddd xmm3, xmm13

    ; FOURTH PIXEL
    movdqa xmm14, xmm4 ; get the fourth pixel
    pmulld xmm14, xmm9 ; do Y multiplications
    ; XMM14 = |Yr|Yg|Yb|0|

    movdqa xmm15, xmm4 ; get the fourth pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Yr+b|Yg|Ur+b|Ug|

    pmulld xmm4, xmm11 ; do V multiplications
    phaddd xmm4, xmm4 ; xmm4 = |Vr+b|Vg|Vr+b|Vg|

    phaddd xmm4, xmm15 ; xmm4 = |Y|U|V|V|

    paddd xmm4, xmm12
    psrad xmm4, 8
    paddd xmm4, xmm13

    ; /CONVERSION

    packusdw xmm2, xmm1 ; pack first and second pixel together
    packusdw xmm4, xmm3 ; pack third and fourth pixel together

    packuswb xmm4, xmm2 ; repack all pixels

    movdqu [rcx + r11 * pixel_size], xmm4 ; store 4 pixels

    add r11, 4
    cmp r10, r11 ; for index < pixel amount
    ja ASM_convertRGBtoYUV_loop
ret