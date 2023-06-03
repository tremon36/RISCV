.global _boot
.text

li x15,6
li sp,1000
jal fibonacci
endless: j endless

fibonacci:

    sw x1,0(sp) 	/* Save return address of function in stack frame[0] */
    lw x15,4(sp)    /* load function argument, frame[1] */
    li x25,0	    /* deepest recursion flag */
    bne x15,x0,endif1	/* if arg = 0 then */
    li x25,1		/* deepest recursion flag = true*/
    li x16,0		/* ret_value: 0*/
    sw x16,8(sp)	/* place return value in stack_frame[2] */
    endif1:
    li x16,1		/* x16 is aux reg */
    bne x15,x16, endif2 /* if arg = 1 then */
    li x25,1		/* deepest recursion flag = true*/
    li x16,1		/* ret_value: 1*/
    sw x16,8(sp)	/* place return value in stack_frame[2] */
    endif2:
    li x26,1
    beq x25,x26,return /*if deepest recursion, dont go deeper*/

    /* Now, do recursion , fibonacci(x-1) + fibonacci(x-2) */

    add x25,x15,-1 /* x - 1 (new argument)*/
    sw x25,4(sp)   /* function argument no longer needed, used for new argument */
    add sp,sp,12  /* stack pointer 1 frame up */
    sw x25,4(sp)   /* new stack frame[1] = x-1 */
    jal fibonacci  /* call fibonacci with new argument */
    lw x25,8(sp)   /* get result from the prevoius call */
    add sp,sp,-12 /* stack pointer 1 frame down */
	lw x26,4(sp)   /* load function argument x-1 */
	addi x26,x26,-1
    sw x25,4(sp)   /* save result from the previous call in frame[1] */
    add sp,sp,12  /* stack pointer 1 frame up*/
    sw x26,4(sp)   /* new stack frame[1] = x-2 */
    jal fibonacci
    lw x25,8(sp)   /* load result from the prevoius call (frame[2])*/
    add sp,sp,-12 /* stack pointer 1 frame down */
    lw x26,4(sp)	/* load result from the first recursion in frame[1]*/
    add x25,x25,x26 /* result is now in x25*/
    sw x25,8(sp)    /*save in frame[2] */
	lw x1,0(sp)
    return: ret


simplified: -----------------------------------------------------------------------------------------------------------------------------------------------------------

addi x15,x0,10
addi sp,x0,0
sw x15,4(sp)
jal x1,fibonacci
endless:
jal x0,endless

fibonacci:

    sw x1,0(sp)
    lw x15,4(sp)
    addi x25,x0,0
    bne x15,x0,endif1
    addi x25,x0,1
    addi x16,x0,0
    sw x16,8(sp)
    endif1:
    addi x16,x0,1
    bne x15,x16, endif2
    addi x25,x0,1
    addi x16,x0,1
    sw x16,8(sp)
    endif2:
    addi x26,x0,1
    beq x25,x26,return



    addi x25,x15,-1
    sw x25,4(sp)
    addi sp,sp,12
    sw x25,4(sp)
    jal x1,fibonacci
    lw x25,8(sp)
    addi sp,sp,-12
    lw x26,4(sp)
    addi x26,x26,-1
    sw x25,4(sp)
    addi sp,sp,12
    sw x26,4(sp)
    jal x1,fibonacci
    lw x25,8(sp)
    addi sp,sp,-12
    lw x26,4(sp)
    add x25,x25,x26
    sw x25,8(sp)
    lw x1,0(sp)
return:
    jalr x0,x1,0
