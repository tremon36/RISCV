.global _boot
.text

_boot:

addi x15,x0,77
addi x16,x0,4
jal start_mult

addi x5,x18,0
sub x18,x18,x5
sub x18,x18,x5
sw  x18,4(x0)
lw  x16,4(x0)

endless: j endless

/*
Funcion de multiplicacion.
    Argumentos: x15 -> OP1
                x16 -> OP2
    resultado:  x18
    Destructiva.
    Reservador x17
*/
start_mult:
	andi x17,x16,1
    beq x0,x17, parte2
    add x18,x18,x15
parte2:
	slli x15,x15,1
    srli x16,x16,1
    bne x16,x0,start_mult
    ret





