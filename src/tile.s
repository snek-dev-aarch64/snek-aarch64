.ifndef _TILE_S
.equ _TILE_S, 1

.include "src/screen.s"
.include "src/random.s"

.equ PARTICLE_SIZE, SCALE_FACTOR

.equ DARK,   0x00111111
.equ DARKER, 0x00222222
.equ SAND,   0x00FBD48F

.data
    particle:        .word SAND
    particle_dark:   .word SAND - DARK
    particle_darker: .word SAND - DARKER

.text
/*
    game_loop

    Brief:
        Draw tile with

    Params:
        x0 - framebuffer
        x1 - x
        x2 - y
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

.endif
