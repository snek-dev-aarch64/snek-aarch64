.include "src/screen.s"
.include "src/snek.s"
.include "src/food.s"

.equ RAND_SEED, 213

.equ BLACK,     0x00000000
.equ WHITE,     0x00FFFFFF
.equ CYAN,      0x0046878F
.equ GB_DGREEN, 0x003D4130
.equ GB_LGREEN, 0x00C4D0A2
.equ RED, 0x00FF0000

.data
    random_seed: .word RAND_SEED
    background:  .word GB_LGREEN
    foreground:  .word GB_DGREEN
    food:        .word RED
    snek:
        .word GB_DGREEN
        .word SNEK_INITIAL_SIZE
        .word 0
        .word SNEK_INITIAL_SIZE - 1
        .word SNEK_MAXIMUM_SIZE
        .skip 4 * SNEK_MAXIMUM_SIZE

.text
.globl main
main:
    mov x20, x0 /* FRAMEBUFFER */

    ldr x0, random_seed
    bl srand

    adr x0, snek
    mov x1, SNEK_INITIAL_X
    mov x2, SNEK_INITIAL_Y
    bl init_snek

    mov x0, x20
    ldr w3, background
    bl init_screen

    mov x0, x20
    adr x1, snek
    bl draw_snek

    adr x0, snek
    mov x1, 9
    mov x2, 4
    bl snek_push

    adr x0, snek
    bl snek_head

    mov x0, x20
    ldr w3, foreground
    mov x4, SNEK_BLOCK_PADDING
    bl block

    adr x0, snek
    bl snek_last

    mov x0, x20
    ldr w3, background
    mov x4, SNEK_BLOCK_PADDING
    bl block

    adr x0, snek
    bl snek_pop

    adr x0, snek
    mov x1, 9
    mov x2, 5
    bl snek_push

    adr x0, snek
    bl snek_head

    mov x0, x20
    ldr w3, foreground
    mov x4, SNEK_BLOCK_PADDING
    bl block

    mov x0, x20
    mov x1, 0
    mov x2, 0
    ldr w3, foreground
    bl point

    adr x0, snek
    bl new_food

    mov x21, 20
loop:
    cbz x21, _loop

    adr x0, snek
    bl new_food

    mov x2, x1
    mov x1, x0
    mov x0, x20
    ldr w3, food
    bl point

    sub x21, x21, 1
    b loop

_loop:

InfLoop:
    b InfLoop
