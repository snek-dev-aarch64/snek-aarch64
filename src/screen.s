.ifndef _SCREEN_S
.equ    _SCREEN_S, 1

.equ SCREEN_WIDTH, 	 640
.equ SCREEN_HEIGHT,	 480
.equ BITS_PER_PIXEL, 32
.equ SCALE_FACTOR,   10
.equ MAX_WIDTH,      SCREEN_WIDTH / SCALE_FACTOR - 1
.equ MAX_HEIGHT,     SCREEN_HEIGHT / SCALE_FACTOR - 1

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
    Subroutine: point

    Brief:
        Draw a point into the framebuffer based on the scale factor

    Params:
        x0 - framebuffer
        x1 - x pos
        x2 - y pos
        w3 - color

    Notes:
        The point coords should be choosen from 0,0 to MAX_WIDTH,MAX_HEIGHT
*/
point:
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

    mul x22, x2, x19  /* y min */
    add x23, x22, x19 /* y max */
    mov x19, x22      /* y temp */

point_loopx:
    cmp x20, x21
    bge _point

    mov x22, x19
point_loopy:
    mov x1, x20
    mov x2, x22
    bl pixel

    add x22, x22, 1
    cmp x22, x23
    blt point_loopy

    add x20, x20, 1
    b point_loopx

_point:
    ldr lr,  [sp]
    ldr x23, [sp, 8]
    ldr x22, [sp, 16]
    ldr x21, [sp, 24]
    ldr x20, [sp, 32]
    ldr x19, [sp, 40]
    add sp, sp, 48

    ret

/*
    Subroutine: init_screen

    Brief:
        Draw the entire screen with a color

    Params:
        x0 - framebuffer
        w3 - color
*/
init_screen:
    sub sp, sp, 24
    str x19, [sp, 16]
    str x20, [sp, 8]
    str lr,  [sp]

    mov x19, #SCREEN_WIDTH-1
init_screen_loopx:
    cmp x19, 0
    blt _init_screen

    mov x20, #SCREEN_HEIGHT-1
init_screen_loopy:
    mov x1, x19
    mov x2, x20
    bl pixel

    sub x20, x20, 1
    cmp x20, 0
    bge init_screen_loopy

    sub x19, x19, 1
    b init_screen_loopx

_init_screen:
    ldr lr,  [sp]
    ldr x20, [sp, 8]
    ldr x19, [sp, 16]
    add sp, sp, 24

    ret

.endif