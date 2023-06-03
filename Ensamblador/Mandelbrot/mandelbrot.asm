# Global variables

lui x1,0xFFFD8 #Load pointer to frame base address in x1

lui x2,0xFFFF4 
ori x2,x2,0x200 # Load pointer to .data segment in x2

li x26,0 # render pixel state
mv x27,x1 # current render address

li x3,2 
slli x3,x3,13 # load limit = 2, fixed point arithmetic, 13 decimals.

li x4, 0x4C # load  (0.009227), real step to show between -2 and 1
li x5, 0x44 # load  (0.00830), imaginary step to show between -1 and 0.99

li x6,320 # Horizontal limit
li x7,240 # Vertical limit 

li x8,0 # Vertical counter
li x9,0 # Horizontal counter

li x10,-1 
slli x10,x10,14 # Load -2 in fixed point with 13 decimals (Start for  real axis)

li x15,1
slli x15,x15,13 # Load 1 in fixed point with 13 decimals (start for imaginary axis)

mv x11,x10 # x11 holds current real value 
mv x12,x15 # x12 holds current imaginary value

v_loop: bge x8,x7,end_vertical # while(v_count < v_limit)
h_loop: bge x9,x6,end_horizontal # while(h_count < h_limit)

li x16,0 # mandelbrot loop interator
li x17,79 # mandelbrot loop iterator limit
mv x13,x11 # x13 holds current real value for mandelbrot algorithm
mv x14,x12 # x14 holds current imaginary value for mandelbrot algorithm

mandel_loop:

bge x13,x3,end_mandel # real > 2 or
bge x14,x3,end_mandel # imag > 2 or
bge x16,x17, end_mandel # max_inter = 79

add x18,x13,x14 # x18 = real + imag
sub x19,x13,x14 # x18 = real - imag 

# multiply real * imag 

mv x20,x13 
mv x21,x14 
li x23,0 

srli x24,x20,31 # sign of real
srli x25,x21,31 # sign of imaginary

#if real is negative, convert to positive

beq x24,x0,is_positive 
not x20,x20
addi x20,x20,1
is_positive:

#if imag is negative, convert to positive
beq x25,x0,compute_result_sign
not x21,x21
addi x21,x21,1

compute_result_sign:
xor x25,x24,x25

start_mult_1:
andi x22,x21,1
beq x0,x22, parte2
add x23,x23,x20
parte2:
slli x20,x20,1
srli x21,x21,1
bne x21,x0,start_mult_1

srli x23,x23,12 # shift 12, as 13 decimals each, but then multiply by two (2ab)
beqz x25,endmul 
not x23,x23
addi x23,x23,1 
endmul:
mv x14,x23 # copy to current imag 

# multiply (real + imag) * (real - imag)

mv x20,x18 
mv x21,x19 
li x23,0 

srli x24,x20,31 # sign of real + imag
srli x25,x21,31 # sign of real - imag

#if real is negative, convert to positive

beq x24,x0,is_positive_2 
not x20,x20
addi x20,x20,1
is_positive_2:

#if imag is negative, convert to positive
beq x25,x0,compute_result_sign_2
not x21,x21
addi x21,x21,1

compute_result_sign_2:
xor x25,x24,x25

start_mult_2:
andi x22,x21,1
beq x0,x22, parte2_2
add x23,x23,x20
parte2_2:
slli x20,x20,1
srli x21,x21,1
bne x21,x0,start_mult_2

srai x23,x23,13 # shift 13, as 13 decimals each
beqz x25,endmul_2 
not x23,x23
addi x23,x23,1 
endmul_2:
mv x13,x23 # copy to current real

add x14,x14,x12 # add original imaginary
add x13,x13,x11 # add original real 
addi x16,x16,1 # add 1 iteration

j mandel_loop

end_mandel:
addi x9,x9,1 # add 1 to h_count
add x11,x11,x4 # add real_step to current real value

j render_pixel 
end_render_pixel:
lui x2,0xFFFF4 
ori x2,x2,0x200 # Load pointer to .data segment in x2

j h_loop
end_horizontal: 

li x9,0 # reset h_count
addi x8,x8,1 # v_count++
sub x12,x12,x5 # substract imaginary_step to current imaginary value
mv x11,x10 # reset real axis to -1.
j v_loop

end_vertical: j end_vertical

# render pixel at current position

render_pixel: 

srli x16,x16,1 # Divide iter by two
lbu x25,0(x2)

addi x2,x2,80 # Point to G value
slli x25,x25,4 
lbu x24,0(x2)
add x25,x25,x24 # Now RG 

addi x2,x2,80 # Point to B value
slli x25,x25,4 
lbu x24,0(x2)
add x25,x25,x24 # Now RGB

bnez x26, procedure_B

srli x28,x25,4  # get RG
sb x28,0(x27) # store RG

slli x28,x25,4 # get B 
lb x29,1(x27)
andi x29,x29,0x0F
or x29,x29,x28 
sb x29,1(x27) # Store B

li x26,1 # Next time use procedure B
addi x27,x27,1 # Add 1 to pixel address pointer
j end_render_pixel

procedure_B:

srli x28,x25,8  # get R 
lbu x29,0(x27)
andi x29,x29,0xF0
or x29,x29,x28 
sb x29,0(x27) # save R 
sb x25,1(x27) # save GB 

li x26,0 # Next time use procedure A
addi x27,x27,2 # Add 2 to pixel address pointer
j end_render_pixel













