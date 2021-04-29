.text
# gp+0: now me.x
# gp+4: now me.y
# gp+8: initial me.x
# gp+12: initial me.y
# gp+16: dest.x
# gp+20: dest.y
# gp+24: flag

# main
 addi $gp,$0,0x1800		
 addi $sp,$0,0x3ffc  #stack
 mtc0 $0,$0
 
 addi $k0,$0,0 # $k0 current x
display_x:
 addi $k1,$0,0 # $k1 current y
display_y:
 sll $t0,$k0,4
 add $t0,$t0,$k1
 sll $t0,$t0,2
 lw $a2,0x1000($t0) # state at x, y (state storage starts from 1024)
 beq $a2,$0,display_skip # skip ground
 
display_next:
 add $a0,$0,$k0
 add $a1,$0,$k1
 jal display
display_skip:
 addi $k1,$k1,1
 addi $t0,$0,16
 bne $k1,$t0,display_y
 addi $k0,$k0,1
 addi $t0,$0,16
 bne $k0,$t0,display_x
 
 addi $k0,$0,1
 sw $k0,24($gp)
 mfc0 $0,$0
loop:
 j loop
 addi $v0,$0,0x32
 syscall


# func display(x, y, type)  x-a0,y-a1,type-a2
# use $s0,$s1,$s2,$s3,$s4,$t0
display:
 addi $sp,$sp,24 # func display(x, y, type)
 sw $t0,0($sp)
 sw $s0,-4($sp)
 sw $s1,-8($sp)
 sw $s2,-12($sp)
 sw $s3,-16($sp)
 sw $s4,-20($sp)
 
 addi $t0,$0,2
 bne $a2,$t0,check_type_6 # upper left of me
 lw $s4,24($gp)
 bne $s4,$0,load_addr
 sw $a0,0($gp) # update now me.x
 sw $a1,4($gp) # update now me.y
 sw $a0,8($gp) # update initial me.x
 sw $a1,12($gp) # update initial me.y
 j load_addr
 
 check_type_6:
 lw $s4,24($gp)
 bne $s4,$0,load_addr
 sw $a0,16($gp) # update now dest.x
 sw $a1,20($gp) # update now dest.y

 load_addr:
 sll $s0,$a2,8   #a2储存方块的图案编号
 j draw  #跳转到渲染方格子程序

draw:
 sll $s1,$a0,3 # $s1 x base
 addi $s2,$0,0 # $s2 x offset
draw_x:
 sll $s3,$a1,3 # $s3 y base
 addi $s4,$0,0 # $s4 y offset
draw_y:
 add $t0,$0,$s2
 sll $t0,$t0,3
 add $t0,$t0,$s4
 sll $t0,$t0,2
 add $t0,$t0,$s0
 lw $a0,0($t0) # color
 add $t0,$s3,$s4
 sll $t0,$t0,18 # y
 add $a0,$a0,$t0
 add $t0,$s1,$s2 
 sll $t0,$t0,25 # x
 add $a0,$a0,$t0
 addi $v0,$0,0x147
 syscall
 addi $s4,$s4,1
 addi $t0,$0,8
 bne $s4,$t0,draw_y
 addi $s2,$s2,1
 addi $t0,$0,8
 bne $s2,$t0,draw_x
 lw $t0,0($sp)
 lw $s0,-4($sp)
 lw $s1,-8($sp)
 lw $s2,-12($sp)
 lw $s3,-16($sp)
 lw $s4,-20($sp)
 addi $sp,$sp,-24
 jr $ra
 

# func display_character(x,y,s)
##set (x,y)->s,(x+1,y)->s+1,(x,y+1)->s+2,(x+1,y+10>s+3
## x-t5  y-t6  s-t7
## use s2,s3,t0,t2,ra
display_character: 
 addi $sp,$sp,20
 sw $s2,0($sp)
 sw $s3,-4($sp)
 sw $t0,-8($sp)
 sw $t2,-12($sp)
 sw $ra,-16($sp)
 
 addi $t2,$t7,0
 sll $t0,$t5,4   
 add $t0,$t0,$t6
 sll $t0,$t0,2
 sw $t2,0x1000($t0)		# (x,y)->s
 add $a0,$0,$t5
 add $a1,$0,$t6
 add $a2,$0,$t2
 jal display
 
 beq $t7,$0,display_character_zero1
 addi $t2,$t7,1
 j display_character_begin1
display_character_zero1:
 addi $t2,$0,0
