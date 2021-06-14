.ifndef _SCREEN_S
.equ    _SCREEN_S, 1

.include "src/random.s"

.equ SCREEN_WIDTH, 	 640
.equ SCREEN_HEIGHT,	 480
.equ BITS_PER_PIXEL, 32
.equ SCALE_FACTOR,   16
.equ MAX_WIDTH,      SCREEN_WIDTH / SCALE_FACTOR - 1
.equ MAX_HEIGHT,     SCREEN_HEIGHT / SCALE_FACTOR - 1

.equ PARTICLE_SIZE, SCALE_FACTOR >> 1

.equ DARK,   0x00111111
.equ DARKER, 0x00222222
.equ SAND,   0x00FBD48F

.data
    particle:        .word SAND
    particle_dark:   .word SAND - DARK
    particle_darker: .word SAND - DARKER

.text
/*
    Subroutine: pixel

    Brief:
        Draw a pixel into the framebuffer

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color
*/
pixel:
    sub sp, sp, 8
    str x19, [sp]

    mov x19, SCREEN_WIDTH
    mul x2, x2, x19
    add x1, x1, x2

    str w3, [x0, x1, lsl 2]

_pixel:
    ldr x19, [sp]
    add sp, sp, 8

    ret

/*
    Subroutine: block

    Brief:
        Draw a block into the framebuffer based on the scale factor and on the provided padding

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color
        x4 - padding

    Notes:
        The block coords should be choosen from 0,0 to MAX_WIDTH,MAX_HEIGHT
*/
block:
    sub sp, sp, 48
    str x19, [sp, 40]
    str x20, [sp, 32]
    str x21, [sp, 24]
    str x22, [sp, 16]
    str x23, [sp, 8]
    str lr,  [sp]

    mov x19, SCALE_FACTOR

    mul x20, x1, x19  /* x min */
    add x21, x20, x19 /* x max */
    add x20, x20, x4
    sub x21, x21, x4

    mul x22, x2, x19  /* y min */
    add x23, x22, x19 /* y max */
    add x22, x22, x4
    sub x23, x23, x4

block_loopx:
    cmp x20, x21
    bge _block

    mov x19, x22

block_loopy:
    mov x1, x20
    mov x2, x19
    bl pixel

    add x19, x19, 1
    cmp x19, x23
    blt block_loopy

    add x20, x20, 1
    b block_loopx

_block:
    ldr lr,  [sp]
    ldr x23, [sp, 8]
    ldr x22, [sp, 16]
    ldr x21, [sp, 24]
    ldr x20, [sp, 32]
    ldr x19, [sp, 40]
    add sp, sp, 48

    ret

/*
    Subroutine: rect

    Brief:
        Draw a rectangle given (x min, y min) and (x max, y max)

    Params:
        x0 - framebuffer
        x1 - x min
        x2 - y min
        x3 - x max
        x4 - y max
        w5 - color
*/
rect:
    sub sp, sp, 48
    str x19, [sp, 40]
    str x20, [sp, 32]
    str x21, [sp, 24]
    str x22, [sp, 16]
    str x23, [sp, 8]
    str lr,  [sp]

    mov x20, x1 /* x min */
    mov x21, x2 /* y min */

    mov x22, x3 /* x max */
    mov x23, x4 /* y max */

rect_loopx:
    cmp x20, x22 /* If x min >= x max */
    bge _rect

    mov x19, x21

rect_loopy:
    mov x1, x20
    mov x2, x19
    mov w3, w5
    bl pixel

    add x19, x19, 1
    cmp x19, x23
    blt rect_loopy

    add x20, x20, 1
    b rect_loopx

_rect:
    ldr lr,  [sp]
    ldr x23, [sp, 8]
    ldr x22, [sp, 16]
    ldr x21, [sp, 24]
    ldr x20, [sp, 32]
    ldr x19, [sp, 40]
    add sp, sp, 48

    ret

/*
    Subroutine: tile

    Brief:
        Draw tile with random particles

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
*/
tile:
    sub sp, sp, 56
    str x19, [sp, 48]
    str x20, [sp, 40]
    str x21, [sp, 32]
    str x22, [sp, 24]
    str x23, [sp, 16]
    str x24, [sp, 8]
    str lr,  [sp]

    mov x19, SCALE_FACTOR

    mul x20, x1, x19  /* x min */
    add x21, x20, x19 /* x max */

    mul x22, x2, x19  /* y min */
    add x23, x22, x19 /* y max */

    mov x24, x0

tile_loopx:
    cmp x20, x21
    bge _tile

    mov x19, x22

tile_loopy:
    mov x0, 0
    mov x1, 2
    bl randrn

    cmp x0, 0
    beq tile_loopx_dark

    cmp x0, 1
    beq tile_loopx_darker

    ldr w3, particle
    b tile_loopx_continue

