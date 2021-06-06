.include "src/screen.s"
.include "src/snek.s"
.include "src/food.s"

.equ RAND_SEED, 213

.equ BLACK,     0x00000000
.equ WHITE,     0x00FFFFFF
.equ CYAN,      0x0046878F
.equ GB_DGREEN, 0x003D4130
.equ GB_LGREEN, 0x00C4D0A2
.equ RED,       0x00FF0000

.equ DIR_UP,    0
.equ DIR_DOWN,  1
.equ DIR_RIGHT, 2
.equ DIR_LEFT,  3

.data
    random_seed: .word RAND_SEED
    background:  .word GB_LGREEN
    foreground:  .word GB_DGREEN
    food_color:  .word RED
    food_x:      .word 0
    food_y:      .word 0
    snek:
        .word DIR_RIGHT
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

    mov x0, x20
    adr x1, snek
    b game_loop_init

/*
    Subroutine: game_loop

    Brief:
        Game's main loop

    Params:
        x0 - framebuffer
        x1 - snek base address
*/
game_loop_init:
    mov x19, x0
    mov x20, x1

game_loop:
    mov x0, x20
    bl snek_head

    ldr w21, [x20, SNEK_DIRECTION_OFFSET]

    cmp w21, DIR_UP
    beq game_loop_up

    cmp w21, DIR_DOWN
    beq game_loop_down

    cmp w21, DIR_RIGHT
    beq game_loop_right

    cmp w21, DIR_LEFT
    beq game_loop_left

game_loop_up:
    add x2, x2, 1
    b game_loop_food

game_loop_down:
    sub x2, x2, 1
    b game_loop_food

game_loop_right:
    add x1, x1, 1
    b game_loop_food

game_loop_left:
    sub x1, x1, 1

game_loop_food:
    mov x0, x20
    bl snek_push

    mov x0, x20
    bl snek_head

    ldr w21, food_x
    ldr w22, food_y

    cmp w1, w21
    bne game_loop_continue_pop
    cmp w2, w22
    bne game_loop_continue_pop

    b game_loop_continue

game_loop_continue_pop:
    mov x0, x20
    bl snek_last

    mov x0, x19
    ldr w3, background
    bl point

    mov x0, x20
    bl snek_pop

game_loop_continue:
    mov x0, x20
    bl snek_head

    mov x0, x19
    ldr w3, [x20, SNEK_COLOR_OFFSET]
    mov x4, SNEK_BLOCK_PADDING
    bl block

    movz x27, 0x0FFF, lsl 16
    movk x27, 0xFFFF, lsl 0
    bl delay

    b game_loop

delay:
    sub sp, sp, 8
    str x19, [sp]

    subs x19, x19, 1
    bgt delay

_delay:
    ldr x19, [sp]
    add sp, sp, 8

    ret