display_character_begin1:
 add $s2,$t5,1
 sll $t0,$s2,4   
 add $t0,$t0,$t6
 sll $t0,$t0,2
 sw $t2,0x1000($t0)		# (x+1,y)->s+1
 add $a0,$0,$s2
 add $a1,$0,$t6
 add $a2,$0,$t2
 jal display
 
 beq $t7,$0,display_character_zero2
 addi $t2,$t7,2
 j display_character_begin2
display_character_zero2:
 addi $t2,$0,0
display_character_begin2:
 addi $s2,$t6,1
 sll $t0,$t5,4   
 add $t0,$t0,$s2
 sll $t0,$t0,2
 sw $t2,0x1000($t0)		# (x,y+1)->s+2 
 add $a0,$0,$t5
 add $a1,$0,$s2
 add $a2,$0,$t2
 jal display
 
 beq $t7,$0,display_character_zero3
 addi $t2,$t7,3
 j display_character_begin3
display_character_zero3:
 addi $t2,$0,0
display_character_begin3:
 addi $s2,$t5,1
 addi $s3,$t6,1
 sll $t0,$s2,4   
 add $t0,$t0,$s3
 sll $t0,$t0,2
 sw $t2,0x1000($t0)		# (x+1,y+1)->s+3 
 add $a0,$0,$s2
 add $a1,$0,$s3
 add $a2,$0,$t2
 jal display
 
 lw $s2,0($sp)
 lw $s3,-4($sp)
 lw $t0,-8($sp)
 lw $t2,-12($sp)
 lw $ra,-16($sp)
 addi $sp,$sp,-20     # return
 
 jr $ra
##################
 
# exception go_up
# use $t0,$t1,$t2,$s0,$s1,$s2,$s3,$s4,$a0,$a1,$a2
go_up:
 addi $sp,$sp,44 # exception go_up
 sw $t0,0($sp)
 sw $t1,-4($sp)
 sw $t2,-8($sp)
 sw $s0,-12($sp)
 sw $s1,-16($sp)
 sw $s2,-20($sp)
 sw $s3,-24($sp)
 sw $s4,-28($sp)
 sw $a0,-32($sp)
 sw $a1,-36($sp)
 sw $a2,-40($sp)
 lw $s0,0($gp) # me.x
 lw $s1,4($gp) # me.y
 # my location:(x,y),(x+1,y),(x,y+1),(x+1,y+1)
 addi $t0,$0,1   #x,y belongs to [1,13]
 beq $s1,$t0,go_up_not_move
 
 addi $t1,$s1,-1
 sll $t0,$s0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,y-1)
 addi $t0,$0,1
 beq $s2,$t0,go_up_not_move # wall
 
 addi $t1,$s1,-1
 addi $t0,$s0,1
 sll $t0,$t0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s3,0x1000($t0) # state at (x+1,y-1)
 addi $t0,$0,1
 beq $s3,$t0,go_up_not_move # wall
 
 #(x,y--)    get location (x,k0)
 addi $t1,$s1,-1
 addi $t2,$t1,0
go_up_y_decrease_at_x:
 addi $k0,$t2,0
 addi $t2,$t2,-1
 sll $t0,$s0,4
 add $t0,$t0,$t2
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_up_y_decrease_at_x # ground

 #(x+1,y--)   get location (x+1,k1)
 addi $s3,$s0,1   #x+1
 addi $t1,$s1,-1
 addi $t2,$t1,0
go_up_y_decrease_at_x_add_1:
 addi $k1,$t2,0
 addi $t2,$t2,-1
 sll $t0,$s3,4
 add $t0,$t0,$t2
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x+1,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_up_y_decrease_at_x_add_1 # ground
 
 #test (x,k1) : if pass test, use k1; else use k0
 sll $t0,$s0,4
 add $t0,$t0,$k1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_up_pass_test   #ground
 addi $k1,$k0,0
 
go_up_pass_test:
 #set state:(x,k1)->2 (x+1,k1)->3 (x,k1+1)->4 (x+1,k1+1)->5
 #(x,y),(x+1,y),(x,y+1),(x+1,y+1)->0
 
 sw $k1,4($gp)   #now.y = k1
 
 lw $s3,16($gp)   #dest.x
 lw $s4,20($gp)   #dest.y
 bne $s0,$s3,go_up_not_dest
 bne $k1,$s4,go_up_not_dest
 
 ## go to dest
 add $t5,$s0,$0
 add $t6,$k1,$0
 addi $t7,$0,10
 jal display_character
 
 j go_up_remove

go_up_not_dest:
 add $t5,$s0,$0
 add $t6,$k1,$0
 addi $t7,$0,2
 jal display_character
 
