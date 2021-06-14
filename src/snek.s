.ifndef _SNEK_S
.equ    _SNEK_S, 1

.include "src/screen.s"

.equ SNEK_INITIAL_SIZE,  5
.equ SNEK_MAXIMUM_SIZE,  55
.equ SNEK_INITIAL_X,     4
.equ SNEK_INITIAL_Y,     4
.equ SNEK_BLOCK_PADDING, SCALE_FACTOR / 10

.equ SNEK_DIRECTION_OFFSET, 0
.equ SNEK_COLOR_OFFSET,     4
.equ SNEK_SIZE_OFFSET,      8
.equ SNEK_FRONT_OFFSET,     12
.equ SNEK_REAR_OFFSET,      16
.equ SNEK_CAPACITY_OFFSET,  20
.equ SNEK_ARRAY_OFFSET,     24

/*
    A snek is a static array defined as follows:
    snek:
        .word DIR_X               (direction)
        .word 0x...               (color)
        .word SNEK_INITIAL_SIZE   (size)
        .word 0                   (front)
        .word SNEK_INITIAL_SIZE-1 (rear)
        .word SNEK_MAXIMUM_SIZE   (capacity)
        .skip 4*SNEK_MAXIMUM_SIZE (coord array)

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

    str wzr, [x0, SNEK_FRONT_OFFSET]

    mov w9, SNEK_INITIAL_SIZE
    str w9, [x0, SNEK_SIZE_OFFSET]

    mov w9, SNEK_INITIAL_SIZE-1
    str w9, [x0, SNEK_REAR_OFFSET]

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
    Subroutine: snek_push

    Brief:
        Push a coord pair into the snek

    Params:
        x0 - snek base address
        x1 - x pos
        x2 - y pos

    Notes:
        The size of the snek should be less than its capacity
*/
snek_push:
    sub sp, sp, 24
    str x19, [sp, 16]
    str x20, [sp, 8]
    str x21, [sp]

    ldr w19, [x0, SNEK_SIZE_OFFSET]
    add w19, w19, 1
    str w19, [x0, SNEK_SIZE_OFFSET]

    ldr w19, [x0, SNEK_REAR_OFFSET]
    ldr w20, [x0, SNEK_CAPACITY_OFFSET]

    /* REAR = (REAR + 1) % CAPACITY */
    add  w19, w19, 1         /* REAR = REAR + 1 */
    udiv w21, w19, w20       /* w21 = REAR // CAPACITY */
    msub w19, w21, w20, w19  /* REAR = REAR - (w21*CAPACITY) */

    str w19, [x0, SNEK_REAR_OFFSET]

    movk x19, 0, lsl 32
    lsl  x19, x19, 2

    add x20, x0, SNEK_ARRAY_OFFSET
    add x20, x20, x19

    /* signed modulus is kinda harder */
    /* a % b = ((a % b) + b) % b */
    mov  w21, MAX_WIDTH+1
    sdiv w19, w1,  w21
    msub w1,  w19, w21, w1
    add  w1,  w1,  MAX_WIDTH+1
    udiv w19, w1,  w21
    msub w1,  w19, w21, w1

    mov  w21, MAX_HEIGHT+1
    sdiv w19, w2,  w21
    msub w2,  w19, w21, w2
    add  w2,  w2,  MAX_HEIGHT+1
    udiv w19, w2,  w21
    msub w2,  w19, w21, w2

    strh w1, [x20], 2
    strh w2, [x20]

_snek_push:
    ldr x21, [sp]
    ldr x20, [sp, 8]
    ldr x19, [sp, 16]
    add sp, sp, 24

    ret

/*
    Subroutine: snek_head

    Brief:
        Return the 'head' pair of the snek queue

    Params:
        x0 - snek base address

    Return:
        x1 - x pos
        x2 - y pos
*/
snek_head:
    sub sp, sp, 8
    str x19, [sp]

    ldr w19, [x0, SNEK_REAR_OFFSET]
    movk x19, 0, lsl 32

    add x0, x0, SNEK_ARRAY_OFFSET

    lsl x19, x19, 2
    ldrh w1, [x0, x19]
    add x19, x19, 2
    ldrh w2, [x0, x19]

    movk x1, 0, lsl 32
    movk x2, 0, lsl 32

_snek_head:
    ldr x19, [sp]
    add sp, sp, 8

    ret

/*
    Subroutine: snek_draw_head

    Brief:
        Draw the head of the snek

    Params:
        x0 - snek base address
        x1 - framebuffer
*/
snek_draw_head:
    sub sp, sp, 24
    str x19, [sp, 16]
    str x20, [sp, 8]
    str lr,  [sp]

    mov x19, x0
    mov x20, x1

    mov x0, x1
    bl snek_head

    mov x0, x19
    ldr w3, [x20, SNEK_COLOR_OFFSET]
    mov x4, SNEK_BLOCK_PADDING
    bl block

_snek_draw_head:
    ldr lr,  [sp]
    ldr x20, [sp, 8]
    ldr x19, [sp, 16]
    add sp, sp, 24

    ret 

/*
    Subroutine: draw_snek

    Brief:
        Draw a snek on the screen

    Params:
        x0 - framebuffer
        x1 - snek base address
*/
draw_snek:
    sub sp, sp, 72
    str x19, [sp, 64] /* array */
    str x20, [sp, 56] /* color */
    str x21, [sp, 48] /* capacity */
    str x22, [sp, 40] /* front */
    str x23, [sp, 32] /* size */
    str x24, [sp, 24] /* i */
    str x25, [sp, 16] /* j */
    str x26, [sp, 8]  /* jtemp */
    str lr,  [sp]

    /*
        &A[0] = ARRAY + FRONT
        &A[i] = ARRAY + 4*((FRONT + i) % CAPACITY)
    */

    ldr w20, [x1, SNEK_COLOR_OFFSET]
    ldr w21, [x1, SNEK_CAPACITY_OFFSET]
    ldr w22, [x1, SNEK_FRONT_OFFSET]
    ldr w23, [x1, SNEK_SIZE_OFFSET]

    movk x21, 0, lsl 32
    movk x22, 0, lsl 32
    movk x23, 0, lsl 32

    add x19, x1, SNEK_ARRAY_OFFSET

    mov x24, xzr
draw_snek_loop:
    cmp x24, x23   /* i == size */
    beq _draw_snek

    add  x25, x22, x24      /* j = FRONT + i */
    udiv x26, x25, x21      /* jtemp = j // capacity */
    msub x25, x26, x21, x25 /* j = (FRONT + i) % CAPACITY */

    lsl x25, x25, 2
    ldrh w1, [x19, x25]
    add x25, x25, 2
    ldrh w2, [x19, x25]

    movk x1, 0, lsl 32
    movk x2, 0, lsl 32
    mov w3, w20
    mov x4, SNEK_BLOCK_PADDING
    bl block

    add x24, x24, 1

    b draw_snek_loop

_draw_snek:
    ldr lr,  [sp]
    ldr x26, [sp, 8]
    ldr x25, [sp, 16]
    ldr x24, [sp, 24]
    ldr x23, [sp, 32]
    ldr x22, [sp, 40]
    ldr x21, [sp, 48]
    ldr x20, [sp, 56]
    ldr x19, [sp, 64]
    add sp, sp, 72

    ret

.endif /* _SNEK_S */
