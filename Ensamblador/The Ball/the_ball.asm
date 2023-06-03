.global _boot
.text

_boot:

/* Initialization of registers */

lui x6,0x1c     /* global pointer to superframe addresses */
addi x6,x6,512  /* load 115200 (last address of frame) */

li x10,10       /* x10 holds ball position, starting at 10 */
li x11,641      /* x11 holds calculation for ball speed, x + 320*y*/
li x12,0xFF     /* x12 holds ball color, starting at full blue */

/* clear screen*/

clear:

li x5,0        /*x5 is a counter*/
li x7,0

loop_1:  /* Blazingly fast (1 IPC). Should take 4800 cycles (480 uS) of the 16666 uS available (2%) */
beq x5,x6,end_clear

addi x5,x5,24
sw x0,0(x7)
sw x0,4(x7)
sw x0,8(x7)
sw x0,12(x7)
addi x7,x7,24
sw x0,-8(x5)
sw x0,-4(x5)
j loop_1

end_clear:

/* calculate new ball position */

add x10,x10,x11
/* check edge collision (only y coordinate cause fuck it) */

lui x5,18
addi x5,x5,-447 /* to check for bottom collision, x5 = 76800 - 319 - 320 * 10 */

blt x10,x5,check_top_collision
    li x11,-959 /* ball speed is now (1,-2) */
    add x12,x12,3

check_top_collision:
bgt x10,x0,end_collision_check
    li x11,961 /* ball speed is now  (1,2) */
    add x12,x12,3

end_collision_check:

/* render ball */

li x5,3
sw x5,800(x6)
srli x26,x10,1
add x26,x26,x10 /* load ball position in pixels in x26 (ball_pos * 1.5)*/
sw x26,804(x6)
jal division_func
lw x23,804(x6) /* load remainder */    /* address step 0 = step only 1, 1 = step 2*/
li x8,0     /* counter to check when 10 pixels */
li x9,10    /* barrier to check when 10 pixels */


lui x27,0x1
addi x27,x27,239
add x27,x27,x26 /* load last position for ball, */

render:
bge x26,x27,waste_time /* end of render, go to waste time */
beq x8,x9,add_480 /* check for line end */

bne x23,x0,step2
    srli x13,x12,4 /* get RG */
    sb x13,0(x26)

    slli x13,x12,4 /* get B */
    lb x14,1(x26)
    andi x14,x14,0x0F
    or x14,x14,x13 
    sb x14,1(x26)

    addi x8,x8,1    /* one more pixel */
    addi x26,x26,1    /* Add 1 to address counter*/
    li x23,1        /* next step is two addr*/
    j  render 

step2:

    srli x13,x12,8 /* get R */
    lb x14,0(x26)
    andi x14,x14,0xF0
    or x14,x14,x13 
    sb x14,0(x26) /* save R */
    sb x12,1(x26) /* save GB */

    addi x8,x8,1    /* one more pixel */
    addi x26,x26,2    /* Add 2 to address counter*/
    li x23,0        /* next step is one addr*/
    j  render 

add_480:

    li x8,0
    addi x26,x26,465
    j render

waste_time:

    lui x7,128
    li x5,0
    check:
    beq x5,x7,clear
    addi x5,x5,1
    j check

division_func:

/* we are going to use registers from x10 to x15 */
/* arguments are in adress 116000 (divisor) and 116004 (dividendo) */


lui x2,28
addi x2,x2,1312 /* load pointer to 116000 addr*/


sw x10,8(x2)
sw x11,12(x2)
sw x12,16(x2)
sw x13,20(x2) /* save content of registers */

lw x8,0(x2)
lw x9,4(x2)

addi x10,x0,0  /* x10 is Q */
addi x11,x0,0  /* x11 is R */
addi x12,x0,1  /* x12 is bit counter, max 17 bits */
slli x12,x12,16

divide:
beq x12,x0,end
and x13,x9,x12
slli x11,x11,1
slli x10,x10,1
beq x13,x0,set0
    ori x11,x11,1
    addi x13,x0,0
set0:

blt x11,x8,skipped

    sub x11,x11,x8
    ori x10,x10,1

skipped:

srai x12,x12,1
j divide 
end:

/*content of registers restoration*/

sw x10,0(x2)
sw x11,4(x2)

lw x10,8(x2)
lw x11,12(x2)
lw x12,16(x2)
lw x13,20(x2) /* save content of registers */

ret