#####################################################################
#
# CSCB58 Winter 2024 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Nikolos Zegas-Tepper, 1009196503, tepperni, nikolos.zegastepper@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.eqv BASE_ADDRESS 0x10008000

.eqv PLAYER_SPEED 1
.eqv GRAVITY 1
.eqv TURTLE_SPEED 1
.eqv DRIP_SPEED   3

# colours
.eqv EMPTY_HEART 0x533a20 
.eqv HEALTH_LOC 976

.eqv RED 0xff0000 # HEART + 1HP HAT + DRAGON FIRE
.eqv WHITE 0xffffff
.eqv BLACK 0x000000 
.eqv GOLD 0xf1e504
.eqv ORANGE 0xff5604

.eqv HAT_D1 0xd400ff #3hp
.eqv HAT_D2 0xeaff00 #2hp

.eqv EDGE 0x702e0e
.eqv BACK 0xbc5a2a

.eqv TURTLE1_GREEN 0x12b112
.eqv TURTLE_SPIKE 0xa29994
.eqv STALA 0x4e4444
.eqv ACID_GREEN 0x3eff09
.eqv TURTLE2_GREEN 0x50bc2a

.data
MAIN_POS:	.word 6, 7   	# characters position, operating on coord grid (x, y): x,y in [0, 63] (6,7)
MAIN_HEALTH:	.word 3		# begin with 3 hp

TURTLE1_POS:	.word 17, 21, 1	# start moving right (use 3rd variable 4=right -4=left) (17,21,1)
TURTLE2_POS: 	.word 50, 47, 1	# same as above

DRIP_POS:	.word 16, 28 	# track drips (SINCE ALL ARE IN A LINE, ONLY NEED 1 COORD) change to actual pos before implement
DRIP_TIMER:	.word 0

.text
.globl main 

#TODO:		
# - GET IT ALL MOVING (PLAYER + ENEMIES)
#    - HARD BOUNDARIES (edges)
# - COLLISION BETWEEN THEM AND PLAYER
#    - DAMAGE
# - RESTART
# - victory / loss screen?


#WANT menu (+1), shooting(?), moving enemies (+2), diff damage level colours (+2). ez 5.
#NEED score for win/lose? consider big rocks that reach the end? or coins?

main:
	jal draw_stage
	j loop

	
loop:
	li $a0 1 #THIS AND BELOW DELETES 
	jal draw_player #PLAYER
	jal draw_turtle1
	jal draw_turtle2
	jal draw_acid
	li $a0, 0 #RESET HARD CHECK FOR THIS CLOCK CYCLE

	
	jal grav
	jal handle_input
	jal move_enemies
	
	la $t0, DRIP_TIMER #same for drip
	lw $t1, 0($t0)
	addi $t1, $t1, 40
	sw $t1, 0($t0)
	#bgt $t1 1400 move_acid
	
	la $t0, DRIP_POS
	lw $t1, 4($t0)
	#beq
	
	
	
	jal draw_player
	jal draw_turtle1
	jal draw_turtle2
	jal draw_acid
	
	#DO SAME FOR DRIPS, TURTLE
	
	#THIS WILL WORK LIKE
	#remove player, check input, move player
		# left right standard, if down then down (no air strafing)
	#remove enemies, update enemies, move enemies
	#check collision on all enemies
		# if collision, play death animation
		# decrement health, gray heart
		# if 0 game over screen, else restart at top (RESET .data, call loop again) maybe check on top of game loop??
	#check y > 57 for victory screen
		
		
		
sleep:
	li $v0, 32 #MARS instruction for sleep
	li $a0, 40 #sleep for 40ms
	syscall

	j loop #restart loop

handle_input:
	li $t9, 0xffff0000
	lw $t8, 0($t9)
	bne $t8, 1, return
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before

	beq $t2, 97, left #a was pressed
	beq $t2, 100, right #d
	beq $t2, 114, restart #r
	beq $t2, 113, exit #q

	jr $ra #any other input is invalid

left:
	la $t0 BASE_ADDRESS
	la $t1, MAIN_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	add $t1, $t1, -8 #want just left of player
	
	lw $t4, 0($t1) #CHECK ALL 5 PIXELS LEFT OF PLAYER 
	beq $t4, EDGE, return
	lb $t4, 256($t1)
	beq $t4, EDGE, return
	lb $t4, 512($t1)
	beq $t4, EDGE, return
	lb $t4, -256($t1)
	beq $t4, EDGE, return
	lb $t4, -512($t1)
	beq $t4, EDGE, return
	
	la $t0, MAIN_POS #same for drip
	lw $t1, 0($t0)
	addi $t1, $t1, -PLAYER_SPEED
	sw $t1, 0($t0)
	
	jr $ra

