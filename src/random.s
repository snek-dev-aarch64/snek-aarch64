.ifndef _RANDOM_S
.equ    _RANDOM_S, 1

.equ RAND_MAX, 0x7FFFFFFFFFFFFFFF

.data
    rseed: .dword 1

/*
    Subroutine: srand

    Brief:
        Initialize the random seed

    Params:
        x0 - seed
*/
srand:
    sub sp, sp, 8
    str x19, [sp]

    adr x19, rseed
    str x0,  [x19]

_srand:
    ldr x19, [sp]
    add sp, sp, 8

    ret

/*
    Subroutine: rand

    Brief:
        Generate a pseudo-random integer based on the random seed

    Returns:
        x0 - pseudo-random result
*/
rand:
    sub sp, sp, 16
    str x19, [sp, 8] /* rseed  */
    str x20, [sp]    /* &rseed */

    /*
        pseudo-random algorythm
        rseed = rseed*0xF329 + 1234
        returns rseed//0xFFFF % RAND_MAX
    */

    ldr x19, rseed

    mov x20, 0xF329
    mul x19, x19, x20
    add x19, x19, 1234

    adr x20, rseed
    str x19, [x20]

    /* rand = rseed // 2^16 */
    mov  x20, 0xFFFF
    udiv x19, x19, x20

    /* rand = rand % RAND_MAX */
    mov x20, RAND_MAX
    mov x0,  x19

    udiv x19, x0,  x20
    msub x0,  x19, x20, x0

_rand:
    ldr x20, [sp]
    ldr x19, [sp, 8]
    add sp, sp, 16

    ret

/*
    Subroutine: randrn

    Brief:
        Generates a pseudo-random integer in the range [x0,x1]

    Params:
        x0 - start
        x1 - end

    Returns:
        x0 - pseudo-random result

    Notes:
        start <= end
*/
randrn:
    sub sp, sp, 32
    str x19, [sp, 24]
    str x20, [sp, 16]
    str x21, [sp, 8]
    str lr,  [sp]

    /* x21 = start */
    mov x21, x0

    /* x19 = end - start + 1 */
    sub x19, x1,  x21
    add x19, x19, 1

    bl rand

    /* rand = rand % x19 */
    udiv x20, x0,  x19
    msub x0,  x20, x19, x0

    /* rand = rand + start */
    add x0, x0, x21

_randrn:
    ldr lr,  [sp]
    ldr x21, [sp, 8]
    ldr x20, [sp, 16]
    ldr x19, [sp, 24]
    add sp, sp, 32

    ret

/*
    Subroutine: randzn

    Brief:
        Generates a pseudo-random integer in the range [0,x0]

    Params:
        x0 - end

    Returns:
        x0 - pseudo-random result

    Notes:
        end > 0
*/
randzn:
    sub sp, sp, 8
    str lr, [sp]

    mov x1, x0
    mov x0, xzr
    bl randrn

_randzn:
    ldr lr, [sp]
    add sp, sp, 8

    ret

.endif /* _RANDOM_S */