go_up_remove:
 addi $t2,$0,0
 add $t5,$s0,$0
 add $t6,$s1,$0
 addi $t7,$0,0
 jal display_character
 
 ##return
go_up_not_move:
 lw $t0,0($sp)
 lw $t1,-4($sp)
 lw $t2,-8($sp)
 lw $s0,-12($sp)
 lw $s1,-16($sp)
 lw $s2,-20($sp)
 lw $s3,-24($sp)
 lw $s4,-28($sp)
 lw $a0,-32($sp)
 lw $a1,-36($sp)
 lw $a2,-40($sp)
 addi $sp,$sp,-44
 eret
 
 
# exception go_down
# use $t0,$t1,$t2,$s0,$s1,$s2,$s3,$s4,$a0,$a1,$a2
go_down:
 addi $sp,$sp,44 # exception go_down
 sw $t0,0($sp)
 sw $t1,-4($sp)
 sw $t2,-8($sp)
 sw $s0,-12($sp)
 sw $s1,-16($sp)
 sw $s2,-20($sp)
 sw $s3,-24($sp)
 sw $s4,-28($sp)
 sw $a0,-32($sp)
 sw $a1,-36($sp)
 sw $a2,-40($sp)
 lw $s0,0($gp) # me.x
 lw $s1,4($gp) # me.y
 # my location:(x,y),(x+1,y),(x,y+1),(x+1,y+1)
 addi $t0,$0,13   #x,y belongs to [1,13]
 beq $s1,$t0,go_down_not_move
 
 addi $t1,$s1,2
 sll $t0,$s0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,y+2)
 addi $t0,$0,1
 beq $s2,$t0,go_down_not_move # wall
 
 addi $t1,$s1,2
 addi $t0,$s0,1
 sll $t0,$t0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s3,0x1000($t0) # state at (x+1,y+2)
 addi $t0,$0,1
 beq $s3,$t0,go_down_not_move # wall
 
 #(x,y++)    get location (x,k0)
 addi $t1,$s1,2
 addi $t2,$t1,0
go_down_y_increase_at_x:
 addi $k0,$t2,0
 addi $t2,$t2,1
 sll $t0,$s0,4
 add $t0,$t0,$t2
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_down_y_increase_at_x # ground


 #(x+1,y++)   get location (x+1,k1)
 addi $s3,$s0,1   #x+1
 addi $t1,$s1,1
 addi $t2,$t1,0
go_down_y_increase_at_x_add_1:
 addi $k1,$t2,0
 addi $t2,$t2,1
 sll $t0,$s3,4
 add $t0,$t0,$t2
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x+1,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_down_y_increase_at_x_add_1 # ground
 
 
 #test (x,k1) : if pass test, use k1; else use k0
 sll $t0,$s0,4
 add $t0,$t0,$k1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_down_pass_test   #ground
 addi $k1,$k0,0
 
go_down_pass_test:
 addi $k1,$k1,-1  #  get upper location
 
 #set state:(x,k1)->2 (x+1,k1)->3 (x,k1+1)->4 (x+1,k1+1)->5
 #(x,y),(x+1,y),(x,y+1),(x+1,y+1)->0
 
 sw $k1,4($gp)   #now.y = k1
 
 lw $s3,16($gp)   #dest.x
 lw $s4,20($gp)   #dest.y
 bne $s0,$s3,go_down_not_dest
 bne $k1,$s4,go_down_not_dest
 
 ## go to dest
 add $t5,$s0,$0
 add $t6,$k1,$0
 addi $t7,$0,10
 jal display_character
 
 j go_down_remove


go_down_not_dest:
 add $t5,$s0,$0
 add $t6,$k1,$0
 addi $t7,$0,2
 jal display_character
 
go_down_remove:
 add $t5,$s0,$0
 add $t6,$s1,$0
 addi $t7,$0,0
 jal display_character
 
 ##return
go_down_not_move:
 lw $t0,0($sp)
 lw $t1,-4($sp)
 lw $t2,-8($sp)
 lw $s0,-12($sp)
 lw $s1,-16($sp)
 lw $s2,-20($sp)
 lw $s3,-24($sp)
 lw $s4,-28($sp)
 lw $a0,-32($sp)
 lw $a1,-36($sp)
 lw $a2,-40($sp)
 addi $sp,$sp,-44
 eret
 