right:
	la $t0 BASE_ADDRESS
	la $t1, MAIN_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	add $t1, $t1, 8 #want just right of player
	
	lw $t4, 0($t1) #CHECK ALL 5 PIXELS RIGHT OF PLAYER
	beq $t4, EDGE, return
	lb $t4, 256($t1)
	beq $t4, EDGE, return
	lb $t4, 512($t1)
	beq $t4, EDGE, return
	lb $t4, -256($t1)
	beq $t4, EDGE, return
	lb $t4, -512($t1)
	beq $t4, EDGE, return
	
	la $t0, MAIN_POS #same for drip
	lw $t1, 0($t0)
	addi $t1, $t1, PLAYER_SPEED
	sw $t1, 0($t0)
	
	jr $ra

grav:
	la $t0 BASE_ADDRESS
	la $t1, MAIN_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	add $t1, $t1, 768 #want just right of player
	
	lw $t4, 0($t1) 
	beq $t4, EDGE, return
	lb $t4, 4($t1)
	beq $t4, EDGE, return
	lb $t4, -4($t1)
	beq $t4, EDGE, return

	
	la $t0, MAIN_POS #same for drip
	lw $t1, 4($t0)
	addi $t1, $t1, GRAVITY
	sw $t1, 4($t0)
	
	jr $ra

restart:
	
	
	#change all variables to default
	
	# j main redraw everything (cause sometimes clippy stuff wants to be fixed)
	
move_enemies:
	la $t1, TURTLE1_POS
	lw $t2, 0($t1) #check x value
	lw $t3, 8($t1)
	add $t2, $t2, $t3 #add + x
	sw $t2, 0($t1)
	
	#check if need to change direction
	beq $t2, 60, change_turtle1 
	beq $t2, 15, change_turtle2 
	j move_turtle2	
	
	
change_turtle1:
	li $t3 -1
	sw $t3 8($t1)
	j move_turtle2
	
change_turtle2:
	li $t3 1
	sw $t3 8($t1)
	j move_turtle2

move_turtle2:
	la $t1, TURTLE2_POS
	lw $t2, 0($t1) #check x value
	lw $t3, 8($t1)
	add $t2, $t2, $t3 #add + x
	sw $t2, 0($t1)
	
	#check if need to change direction
	beq $t2, 60, change_turtle3 
	beq $t2, 12, change_turtle4 
	jr $ra
	
change_turtle3:
	li $t3 -1
	sw $t3 8($t1)
	jr $ra
	
change_turtle4:
	li $t3 1
	sw $t3 8($t1)
	jr $ra
	
	
	jr $ra
#player drawing
draw_player:
	la $t0, BASE_ADDRESS #framebuffer
	la $t1, MAIN_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	
	#determine health level
	lw $t3, MAIN_HEALTH #get health

	li $t2, BLACK 
	beq $a0, 1, load_clear #HARD CHECK FOR REMOVE PLAYER
	beq $a0, 2, load_green #FOR ACID ANIMATION
	beq $t3, 3, load_dmg1
	beq $t3, 2, load_dmg2
	beq $t3, 1, load_dmg3
	beq $t3, 0, load_clear
#set colours based on dmg level 
load_dmg1:
	li $t3, HAT_D1
	j render_player
load_dmg2:
	li $t3, HAT_D2
	j render_player
load_dmg3:
	li $t3, RED
	j render_player
load_clear: #dead
	li $t2, BACK
	li $t3, BACK
	j render_player
load_green: #ACID ANIMATION
	li $t2, ACID_GREEN
	li $t3, TURTLE1_GREEN
	j render_player
render_player:
    sw $t2, 0($t1)
    sw $t2, 256($t1)
    sw $t2, 516($t1)
    sw $t2, 508($t1)
    sw $t2, -4($t1)
    sw $t2, 4($t1)
    sw $t2, -256($t1)
    sw $t3, -512($t1)  
    
    jr $ra
    
#turtle drawing
draw_turtle1:
	la $t0, BASE_ADDRESS #framebuffer
	la $t1, TURTLE1_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	
	li $t2, TURTLE1_GREEN
	li $t3, BLACK
	beq $a0, 1, turtle_clear
	j render_turtle
	
draw_turtle2:
	la $t0, BASE_ADDRESS #framebuffer
	la $t1, TURTLE2_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3

	#get exact pixel location
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	
	li $t2, TURTLE2_GREEN
	li $t3, BLACK
	beq $a0, 1, turtle_clear
	j render_turtle
	
turtle_clear:
	li $t2, BACK
	li $t3, BACK
	j render_turtle
render_turtle:
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	sw $t2, -4($t1)
	sw $t2, -8($t1)
	sw $t2, -256($t1)
	sw $t2, -252($t1)
	sw $t2, -260($t1)
	sw $t3, 260($t1)
	sw $t3, 252($t1)
	
	jr $ra
	
draw_acid:
	la $t0, BASE_ADDRESS #framebuffer
	la $t1, DRIP_POS #player in memory
	lw $t2, 0($t1) #get x in t2
	lw $t3, 4($t1) #get y in t3
	
	sll $t2, $t2, 2 # actual x = stored x * 4 
	sll $t3, $t3, 8 # actual y = stored y * (2^8)
	add $t1, $t0, $t2 #base + x
	add $t1, $t1, $t3 #base+x + y
	
	li $t2, ACID_GREEN
	beq $a0, 1, acid_clear
	j render_acid
	
