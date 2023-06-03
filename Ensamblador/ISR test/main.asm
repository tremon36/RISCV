.global _boot
.text

_boot:

addi x5,x0,0
addi x8,x0,0

adder: addi x5,x5,1

lui x7,512
li x6,0
check:
beq x6,x7,adder
addi x6,x6,1
csrrsi x9,mstatus,0
j check