# exception go_left
# use $t0,$t1,$t2,$s0,$s1,$s2,$s3,$s4,$a0,$a1,$a2
go_left:
 addi $sp,$sp,44 # exception go_left
 sw $t0,0($sp)
 sw $t1,-4($sp)
 sw $t2,-8($sp)
 sw $s0,-12($sp)
 sw $s1,-16($sp)
 sw $s2,-20($sp)
 sw $s3,-24($sp)
 sw $s4,-28($sp)
 sw $a0,-32($sp)
 sw $a1,-36($sp)
 sw $a2,-40($sp)
 lw $s0,0($gp) # me.x
 lw $s1,4($gp) # me.y
 # my location:(x,y),(x+1,y),(x,y+1),(x+1,y+1)
 addi $t0,$0,1   #x,y belongs to [1,13]
 beq $s0,$t0,go_left_not_move
 
 addi $t1,$s0,-1
 sll $t0,$t1,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x-1,y)
 addi $t0,$0,1
 beq $s2,$t0,go_left_not_move # wall
 
 addi $t1,$s1,1
 addi $t0,$s0,-1
 sll $t0,$t0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s3,0x1000($t0) # state at (x-1,y+1)
 addi $t0,$0,1
 beq $s3,$t0,go_left_not_move # wall
 
 #(x--,y)    get location (k0,y)
 addi $t1,$s0,-1
 addi $t2,$t1,0
go_left_x_decrease_at_y:
 addi $k0,$t2,0
 addi $t2,$t2,-1
 sll $t0,$t2,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_left_x_decrease_at_y # ground

 #(x--,y+1)   get location (k1,y+1)
 addi $s3,$s1,1   #y+1
 addi $t1,$s0,-1
 addi $t2,$t1,0
go_left_x_decrease_at_y_add_1:
 addi $k1,$t2,0
 addi $t2,$t2,-1
 sll $t0,$t2,4
 add $t0,$t0,$s3
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x+1,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_left_x_decrease_at_y_add_1 # ground
 
 #test (k1,y) : if pass test, use k1; else use k0
 sll $t0,$k1,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_left_pass_test   #not ground
 addi $k1,$k0,0
 
go_left_pass_test:
 #set state:(k1,y)->2 (k1+1,y)->3 (k1,y+1)->4 (k1+1,y+1)->5
 #(x,y),(x+1,y),(x,y+1),(x+1,y+1)->0
 
 sw $k1,0($gp)   #now.x = k1
 
 lw $s3,16($gp)   #dest.x
 lw $s4,20($gp)   #dest.y
 bne $k1,$s3,go_left_not_dest
 bne $s1,$s4,go_left_not_dest
 
 ## go to dest
 add $t5,$k1,$0
 add $t6,$s1,$0
 addi $t7,$0,10
 jal display_character
 
 j go_left_remove


go_left_not_dest:
 add $t5,$k1,$0
 add $t6,$s1,$0
 addi $t7,$0,2
 jal display_character
 
go_left_remove:
 add $t5,$s0,$0
 add $t6,$s1,$0
 addi $t7,$0,0
 jal display_character
 
 ##return
go_left_not_move:
 lw $t0,0($sp)
 lw $t1,-4($sp)
 lw $t2,-8($sp)
 lw $s0,-12($sp)
 lw $s1,-16($sp)
 lw $s2,-20($sp)
 lw $s3,-24($sp)
 lw $s4,-28($sp)
 lw $a0,-32($sp)
 lw $a1,-36($sp)
 lw $a2,-40($sp)
 addi $sp,$sp,-44
 eret
 
 
# exception go_right
# use $t0,$t1,$t2,$s0,$s1,$s2,$s3,$s4,$a0,$a1,$a2
go_right:
 addi $sp,$sp,44 # exception go_right
 sw $t0,0($sp)
 sw $t1,-4($sp)
 sw $t2,-8($sp)
 sw $s0,-12($sp)
 sw $s1,-16($sp)
 sw $s2,-20($sp)
 sw $s3,-24($sp)
 sw $s4,-28($sp)
 sw $a0,-32($sp)
 sw $a1,-36($sp)
 sw $a2,-40($sp)
 lw $s0,0($gp) # me.x
 lw $s1,4($gp) # me.y
 # my location:(x,y),(x+1,y),(x,y+1),(x+1,y+1)
 addi $t0,$0,13   #x,y belongs to [1,13]
 beq $s0,$t0,go_right_not_move
 
 addi $t1,$s0,2
 sll $t0,$t1,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x+2,y)
 addi $t0,$0,1
 beq $s2,$t0,go_right_not_move # wall
 
 addi $t1,$s1,1
 addi $t0,$s0,2
 sll $t0,$t0,4
 add $t0,$t0,$t1
 sll $t0,$t0,2
 lw $s3,0x1000($t0) # state at (x+2,y+1)
 addi $t0,$0,1
 beq $s3,$t0,go_right_not_move # wall
 
 #(x++,y)    get location (k0,y)
 addi $t1,$s0,2
 addi $t2,$t1,0
