	processor 6502
	org $0810

; POINTER TABLE BEGIN

screen_mem_current	equ	$2
color_mem_current	equ	$4
player_position		equ	$6
map_pointer		equ	$8

; POINTER TABLE END

; DECLARATIONS BEGIN

; DECLARATIONS END

; PROGRAM BEGIN

init:
	lda #0
	sta $D020
	sta $D021	; set background and border to black

	lda #3
	sta $DD00	; tell VIC-II that the character set is at bank 0
	lda #$1E
	sta $D018	; tell VIC-II that the character set starts at $bank0 + $3800

	lda #<map_data
	sta map_pointer
	lda #>map_data
	sta map_pointer+1

	jsr clear
loop:
	;jsr clear
	jsr draw_map
	jsr draw_ents
	jsr draw_player
	jsr draw_ui
	jsr music
	jmp loop

clear:
	jsr reset_mem_ptrs
	lda #0
	sta (screen_mem_current),y	; write " " to current screen memory location
	lda #15
	sta (color_mem_current),y
	iny
	tya
	bne clear+3			; to avoid writing another label, just go to clear+9, which is "lda #$20"
	inc screen_mem_current+1	; if Y goes from 255 to 0, increase MSB of screen memory
	inc color_mem_current+1
	lda screen_mem_current+1
	cmp #7
	bcc clear+3
	lda #4
	sta screen_mem_current+1	; check if we reached $0800, end of screen memory. if so, get back to $0400
	lda #$D8
	sta color_mem_current+1
	rts

reset_mem_ptrs:				; reset screen mem pointer to $0400 and color mem pointer to $D800
	lda #0
	tay
	tax
	sta screen_mem_current
	sta color_mem_current
	lda #4
	sta screen_mem_current+1
	lda #$D8
	sta color_mem_current+1
	rts

draw_map:
	jsr reset_mem_ptrs		; reset the pointers first

draw_map_loop:
	lda (map_pointer),y		; load character from map
	and #$3F			; convert ASCII to PETSCII
	sta (screen_mem_current),y	; write to screen
	iny
	cpy #23
	bcc draw_map_loop		; if Y=24, go to next line
	tya
	ldy #0
	adc map_pointer			; advance map
	bcs inc_map_ptr_MSB
store_map_ptr:
	sta map_pointer
	
	lda screen_mem_current
	adc #40				; advance screen pointer to next line
	bcs inc_screen_mem_ptr_MSB

store_screen_mem_ptr:
	sta screen_mem_current
	inx
	cpx #8
	bcc draw_map_loop		; if we reached line 8, nothing more to draw
	lda #<map_data
	sta map_pointer
	lda #>map_data
	sta map_pointer+1		; reset map pointer for next drawcall
	rts

inc_map_ptr_MSB:
	inc map_pointer+1
	jmp store_map_ptr

inc_screen_mem_ptr_MSB:
	inc screen_mem_current+1
	jmp store_screen_mem_ptr
	
draw_ents:
	rts

draw_player:
	lda #$40
	sta $0600
	rts

draw_ui:
	rts

music:
	rts

map_data: 
	.byte "   #################    "
	.byte "   #....#........<.#    "
	.byte "   #....#..........#    "
	.byte "   #....+..........#    "
	.byte "   ##########+######    "
	.byte "           #....#       "
	.byte "           #.>..#       "
	.byte "           ######       "

	org $3800

char_set:
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $0 - empty
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $4
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $5
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $6
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $7
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $8
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $9
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $A
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $B
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $C
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $D
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $E
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $F
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $10
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $11
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $12
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $13
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $14
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $15
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $16
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $17
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $18
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $19
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1A
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1B
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1C
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1D
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1E
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $1F
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $20
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $21
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $22
;	.byte $33, $EE, $99, $77, $CC, $BB, $66, $DD	; $23
	.byte $81, $42, $66, $99, $81, $42, $66, $99	; $23
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $24
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $25
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $26
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $27
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $28
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $29
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2A
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2B
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2C
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2D
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2E
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $2F
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $30
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $31
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $32
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $33
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $34
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $35
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $36
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $37
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $38
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $39
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3A
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3B
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3C
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3D
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3E
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $3F
	.byte $3C, $3C, $18, $7E, $18, $18, $3C, $66	; $40 - player
	.byte $0, $0, $0, $0, $0, $0, $0, $0	; $41





; PROGRAM END

