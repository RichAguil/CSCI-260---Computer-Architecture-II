.data
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
m: .word 20
n: .word 40
c1r: .word 0xC0392B
c1g: .word 0xDAF7A6
c1b: .word 0x5DADE2
c2r: .word 0xFF5733 
c2g: .word 0x29FF00 
c2b: .word 0x3498DB 
c3r: .word 0xFF0000 
c3g: .word 0x000000 
c3b: .word 0x1100FF 

.text

background:
li $a0, 0 #x value initial
li $a1, 512 #width size
li $a2, 0 #y value initial
li $a3, 256 # height size
lw $t0, c1r #Loading colors
lw $t1, c1g
lw $t2, c1b
addu $t0, $t0, $t1 #Mixing colors, adding red and green
addu $t0, $t0, $t2 #adding red/green mix and blue
jal draw #jump and link, this stores the return address in the $ra register, allowing one to come back after subroutine is finished

square:
lw $t0, c2r #Loading color
lw $t4, c2g
lw $t7, c2b
addu $t0, $t0, $t4 #Mixing colors
addu $t0, $t0, $t7
li $t6, 256 #Half width of display
lw $t1, n #width and height of square
li $t2, 128 #half height of display
srl $t3, $t1, 1 #divides n in 2
subu $t6, $t6, $t3 #starting x position of square
subu $t5, $t2, $t3 #starting y position of square 
move $a0, $t6 #This moves the x starting value into the argument register
move $a1, $t1 #This moves the width of the square into the argument register
move $a2, $t5 #This moves the y starting value into the argument register
move $a3, $t1 #This moves the height of the square into the argument register
jal draw

topRectangle:
li $t6, 256 #Half width of display
lw $t1, n #width of rectangle
li $t2, 128 #half height of display
lw $t3, m #height of rectangle
srl $t7, $t1, 1 #divides n in 2
subu $t6, $t6, $t3 #starting x position of rectangle
subu $t5, $t2, $t7 #intermediate subtraction
subu $t5, $t5, $t3 #starting y position of rectangle
move $a0, $t6
move $a1, $t1
move $a2, $t5
move $a3, $t3
lw $t0, c3r#Loading color
lw $t1, c3g
lw $t2, c3b
addu $t0, $t0, $t1 #Mixing Colors
addu $t0, $t0, $t2
jal draw

bottomRectangle:
li $t6, 256 #Half width of display
lw $t1, n #width of rectangle
li $t2, 128 #half height of display
lw $t3, m #height of rectangle
srl $t7, $t1, 1 #divides n in 2
subu $t6, $t6, $t3 #starting x position of rectangle
addu $t5, $t2, $t7 #starting y position
move $a0, $t6
move $a1, $t1
move $a2, $t5
move $a3, $t3
lw $t0, c3r#Loading color
lw $t1, c3g
lw $t2, c3b
addu $t0, $t0, $t1 #Mixing Colors
addu $t0, $t0, $t2
jal draw

leftRectangle:
li $t6, 256 #Half width of display
lw $t1, m #width of rectangle
li $t2, 128 #half height of display
lw $t3, n #height of rectangle
srl $t7, $t1, 1 #divides n in 2
subu $t6, $t6, $t3 #starting position
subu $t5, $t2, $t1 #tarting y position 
move $a0, $t6
move $a1, $t1
move $a2, $t5
move $a3, $t3
lw $t0, c3r#Loading color
lw $t1, c3g
lw $t2, c3b
addu $t0, $t0, $t1 #Mixing Colors
addu $t0, $t0, $t2
jal draw

rightRectangle:
li $t6, 256 #Half width of display
lw $t1, m #height of rectangle
li $t2, 128 #half height of display
lw $t3, n #width of rectangle
srl $t7, $t1, 1 #divides n in 2
addu $t6, $t6, $t1 #starting position
subu $t5, $t2, $t1 #starting y position
move $a0, $t6
move $a1, $t1
move $a2, $t5
move $a3, $t3
lw $t0, c3r#Loading color
lw $t1, c3g
lw $t2, c3b
addu $t0, $t0, $t1 #Mixing Colors
addu $t0, $t0, $t2
jal draw

li $v0, 10
syscall

draw: #This draw function draws the rectangle
beq $a1,$zero,Exit #This checks if the width is zero. If it is, branch to the exit label
beq $a3,$zero,Exit #This does the same for the height

beq $a1, 512, checkHeight #This line and the next are >= comparison. Checks if == to 512, continues if it is
slti $t8, $a1, 512 #If $a1 = wdith greater than 512, set $t8 = 0
beq $t8, $zero, Exit #the program exits if the width supplied is bigger than display

checkHeight: beq $a3, 256, continue #Does the same as above, except it checks height
slti $t8, $a3, 256 
beq $t8, $zero, Exit

continue:
la $t1,frameBuffer #Loading base address of frameBuffer
add $a1,$a1,$a0 # this register contains the first row
add $a3,$a3,$a2
sll $a0,$a0,2 # scale x values (every pixel has 4 bytes)
sll $a1,$a1,2
sll $a2,$a2,11 # scale y values (2048 bytes per row)
sll $a3,$a3,11
addu $t2,$a2,$t1 # this register contains the row starting addresses
addu $a3,$a3,$t1
addu $a2,$t2,$a0 # this converts $a2 into rectangle row starting addresses
addu $a3,$a3,$a0
addu $t2,$t2,$a1 # ending address for rectangle to be drawn
li $t4, 2048 # this is the incrementer. it will increment by 1 row (2048 bytes)

rowLoop:
move $t3,$a2 # holds current pixel in the row

columnLoop:
sw $t0,($t3) #stores the color in the frameBuffer array to change the color of the pixel
addiu $t3,$t3,4 #increment to next pixel in the row
bne $t3,$t2,columnLoop #this checks if the right edge of the rectangle has been reached
addu $a2,$a2,$t4 #left edge is incremented by one row
addu $t2,$t2,$t4 #right edge also incremented by one row
bne $a2,$a3,rowLoop #this checks if the bottom edge of the rectangle has been reached

jr $ra

Exit:
li $v0, 10
syscall