go_right_x_increase_at_y:
 addi $k0,$t2,0
 addi $t2,$t2,1
 sll $t0,$t2,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_right_x_increase_at_y # ground

 #(x++,y+1)   get location (k1,y+1)
 addi $s3,$s1,1   #y+1
 addi $t1,$s0,2
 addi $t2,$t1,0
go_right_x_increase_at_y_add_1:
 addi $k1,$t2,0
 addi $t2,$t2,1
 sll $t0,$t2,4
 add $t0,$t0,$s3
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x+1,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_right_x_increase_at_y_add_1 # ground
 
 #test (k1,y) : if pass test, use k1; else use k0
 sll $t0,$k1,4
 add $t0,$t0,$s1
 sll $t0,$t0,2
 lw $s2,0x1000($t0) # state at (x,t2)
 addi $t0,$0,1
 bne $s2,$t0,go_right_pass_test   #not ground
 addi $k1,$k0,0
 
go_right_pass_test:
 addi $k1,$k1,-1  #  get upper location
 #set state:(k1,y)->2 (k1+1,y)->3 (k1,y+1)->4 (k1+1,y+1)->5
 #(x,y),(x+1,y),(x,y+1),(x+1,y+1)->0
 
 sw $k1,0($gp)   #now.x = k1
 
 lw $s3,16($gp)   #dest.x
 lw $s4,20($gp)   #dest.y
 bne $k1,$s3,go_right_not_dest
 bne $s1,$s4,go_right_not_dest
 
 ## go to dest
 add $t5,$k1,$0
 add $t6,$s1,$0
 addi $t7,$0,10
 jal display_character
 
 j go_right_remove

go_right_not_dest:
 add $t5,$k1,$0
 add $t6,$s1,$0
 addi $t7,$0,2
 jal display_character
 
go_right_remove:
 add $t5,$s0,$0
 add $t6,$s1,$0
 addi $t7,$0,0
 jal display_character
 
 ##return
go_right_not_move:
 lw $t0,0($sp)
 lw $t1,-4($sp)
 lw $t2,-8($sp)
 lw $s0,-12($sp)
 lw $s1,-16($sp)
 lw $s2,-20($sp)
 lw $s3,-24($sp)
 lw $s4,-28($sp)
 lw $a0,-32($sp)
 lw $a1,-36($sp)
 lw $a2,-40($sp)
 addi $sp,$sp,-44
 eret
 
 
 
#Exception restart
#use $s0,$s1,$s2,$s3
go_restart:
 addi $sp,$sp,16   # exception restart
 sw $s0,0($sp)
 sw $s1,-4($sp)
 sw $s2,-8($sp)
 sw $s3,-12($sp)
 
 lw $s0,8($gp)     #init.x
 lw $s1,12($gp)     #init.y
 lw $s2,0($gp)     #now.x
 lw $s3,4($gp)	   #now.y
 bne $s0,$s2,go_restart_moved
 bne $s1,$s3,go_restart_moved
 j go_restart_not_move
 
 # reset start point:
go_restart_moved: 
 lw $t5,8($gp)     #init.x
 lw $t6,12($gp)     #init.y
 addi $t7,$0,2
 jal display_character   # (init.x,init.y)->2

 lw $s0,0($gp)		#now.x
 lw $s1,4($gp)	 	#now.y
 lw $s2,16($gp)		#dest.x
 lw $s3,20($gp)		#dest.y
 bne $s0,$s2,go_restart_not_dest
 bne $s1,$s3,go_restart_not_dest
 
 ## reset dest status:
 add $t5,$s2,$0
 add $t6,$s3,$0
 addi $t7,$0,6
 jal display_character		# (dest.x,dest.y)->6
 j go_restart_not_move
  
go_restart_not_dest:
 lw $t5,0($gp)		#now.x
 lw $t6,4($gp)	 	#now.y
 addi $t7,$0,0
 jal display_character		# (now.x,now.y)->0
 
 
go_restart_not_move:

 lw $s0,8($gp)     #init.x
 lw $s1,12($gp)     #init.y
 sw $s0,0($gp)
 sw $s1,4($gp)
 
 lw $s0,0($sp)
 lw $s1,-4($sp)
 lw $s2,-8($sp)
 lw $s3,-12($sp)
 addi $sp,$sp,-16
 eret

 
 
 
 
 
