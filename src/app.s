.include "src/screen.s"
.include "src/snek.s"
.include "src/food.s"

.equ RAND_SEED, 0x1EA7A55

.equ BLOCK_PADDING, SCALE_FACTOR / 10

.equ BLACK,     0x00000000
.equ WHITE,     0x00FFFFFF
.equ CYAN,      0x0046878F
.equ GB_DGREEN, 0x003D4130
.equ GB_LGREEN, 0x00C4D0A2
.equ RED,       0x00FF0000

.equ DIR_UP,     1
.equ DIR_DOWN,  -1
.equ DIR_RIGHT,  2
.equ DIR_LEFT,  -2

.data
    random_seed: .dword RAND_SEED
    background:  .word  GB_LGREEN
    foreground:  .word  GB_DGREEN
    food_color:  .word  RED
    food_x:      .word  12
    food_y:      .word  4
    snek:
        .word DIR_UP
        .word GB_DGREEN
        .word SNEK_INITIAL_SIZE
        .word 0
        .word SNEK_INITIAL_SIZE - 1
        .word SNEK_MAXIMUM_SIZE
        .skip 4 * SNEK_MAXIMUM_SIZE

.text
.globl main
main:
    mov x19, x0 /* FRAMEBUFFER */

    ldr x0, random_seed
    bl srand

    adr x0, snek
    mov x1, SNEK_INITIAL_X
    mov x2, SNEK_INITIAL_Y
    bl init_snek

    mov x0, x19
    bl init_screen

    mov x0, x19
    adr x1, snek
    bl draw_snek

    mov x0, x19
    ldr w1, food_x
    ldr w2, food_y
    ldr w3, food_color
    bl tiled_circle

infloop:
    b infloop