tile_loopx_dark:
    ldr w3, particle_dark
    b tile_loopx_continue

tile_loopx_darker:
    ldr w3, particle_darker

tile_loopx_continue:
    mov x0, x24
    mov x1, x20
    mov x2, x19
    mov w5, w3
    add x3, x20, PARTICLE_SIZE
    add x4, x19, PARTICLE_SIZE
    bl rect

    add x19, x19, PARTICLE_SIZE
    cmp x19, x23
    blt tile_loopy

    add x20, x20, PARTICLE_SIZE
    b tile_loopx

_tile:
    ldr lr,  [sp]
    ldr x24, [sp, 8]
    ldr x23, [sp, 16]
    ldr x22, [sp, 24]
    ldr x21, [sp, 32]
    ldr x20, [sp, 40]
    ldr x19, [sp, 48]
    add sp, sp, 56

    ret

/*
    Subroutine: circle

    Brief:
        Draw a circle inside a x3*x3 square, offsetted by x1 and x2

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        x3 - radius
        w4 - color
*/
circle:
    sub sp, sp, 48
    str x19, [sp, 40]
    str x20, [sp, 32]
    str x21, [sp, 24]
    str x22, [sp, 16]
    str x23, [sp, 8]
    str lr,  [sp]

    mov x19, x0
    mov x20, x1
    mov x21, x2
    mov x22, x3

    /* N = 2*r + 1 */
    lsl x23, x3, 1
    add x23, x23, 1

    mov x9, xzr /* i = 0 */

circle_loopi:
    cmp x9, x23
    beq _circle

    mov x10, xzr

circle_loopj:
    sub x11, x9, x22  /* x = i - r */
    sub x12, x10, x22 /* y = j - r */

    mul x13, x11, x11 /* w = x * x */
    mul x14, x12, x12 /* z = y * y */

    /* v = r * r */
    mul x15, x22, x22

    /* x * x + y * y */
    add x16, x13, x14

    /* x * x + y * y > r * r*/
    cmp x16, x15
    bge circle_loopj_continue

    mov x0, x19
    mov x1, x11
    add x1, x1, x20
    mov x2, x12
    add x2, x2, x21
    mov w3, w4
    bl pixel

circle_loopj_continue:
    add x10, x10, 1

    cmp x10, x23
    bne circle_loopj

    add x9, x9, 1
    b circle_loopi

_circle:
    ldr lr,  [sp]
    ldr x23, [sp, 8]
    ldr x22, [sp, 16]
    ldr x21, [sp, 24]
    ldr x20, [sp, 32]
    ldr x19, [sp, 40]
    add sp, sp, 48

    ret

/*
    Subroutine: tiled_circle

    Brief:
        Draw a tile with a centered circle

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color
*/
tiled_circle:
    sub sp, sp, 16
    str x19, [sp, 8]
    str lr,  [sp]

    mov x19, SCALE_FACTOR
    mov w4, w3
    mov x3, (SCALE_FACTOR >> 1) - (SCALE_FACTOR / 10)
    mul x1, x1, x19
    add x1, x1, x3
    add x1, x1, SCALE_FACTOR / 10
    mul x2, x2, x19
    add x2, x2, x3
    add x2, x2, SCALE_FACTOR / 10
    bl circle

_tiled_circle:
    ldr lr,  [sp]
    ldr x19, [sp, 8]
    add sp, sp, 16

    ret

/*
    Subroutine: init_screen

    Brief:
        Draw the entire screen with a color

    Params:
        x0 - framebuffer
*/
init_screen:
    sub sp, sp, 56
    str x19, [sp, 48]
    str x20, [sp, 40]
    str x21, [sp, 32]
    str x22, [sp, 24]
    str x23, [sp, 16]
    str x24, [sp, 8]
    str lr,  [sp]

    mov x20, xzr /* x min */
    mov x21, xzr /* y min */

    mov x22, MAX_WIDTH + 1  /* x max */
    mov x23, MAX_HEIGHT + 1 /* y max */

    mov x24, x0

init_screen_loopx:
    cmp x20, x22 /* If x min >= x max */
    bge _init_screen

    mov x19, x21

init_screen_loopy:
    mov x0, x24
    mov x1, x20
    mov x2, x19
    bl tile

    add x19, x19, 1
    cmp x19, x23
    blt init_screen_loopy

    add x20, x20, 1
    b init_screen_loopx

_init_screen:
    ldr lr,  [sp]
    ldr x24, [sp, 8]
    ldr x23, [sp, 16]
    ldr x22, [sp, 24]
    ldr x21, [sp, 32]
    ldr x20, [sp, 40]
    ldr x19, [sp, 48]
    add sp, sp, 56

    ret

.endif /* _SNEK_S */
