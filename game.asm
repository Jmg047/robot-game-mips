.data
x:      .word   0:4     # x-coordinates of 4 robots
y:      .word   0:4     # y-coordinates of 4 robots

str1:   .asciiz "Your coordinates: 25 25\n"
str2:   .asciiz "Enter move (1 for +x, -1 for -x, 2 for + y, -2 for -y):"
str3:   .asciiz "Your coordinates: "
sp:     .asciiz " "
endl:   .asciiz "\n"
str4:   .asciiz "Robot at "
str5:   .asciiz "AAAARRRRGHHHHH... Game over\n"

# i       $s0
# myX     $s1
# myY     $s2
# move    $s3
# status  $s4
# temp,pointers $s5,$s6
.text
#   .globl    inc
#   .globl    getNew

main:   li    $s1,25        # myX = 25
    li    $s2,25        # myY = 25
    li    $s4,1         # status = 1

    la    $s5,x     # Load address of x into $s5
    la    $s6,y     # Load address of y into $s6

    sw    $0,($s5)    # x[0] = 0; y[0] = 0;
    sw    $0,($s6)
    sw    $0,4($s5)    # x[1] = 0; y[1] = 50;
    li    $s7,50
    sw    $s7,4($s6)
    sw    $s7,8($s5)    # x[2] = 50; y[2] = 0;
    sw    $0,8($s6)
    sw    $s7,12($s5)   # x[3] = 50; y[3] = 50;
    sw    $s7,12($s6)

    la    $a0,str1    # cout << "Your coordinates: 25 25\n";
    li    $v0,4
    syscall

main_loop:
    bne    $s4,1,main_exit    # while (status == 1) {
    main_while:
	la	$a0,str2	#    cout << "Enter move (1 for +x,
	li	$v0,4		#	-1 for -x, 2 for + y, -2 for -y):";
	syscall

	li	$v0,5		#    cin >> move;
	syscall
	move	$s3,$v0

	bne	$s3,1,main_else1#    if (move == 1)
	add	$s1,$s1,1	#      myX++;
	b	main_exitif
main_else1:
	bne	$s3,-1,main_else2	#    else if (move == -1)
	add	$s1,$s1,-1	#      myX--;
	b	main_exitif
main_else2:
	bne	$s3,2,main_else3	#    else if (move == 2)
	add	$s2,$s2,1	#      myY++;
	b	main_exitif
main_else3:	bne	$s3,-2,main_exitif	#    else if (move == -2)
	add	$s2,$s2,-1	#      myY--;

main_exitif:	la	$a0,x		#    status = moveRobots(&x[0],&y[0],myX,myY);
	la	$a1,y
	move	$a2,$s1
	move	$a3,$s2
	jal	moveRobots
	loc:
	move	$s4,$v0

	la	$a0,str3	#    cout << "Your coordinates: " << myX
	li	$v0,4		#      << " " << myY << endl;
	syscall
	move	$a0,$s1
	li	$v0,1
	syscall
	la	$a0,sp
	li	$v0,4
	syscall
	move	$a0,$s2
	li	$v0,1
	syscall
	la	$a0,endl
	li	$v0,4
	syscall

	la	$s5,x
	la	$s6,y
	li	$s0,0		#    for (i=0;i<4;i++)
main_for:	la	$a0,str4	#      cout << "Robot at " << x[i] << " "
	li	$v0,4		#           << y[i] << endl;
	syscall
	lw	$a0,($s5)
	li	$v0,1
	syscall
	la	$a0,sp
	li	$v0,4
	syscall
	lw	$a0,($s6)
	li	$v0,1
	syscall
	la	$a0,endl
	li	$v0,4
	syscall
	add	$s5,$s5,4
	add	$s6,$s6,4
	add	$s0,$s0,1
	blt	$s0,4,main_for

	beq	$s4,1,main_while
				#  }
main_exit:
    la    $a0,str5    # cout << "AAAARRRRGHHHHH... Game over\n";
    li    $v0,4
    syscall
    li    $v0,10       # Exit program
    syscall

moveRobots:
    	li $s0, 0 		#int i
	
	sw $s7, ($a0)		#move x[0] content to $s6
	
	move $t3, $t7		#ptrX ($t3) = arg0 = x[0] ($s6)
	
	move $s3, $a1		#move y[0] content
	move $t4, $s3		#ptrY = arg1 = y[0] ($s3)

	li $t5, 1		 #alive, $t5 = 1
	
	exitloop: 
	blt $s0, 4, continue
	j loc
	continue:
	 		#  for (i=0;i<4;i++) {
	la $a0, 4($t3) 		#$a0 will hold *ptrX
	move $a1, $a2		 #$a1 will hold arg2
	jal getNew
	la $t3, ($v0) 		 #*ptrX = getNew (*ptrX,arg2)
	
	
	la $a0, ($t4) 		#$a0 will hold *ptrY
	move $a1, $a3		#$a1 will hold arg3
	jal getNew              
	la $t4, ($v0)		#*ptr = getNew (*ptrY,arg3)
										
										
	beq $t3, $a2, if_2	#(*ptrX == arg2)
	
	
	add $t3, $t3, 1		#ptrX++

	add $t4, $t4, 1		#ptrY++ 
				#}
	add $s0, $s0, 1 	#i++
	move $v0, $t5		#return alive;
			#}
	
	bgt $s0, 4, exitloop		   					      			   					     		   					      			   					     
	
	nextAction: 		#(*ptrX == arg2) && (*ptrY == arg3) = true {
	#li $t5, 0		#alive ($t5) = 0				   					      
	j breaklab		#break;
				#}
	move $v0, $t5		#return alive;
	jr $ra	
			#}
			
	if_2:			#(*ptrY == arg3)
	beq $t4, $a3, nextAction		
			
	breaklab:
	add $s0, $s0, 1 	#i++
	j exitloop

    jr    $ra

getNew:
    li $t0, 0 		#temp
    li $t1, 0		#result
    sub $t0, $a0, $a1	#  temp = arg0 - arg1;
	
    blt $t0, 10, else_if1	
    move $t1, $a0	   #  if (temp >= 10)
    sub $t1, $t1, 10	   # 		result = arg0 - 10;
  	
    else_if1:
    ble $t0, 0, else_if2   #  else if (temp > 0)
    move $t1, $a0
    sub $t1, $t1, 1	   #    result = arg0 - 1;
	
    else_if2:
    bne $t0, 0, else_if3	
    move $t1, $a0	   #  else if (temp == 0)
	              	   #    result = arg0;
	
    else_if3:
    ble $t0, -10, else_if4 #  else if (temp > -10)
    move $t1, $a0
    add $t1, $a0,          #    result = arg0 + 1;
	
    else_if4:
    bgt $t0, -10, endCase  #  else if (temp <= -10)
    move $t1, $a0
    add $t1, $a0, 10	   #    result = arg0 + 10;
	
    move $v0, $t1	   #return result	 (final else-if == false)     
    jr $ra		   #					
					      
    endCase: 				      
    move $v0, $t1				      
    jr    $ra