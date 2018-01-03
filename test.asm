	processor 6502
	org $1000

screen_mem_ptr		equ	$2	; $0400 is the address to store here
player_location		equ	$4	; player location is a pointer to an address in the screen memory
player_color_location	equ	$19
current_sprite		equ	$FB	; which sprite to draw
timer			equ	$FD	; timer for sprite

main:
	sei
	lda #0
	sta $d020	; border color	
	sta $D021	; background color
	sta current_sprite
	sta timer

	sta screen_mem_ptr	; LSB of screen memory pointer
	sta player_location	; LSB of player location
	sta player_color_location
	lda #4
	sta screen_mem_ptr+1	; MSB of screen memory pointer
	lda #5
	sta player_location+1	; MSB of player location	
	lda #$D9
	sta player_color_location+1

clrscr_routine_start:
	lda #0
	tay
	sta screen_mem_ptr
	lda #4
	sta screen_mem_ptr+1

clrscr_routine:
	lda #$20
	sta (screen_mem_ptr),y
	inc screen_mem_ptr
	lda screen_mem_ptr
	cmp #0
	beq inc_screen_msb
e:
	lda screen_mem_ptr+1
	cmp #7
	bcc clrscr_routine
	lda screen_mem_ptr
	cmp #$E8		; if less then $07E8, continue clearing. $07E8 is end of screen memory
	bcc clrscr_routine
	jmp player_move
	
inc_screen_msb:
	inc screen_mem_ptr+1
	jmp e

loop:
	ldx #0
out_string:
	lda game,x
	and #$3F
	sta $04A0,x
	lda #1
	sta $D8A0,x
	inx
	cpx #40
	bne out_string

sprite_draw:
	inc timer
	lda timer
	cmp #8
	bne player_move
	lda #0
	sta timer
	tax
	lda #$21
	cpx current_sprite
	beq draw1

draw0:
	lda sprite,x
	sta $04F0,x
	inx
	cpx #4
	bne draw0
	ldx #0
	stx current_sprite
	jmp player_move

draw1:	
	lda sprite2,x
	sta $04F0,x
	inx
	cpx #4
	bne draw1
	ldx #1
	stx current_sprite

player_move:

	ldx #0
delay:
	ldy #0
delay2:
	iny
	cpy #30
	bne delay2

	dex
	cpx #0
	bne delay

left_check:
	lda #%00000100
	and $DC00	; bit #2 of $DC00 signifies paddle left
	beq left

right_check:
	lda #%00001000
	and $DC00
	beq right

up_check:
	lda #%00000001
	and $DC00
	beq up

down_check:
	lda #%00000010
	and $DC00
	beq down

fire_check:
	lda #%00010000
	and $DC00
	beq go_back

	lda #$23
	sta (player_location),y
	
	lda #1
	sta (player_color_location),y

	jmp loop

go_back:
	jmp clrscr_routine_start	

left:
	lda #$D
	sta (player_color_location),y
	dec player_location
	dec player_color_location
	lda player_location
	cmp #$FF
	beq here
	jmp right_check
here:
	dec player_location+1
	dec player_color_location+1
	jmp right_check

right:
	lda #$D
	sta (player_color_location),y
	inc player_location
	inc player_color_location
	beq here2
	jmp up_check
here2:
	inc player_location+1
	inc player_color_location+1
	jmp up_check

up:
	lda #$D
	sta (player_color_location),y
	lda player_location
	sbc #40
	sta player_location
	sta player_color_location
	bcc here3
	jmp down_check
here3:
	dec player_location+1
	dec player_color_location+1
	jmp down_check

down:
	lda #$D
	sta (player_color_location),y
	lda player_location
	adc #39
	sta player_location
	sta player_color_location
	bcs here4
	jmp fire_check 
here4:
	inc player_location+1
	inc player_color_location+1
	jmp fire_check

game dc "             ROGUELITE C64              "
sprite dc ">==<"
sprite2 dc "<==>"
