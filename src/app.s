.include "src/screen.s"
.include "src/snek.s"

.equ BLACK, 0x00000000
.equ WHITE, 0x00FFFFFF

.data
    gb_green:  .word 0x00CADC9F
    cyan:      .word 0x0046878F
    snek_size: .word SNEK_INITIAL_SIZE
    snek:      .skip MAX_WIDTH * MAX_HEIGHT

.text
.globl main
main:
    mov x20, x0 /* FRAMEBUFFER */

    adr x0, snek
    mov x1, SNEK_INITIAL_X
    mov x2, SNEK_INITIAL_Y
    bl init_snek

    mov x0, x20
    ldr w3, gb_green
    bl init_screen

    mov x0, x20
    mov x1, MAX_WIDTH
    mov x2, MAX_HEIGHT
    ldr w3, cyan
    bl point

    mov x0, x20
    adr x1, snek
    ldr x2, snek_size
    ldr w3, cyan
    bl draw_snek

    mov x0, x20
    mov x1, 0
    mov x2, 0
    ldr w3, cyan
    bl point

InfLoop:
    b InfLoop
