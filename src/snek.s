.ifndef _SNEK_S
.equ    _SNEK_S, 1

.include "src/screen.s"

.equ SNEK_INITIAL_SIZE, 5
.equ SNEK_MAXIMUM_SIZE, 55
.equ SNEK_INITIAL_X,    4
.equ SNEK_INITIAL_Y,    4

.equ SNEK_COLOR_OFFSET,    0
.equ SNEK_SIZE_OFFSET,     4
.equ SNEK_FRONT_OFFSET,    8
.equ SNEK_REAR_OFFSET,     12
.equ SNEK_CAPACITY_OFFSET, 16
.equ SNEK_ARRAY_OFFSET,    20

/*
    A snek is a static array defined as follows:
    snek:
        .word (color)
        .word (size)
        .word (front)
        .word (rear)
        .word SNEK_MAXIMUM_SIZE    (capacity)
        .skip  4*SNEK_MAXIMUM_SIZE (coord array)

    - The coord array is made out of 'pairs' (x,y) stored as halfwords
    - Size denotes how many pairs there are currently in the snake
    - Capacity denotes the maximum amount of pairs the sanake can handle
*/

/*
    Subroutine: init_snek

    Brief:
        Initialize snek with SNEK_INITIAL_SIZE

    Params:
        x0 - snek base address
        x1 - x pos
        x2 - y pos
*/
init_snek:
    sub sp, sp, 32
    str x19, [sp, 24]
    str x20, [sp, 16]
    str x21, [sp, 8]
    str x22, [sp]

    mov x19, x0
    add x19, x19, SNEK_ARRAY_OFFSET
    mov x20, x1
    mov x21, x2
    mov x22, xzr

init_snek_loop:
    cmp x22, SNEK_INITIAL_SIZE
    bge _init_snek

    strh w20, [x19], 2 /* store x_i and add 2 */
    strh w21, [x19], 2 /* store y_i and advance to next pair  */

    add x20, x20, 1
    add x22, x22, 1

    b init_snek_loop

_init_snek:
    ldr x22, [sp]
    ldr x21, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 32

    ret

/*
    Subroutine: draw_snek

    Brief:
        Draw a snek on the screen

    Params:
        x0 - framebuffer
        x1 - snek base address
        x2 - snek size
        w3 - color
*/
draw_snek:
    sub sp, sp, 32
    str x19, [sp, 24]
    str x20, [sp, 16]
    str x21, [sp, 8]
    str lr,  [sp]

    add x19, x1, SNEK_ARRAY_OFFSET
    add x20, x1, SNEK_SIZE_OFFSET
    ldrh w21, [x1, SNEK_COLOR_OFFSET]

draw_snek_loop:
    cmp x19, x20
    beq _draw_snek

    ldrh w1, [x19], 2  /* load x and add 2 */
    ldrh w2, [x19], 2  /* load y and go to next pair */

    movk x1, 0, lsl 16
    movk x2, 0, lsl 16
    mov w3, w21
    bl point

    b draw_snek_loop

_draw_snek:
    ldr lr,  [sp]
    ldr x21, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 32

    ret

.endif
