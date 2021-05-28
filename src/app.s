
.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGHT,		480
.equ SCALE_FACTOR,      10
.equ BITS_PER_PIXEL,  	32
.equ MAX_WIDTH,         SCREEN_WIDTH / SCALE_FACTOR - 1
.equ MAX_HEIGHT,        SCREEN_HEIGHT / SCALE_FACTOR - 1

.equ BLACK,     0x00000000
.equ WHITE,     0x00FFFFFF

.text
.globl main
main:
    mov x20, x0 /* FRAMEBUFFER */

    mov x0, x20
    mov w3, WHITE
    bl init_screen

    mov x0, x20
    mov x1, MAX_WIDTH
    mov x2, MAX_HEIGHT
    mov w3, WHITE
    bl point

    mov x0, x20
    mov x1, #0
    mov x2, #0
    mov w3, WHITE
    bl point

    b InfLoop

InfLoop:
    b InfLoop


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
    mov x8, SCREEN_WIDTH
    mul x2, x2, x8
    add x1, x1, x2

    str w3, [x0, x1, lsl #2]

_pixel:
    ret

/*
    Subroutine: point

    Brief:
        Draw a point into the framebuffer based on the scale factor

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color

    Notes:
        The point should be before (MAX_WIDTH, MAX_HEIGHT)
*/
point:
    mov x8, SCALE_FACTOR

    mul x9, x1, x8  /* x min */
    add x10, x9, x8 /* x max */
    sub x9, x9, #1

    mul x11, x2 , x8 /* y min */
    add x12, x11, x8 /* y max */
    mov x13, x11     /* y temp */

    sub sp, sp, #8 /* store lr from call */
    str x30, [sp]

point_loopx:
    add x9, x9, #1
    cmp x9, x10
    beq _point

    mov x11, x13

point_loopy:
    cmp x11, x12
    beq point_loopx

    mov x1, x9
    mov x2, x11
    bl pixel

    add x11, x11, #1
    b point_loopy

_point:
    ldr x30, [sp]   /* restore lr */
    add sp, sp, #8

    ret

/*
    Subroutine: init_screen

    Brief:
        Draw a point into the framebuffer based on the scale factor

    Params:
        x0 - framebuffer
        w3 - color

    Notes:
        The point should be before (MAX_WIDTH, MAX_HEIGHT)
*/
init_screen:
    sub sp, sp, 24
    str x19, [sp, 16]
    str x20, [sp, 8]
    str lr,  [sp]

    mov x19, SCREEN_WIDTH

init_loopx:
    mov x20, SCREEN_HEIGHT
    sub x20, x20, 1
    sub x19, x19, 1
    cbz x19, _init_screen

init_loopy:
    cbz x20, init_loopx
    
    mov x1, x19
    mov x2, x20
    bl pixel

    sub x20, x20, 1
    b init_loopy

_init_screen:
    ldr lr,  [sp]
    ldr x20, [sp, 8]
    ldr x19, [sp, 16]
    add sp, sp, 24

    ret
