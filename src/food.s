.ifndef _FOOD_S
.equ    _FOOD_S, 1

.include "src/screen.s"
.include "src/snek.s"
.include "src/random.s"

/*
    Subroutine: new_food

    Brief:
        Draw a new food

    Params:
        x0 - snek base address

    Returns:
        x0 - x pos
        x1 - y pos
*/
new_food:
    sub sp, sp, 80
    str x19, [sp, 72] /* array */
    str x20, [sp, 64] /* capacity */
    str x21, [sp, 56] /* front */
    str x22, [sp, 48] /* size */
    str x23, [sp, 40] /* i */
    str x24, [sp, 32] /* j */
    str x25, [sp, 24] /* jtemp */
    str x26, [sp, 16] /* random x */
    str x27, [sp, 8]  /* random y */
    str lr,  [sp]

    ldr w20, [x0, SNEK_CAPACITY_OFFSET]
    ldr w21, [x0, SNEK_FRONT_OFFSET]
    ldr w22, [x0, SNEK_SIZE_OFFSET]

    movk x20, 0, lsl 32
    movk x21, 0, lsl 32
    movk x22, 0, lsl 32

    add x19, x0, SNEK_ARRAY_OFFSET

new_food_random:
    mov x23, xzr

    mov x0, MAX_WIDTH
    bl randzn
    mov x26, x0

    mov x0, MAX_HEIGHT
    bl randzn
    mov x27, x0

new_food_loop:
    cmp x23, x22   /* i == size */
    beq _new_food

    add  x24, x21, x23      /* j = FRONT + i */
    udiv x25, x24, x20      /* jtemp = j // capacity */
    msub x24, x25, x20, x24 /* j = (FRONT + i) % CAPACITY */

    lsl x24, x24, 2
    ldrh w1, [x19, x24]
    add x24, x24, 2
    ldrh w2, [x19, x24]

    movk x1, 0, lsl 32
    movk x2, 0, lsl 32

    cmp x1, x26
    bne new_food_continue
    cmp x2, x27
    beq new_food_random

new_food_continue:
    add x23, x23, 1

    b new_food_loop

_new_food:
    mov x0, x26
    mov x1, x27

    ldr lr,  [sp]
    ldr x27, [sp, 8]
    ldr x26, [sp, 16]
    ldr x25, [sp, 24]
    ldr x24, [sp, 32]
    ldr x23, [sp, 40]
    ldr x22, [sp, 48]
    ldr x21, [sp, 56]
    ldr x20, [sp, 64]
    ldr x19, [sp, 72]
    add sp, sp, 80

    ret

.endif /* _FOOD_S */
