.include "src/screen.s"
.include "src/snek.s"

.equ BLACK,    0x00000000
.equ WHITE,    0x00FFFFFF
.equ CYAN,     0x0046878F
.equ GB_GREEN, 0x00CADC9F

.data
    background: .word GB_GREEN
    foreground: .word CYAN
    snek:
        .word CYAN
        .word SNEK_INITIAL_SIZE
        .word 0
        .word SNEK_INITIAL_SIZE - 1
        .word SNEK_MAXIMUM_SIZE
        .skip 4 * SNEK_MAXIMUM_SIZE

.text
.globl main
main:
    mov x20, x0 /* FRAMEBUFFER */

    adr x0, snek
    mov x1, SNEK_INITIAL_X
    mov x2, SNEK_INITIAL_Y
    bl init_snek

    mov x0, x20
    ldr w3, background
    bl init_screen

    mov x0, x20
    mov x1, MAX_WIDTH
    mov x2, MAX_HEIGHT
    ldr w3, foreground
    bl point

    mov x0, x20
    adr x1, snek
    bl draw_snek

    mov x0, x20
    mov x1, 0
    mov x2, 0
    ldr w3, foreground
    bl point

InfLoop:
    b InfLoop
