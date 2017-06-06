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
    movd xmm1, [rdi + r11 * pixel_size] ; load pixel

    punpcklbw xmm1, xmm0 ; unpack pixel
    punpcklwd xmm1, xmm0

    ; CONVERSION
    psubd xmm1, xmm13 ; subtract from all components pixel

    movdqa xmm14, xmm1 ; get the pixel
    pmulld xmm14, xmm9 ; do R multiplications
    ; XMM14 = |Ry|Ru|Rv|0|

    movdqa xmm15, xmm1 ; get the pixel
    pmulld xmm15, xmm10 ; do G multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Ry+u|Rv|Gy+u|Gv|

    pmulld xmm1, xmm11 ; do B multiplications
    phaddd xmm1, xmm1 ; xmm1 = |By+u|Bv|By+u|Bv|

    phaddd xmm1, xmm15 ; xmm1 = |R|G|B|B|

    paddd xmm1, xmm12
    psrad xmm1, 8

    ; /CONVERSION

    packusdw xmm1, xmm0 ; pack pixel
    packuswb xmm1, xmm0

    movd [rcx + r11 * pixel_size], xmm1; store pixel

    add r11, 1
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
; xmm1 : input/output pixel
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
    movd xmm1, [rdi + r11 * pixel_size] ; load 4 pixels

    punpcklbw xmm1, xmm0 ; prepare to unpack last two pixels
    punpcklwd xmm1, xmm0 ; unpack fourth pixel

    ; CONVERSION

    movdqa xmm14, xmm1 ; get the pixel
    pmulld xmm14, xmm9 ; do Y multiplications
    ; XMM14 = |Yr|Yg|Yb|0|

    movdqa xmm15, xmm1 ; get the pixel
    pmulld xmm15, xmm10 ; do U multiplications
    phaddd xmm15, xmm14 ; XMM15 = |Yr+b|Yg|Ur+b|Ug|

    pmulld xmm1, xmm11 ; do V multiplications
    phaddd xmm1, xmm1 ; xmm1 = |Vr+b|Vg|Vr+b|Vg|

    phaddd xmm1, xmm15 ; xmm1 = |Y|U|V|V|

    paddd xmm1, xmm12
    psrad xmm1, 8
    paddd xmm1, xmm13

    ; /CONVERSION

    packusdw xmm1, xmm0 ; pack pixel
    packuswb xmm1, xmm0

    movd [rcx + r11 * pixel_size], xmm1 ; store 4 pixels

    add r11, 1
    cmp r10, r11 ; for index < pixel amount
    ja ASM_convertRGBtoYUV_loop
ret