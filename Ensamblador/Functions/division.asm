/* we are going to use registers from x10 to x15 */
/* arguments are in adress 11600 (divisor) and 11604 (dividendo) */


lui x2,28
addi x2,x2,1312 /* load pointer to 11600 addr*/


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
slli x11,x11,1
slli x10,x10,1
and x13,x9,x12
beq x13,x0,set0
    ori x11,x11,1
    addi x13,x0,0
set0:

blt x11,x8,skipped

    sub x11,x11,x8
    ori x10,x10,1

skipped:

srai x12,x12,1
jal x0,divide 
end:

/*content of registers restoration*/

sw x10,0(x2)
sw x11,4(x2)

lw x10,8(x2)
lw x11,12(x2)
lw x12,16(x2)
lw x13,20(x2) /* save content of registers */

ret