acid_clear:
	li $t2, BACK
	
render_acid:
	sw $t2, 0($t1)
	addi $t1 $t1 72
	sw $t2, 0($t1)
	addi $t1 $t1 52
	sw $t2, 0($t1)
	addi $t1 $t1 3212
	sw $t2, 0($t1)
	
	jr $ra
	


#### STAGE DRAWING (happens once)
draw_stage:
	la $t0, BASE_ADDRESS #framebuffer
	li $t1, 0 #iterator
	li $t2, EDGE #colour
	
draw_outline1:
	bgt $t1, 252, ready_back
	add $t4, $t0, $t1
	sw $t2, 0($t4)
	addi $t1, $t1, 4
	j draw_outline1
	
ready_back:
	li $t2, BACK #colour
draw_back:
	bgt $t1, 16124, ready_outline
	add $t4, $t0, $t1 #get address of current pixel
	sw $t2, 0($t4) 
	addi $t1, $t1, 4 #iterate
	j draw_back	

ready_outline:
	li $t2, EDGE
draw_outline2:
	bgt $t1, 16380, draw_outline3
	add $t4, $t0, $t1
	sw $t2, 0($t4)
	addi $t1, $t1, 4
	j draw_outline2
draw_outline3:
	blt $t1, 256, ready_levels
	add $t4, $t0, $t1
	sw $t2, 0($t4)
	add $t4, $t4, 252
	sw $t2, 0($t4)
	subi $t1, $t1, 256
	j draw_outline3

ready_levels:
	li $t1, 2560
draw_levels:
	bgt $t1, 2816, ready_holes
	add $t4, $t0, $t1 #r1
	sw $t2, 0($t4)
	add $t4, $t4, 256 #r1.5
	sw $t2, 0($t4)
	add $t4, $t4, 3072 #r2
	sw $t2, 0($t4)
	add $t4, $t4, 256 #r2.5
	sw $t2, 0($t4)
	add $t4, $t4, 3072 #r3
	sw $t2, 0($t4)
	add $t4, $t4, 256 #r3.5
	sw $t2, 0($t4)
	add $t4, $t4, 3072 #r4
	sw $t2, 0($t4)
	add $t4, $t4, 256 #r4.5
	sw $t2, 0($t4)
	
	addi $t1, $t1, 4
	j draw_levels
	
ready_holes:
	li $t2, BACK
	li $t1, 2724
draw_holes:
	bgt $t1, 2752, ready_hearts
	add $t4, $t0, $t1
	sw $t2, 0($t4)
	add $t4, $t4, 256
	sw $t2, 0($t4)
	add $t4, $t4, 2924
	sw $t2, 0($t4)
	add $t4, $t4, 256
	sw $t2, 0($t4)
	add $t4, $t4, 3264
	sw $t2, 0($t4)
	add $t4, $t4, 256
	sw $t2, 0($t4)
	add $t4, $t4, 2876
	sw $t2, 0($t4)
	add $t4, $t4, 256
	sw $t2, 0($t4)
	
	addi $t1, $t1, 4
	j draw_holes
	
ready_hearts:
	li $t2 RED
	li $t1 0
	li $t3 HEALTH_LOC
draw_hearts:
	bgt $t1 2 draw_stala
	add $t4 $t0 $t3
	
	sw $t2 0($t4)
	sw $t2 -4($t4)
	sw $t2 -260($t4)
	sw $t2 -252($t4)
	sw $t2 4($t4)
	sw $t2 256($t4)
	
	addi $t3 $t3 16
	addi $t1 $t1 1
	j draw_hearts

draw_stala: #grey spikes
	li $t2 STALA
	li $t1 6464
	add $t1 $t0 $t1
	
	sw $t2 0($t1)
	sw $t2 256($t1)
	sw $t2 512($t1)
	sw $t2 -4($t1)
	sw $t2 4($t1)
	sw $t2 260($t1)
	
	addi $t1 $t1 72
	sw $t2 0($t1)
	sw $t2 -4($t1)
	sw $t2 4($t1)
	sw $t2 252($t1)
	sw $t2 256($t1)
	sw $t2 260($t1)
	sw $t2 512($t1)
	
	addi $t1 $t1 52
	sw $t2 0($t1)
	sw $t2 -4($t1)
	sw $t2 4($t1)
	sw $t2 252($t1)
	sw $t2 256($t1)
	sw $t2 512($t1)
	
	addi $t1 $t1 3212
	sw $t2 0($t1)
	sw $t2 -4($t1)
	sw $t2 4($t1)
	sw $t2 256($t1)
	sw $t2 260($t1)
	sw $t2 512($t1)
	
draw_gold: #TO BE COMPLETED!! just remember victory pixel is (40 , 60)
	li $t2 GOLD
	li $t1 15520
	add $t1 $t0 $t1
	
	sw $t2 0($t1)
	sw $t2 256($t1)
	sw $t2 512($t1)
	
return:
	jr $ra
	
exit:
	li $v0, 10 # exit program
	syscall
