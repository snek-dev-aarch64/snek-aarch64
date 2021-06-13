.include "src/screen.s"
.include "src/snek.s"
.include "src/food.s"
.include "src/tile.s"

.equ RAND_SEED, 0x020800

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

    mov x0, x19
    adr x1, snek

/*
    game_loop

    Brief:
        Game's main loop

    Params:
        x0 - framebuffer
        x1 - snek base address
*/
game_loop:
    mov x19, x0
    mov x20, x1

game_loop_init:
    mov x0, x20
    ldr w1, food_x
    ldr w2, food_y
    bl ai_choose_path

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
    sub x2, x2, 1
    b game_loop_snek_update

game_loop_down:
    add x2, x2, 1
    b game_loop_snek_update

game_loop_right:
    add x1, x1, 1
    b game_loop_snek_update

game_loop_left:
    sub x1, x1, 1

game_loop_snek_update:
    mov x0, x20
    bl snek_push

    mov x0, x20
    bl snek_head

    ldr w9,  food_x
    ldr w10, food_y

    /* if snek in food generate new food */
    cmp w1, w9
    bne game_loop_continue_pop
    cmp w2, w10
    beq game_loop_new_food

    b game_loop_continue_pop

game_loop_new_food:
    mov x0, x20
    bl  new_food

    adr x0, food_x
    str w1, [x0]

    adr x0, food_y
    str w2, [x0]

    mov x0, x19
    ldr w3, food_color
    bl tiled_circle

    /* if max size is eq to capacity win */
    ldr w0, [x20, SNEK_SIZE_OFFSET]
    cmp w0, SNEK_MAXIMUM_SIZE-1
    beq oh_im_die_thank_you_forever

    b game_loop_continue

game_loop_continue_pop:
    mov x0, x20
    bl snek_last

    mov x0, x19
    bl tile

    mov x0, x20
    bl snek_pop

game_loop_continue:
    mov x0, x20
    bl snek_head

    mov x0, x19
    ldr w3, [x20, SNEK_COLOR_OFFSET]
    mov x4, BLOCK_PADDING
    bl block

    mov  x0, x20
    bl   snek_is_ded
    cbnz x0, oh_im_die_thank_you_forever

    movz x0, 0x00FF, lsl 16
    movk x0, 0xFFFF, lsl 0
    bl delay

    b game_loop_init

oh_im_die_thank_you_forever:
    b oh_im_die_thank_you_forever

/*
    Subroutine: ai_choose_path

    Brief:
        Choose a suitable path for the snek to reach the food

    Params:
        x0 - snek base address
        w1 - food x
        w2 - food y
*/
ai_choose_path:
    sub sp, sp, 32
    str x19, [sp, 24]
    str x20, [sp, 16]
    str x21, [sp, 8]
    str lr,  [sp]

    mov x19, x0
    mov w20, w1
    mov w21, w2

    bl snek_head

    ldr w9, [x19, SNEK_DIRECTION_OFFSET]

ai_align_x:
    cmp w20, w1
    beq ai_align_y
    bgt ai_go_right
    blt ai_go_left

ai_align_y:
    cmp w21, w2
    beq _ai_choose_path
    bgt ai_go_down
    blt ai_go_up

ai_go_up:
    mov w10, DIR_UP
    b ai_decide_direction

ai_go_down:
    mov w10, DIR_DOWN
    b ai_decide_direction

ai_go_right:
    mov w10, DIR_RIGHT
    b ai_decide_direction

ai_go_left:
    mov w10, DIR_LEFT

/* if we go to the opposite direction the snake instantly dies */
/* so we keep the one we had and loop to the other side to align */
ai_decide_direction:
    adds wzr, w10, w9
    bne  ai_load_direction

    neg w10, w10

ai_load_direction:
    str w10, [x19, SNEK_DIRECTION_OFFSET]

_ai_choose_path:
    ldr lr,  [sp]
    ldr x21, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 8

    ret

/*
    Subroutine: delay

    Brief:
        Delay the program flow

    Params:
        x0 - delay ammount
*/
delay:
    cbz x0, _delay_end

delay_loop:
    nop
    subs x0, x0, 1
    bne delay_loop

_delay_end:
    ret
