;-------------------------------------
;   Keyboard and Bufferless VGA Demo Assembly Program
;	Authors: Bridget Benson and Ryan Rumsey
;	Date:	5/4/16
;-------------------------------------

;------------------
;- Port Definitions
;------------------
.EQU	X_POS_EN_ID	= 0xA1	;VGA Controller port X_POS_EN
.EQU	Y_POS_ID	= 0xA2	;VGA Controller port Y_POS
.EQU	RGB_DATA_ID	= 0xA3  ;VGA Controller port RGB_DATA_IN
.EQU	OBJ_ADDR_ID	= 0xA4	;VGA Controller port OBJ_ADDR
.EQU	SSEG_ID		= 0x80  ;Seven Segment Display
.EQU	LEDS_ID		= 0x40  
.EQU	SWITCHES_ID = 0x20
.EQU	BUTTONS_ID  = 0x24
.EQU	PS2_KEY_CODE_ID = 0x30
.EQU	PS2_CONTROL_ID = 0x32

;------------------
;- Bit Masks
;------------------
.EQU	EN_MASK		= 0x80  ;Enable bit is in MSB position of X_POS_EN

;------------------------------------------------------------------
; Various Keyboard Definitions
;------------------------------------------------------------------
.EQU KEY_UP     = 0xF0        ; key release data
.EQU int_flag   = 0x01        ; interrupt hello from keyboard
.EQU UP       = 0x1D     	  ; 'w' 
.EQU LEFT     = 0x1C     	  ; 'a'
.EQU RIGHT    = 0x23     	  ; 'd'
.EQU DOWN     = 0x1B    	  ; 's'
;------------------------------------------------------------

;------------------
;- Delay Constants
;------------------
.EQU	OUTER_CONST	 = 0x7F
.EQU	MIDDLE_CONST = 0x0F
.EQU	INNER_CONST  = 0x0F
;------------------
;- VGA Boundaries
;------------------
.EQU	MAX_X		= 0xCF  ;Maximum X position
.EQU	MAX_Y		= 0x3B	;Maximum Y position
;------------------
;- Object Memory
;------------------
.EQU	OBJ0_MEM	= 0x00	;Stack address for Object 0 info
.EQU	OBJ1_MEM	= 0x03	;Stack address for Object 1 info
.EQU	OBJ2_MEM	= 0x06	;Stack address for Object 2 info
.EQU	OBJ3_MEM	= 0x09  ;Stack address for Object 3 info
.EQU	OBJ4_MEM	= 0x0C  ;Stack address for Object 4 info
.EQU	OBJ5_MEM	= 0x0F  ;Stack address for Object 5 info
.EQU	OBJ6_MEM	= 0x12  ;Stack address for Object 6 info
.EQU	OBJ7_MEM	= 0x15  ;Stack address for Object 7 info

;----------------------
;- Register Definitions
;----------------------
.DEF	R_X_POS_EN	= r0
.DEF	R_Y_POS		= r1
.DEF	R_RGB_DATA	= r2
.DEF	R_OBJ_ADDR	= r3
.DEF	R_ARGUMENT	= r31


.CSEG 
.ORG 0x01

; Draw a smiley face, person, and square on screen
init:	
			;Enable object 1 (square)
			MOV		R_X_POS_EN, 0x81			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x01
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ0_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 2 (square)
			MOV		R_X_POS_EN, 0x89			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x02
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ1_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 3 (square)
			MOV		R_X_POS_EN, 0x91			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x03
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ2_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 4 (square)
			MOV		R_X_POS_EN, 0x9A			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x04
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ3_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 5 (square)
			MOV		R_X_POS_EN, 0xA3			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x05
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ4_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 6 (square)
			MOV		R_X_POS_EN, 0xAC			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x06
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ5_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

			;Enable object 7 (square)
			MOV		R_X_POS_EN, 0xB5			
			MOV		R_Y_POS, 	0x1D
			MOV		R_RGB_DATA, 0xFF
			MOV		R_OBJ_ADDR, 0x07
			CALL	update_obj
			MOV		R_ARGUMENT, OBJ6_MEM	;Set up r31 with mem address
			CALL	set_obj_data	;Store r0-2 into stack at OBJ1_MEM

		
		
			

main:       MOV		R_ARGUMENT, OBJ2_MEM  ;select to move the man
			MOV		R_OBJ_ADDR, 0x03
			CALL    get_obj_data	
			SEI

			
loop:		IN		r20, SWITCHES_ID 	;just to test switches 
			OUT		r20, LEDS_ID		;just to test LEDS
			BRN		loop				;hang out here waiting for keyboard interrupts

		
;------------------------------------------------------------
;- These subroutines add and/or subtract '1' from the given 
;- X or Y value, depending on the direction the object was 
;- told to go. The trick here is to not go off the screen
;- so the object is moved only if there is room to move the 
;- object without going off the screen.  
;- 
;- Tweaked Registers: possibly r0, r1 (X and Y positions)
;------------------------------------------------------------
sub_x:   CMP   R_X_POS_EN ,0x80    ; see if you can move
         BREQ  done1
         SUB   R_X_POS_EN,0x01    ; move if you can
done1:   RET

sub_y:   CMP   R_Y_POS,0x00    ; see if you can move
         BREQ  done2
         SUB   R_Y_POS,0x01    ; move if you can
done2:   RET
 
add_x:   CMP   R_X_POS_EN, MAX_X    ; see if you can move
         BREQ  done3  
         ADD   R_X_POS_EN,0x01    ; move if you can
done3:   RET

add_y:   CMP   R_Y_POS,MAX_Y    ; see if you can move
         BREQ  done4   
         ADD   R_Y_POS,0x01    ; move if you can
done4:   RET


;------------------------------------
; Subroutine get_obj_data
; Loads object data (X_POS, Y_POS, and color)
; from the stack based on address in r4
;
; R_ARGUMENT (r31) - Stack address
;------------------------------------
get_obj_data:
			LD		R_X_POS_EN, (r31)
			ADD		R_ARGUMENT, 0x01
			LD		R_Y_POS, 	(r31)
			ADD		R_ARGUMENT, 0x01
			LD		R_RGB_DATA, (r31)
			RET

;------------------------------------
; Subroutine set_obj_data
; Stores object data onto the stack based on address in r4
; Uses 3 memory words
;
; R_ARGUMENT (r31) - Stack address
;------------------------------------
set_obj_data:
			ST		R_X_POS_EN, (r31)
			ADD		R_ARGUMENT, 0x01
			ST		R_Y_POS, 	(r31)
			ADD		R_ARGUMENT, 0x01
			ST		R_RGB_DATA, (r31)
			RET

;------------------------------------
; Subroutine update_obj
;
; r0 - X_POS_EN
; r1 - Y_POS
; r2 - RGB_DATA
; r3 - OBJ_ADDR

;------------------------------------
update_obj:
			MOV		r4, R_OBJ_ADDR			;r4 is temp address
			OUT		r0, X_POS_EN_ID
			OUT		r1, Y_POS_ID
			OUT		r2, RGB_DATA_ID
			OUT		r4, OBJ_ADDR_ID
			MOV		r4, 0
			OUT		r4, OBJ_ADDR_ID
			RET

;------------------------------------
; Subroutine delay
; Delays the CPU by doing a long nested loop
;
;------------------------------------
delay:
					MOV		r29, OUTER_CONST
delay_outer:		MOV		r28, MIDDLE_CONST
					CMP		r29, 0x00
					BREQ	delay_done
delay_middle:		MOV		r27, INNER_CONST
					CMP		r28, 0x00
					BREQ	delay_mid_done
delay_inner:		CMP		r27, 0x00
					BREQ	delay_inner_done
					SUB		r27, 0x01	;sub inner count
					BRN		delay_inner
delay_inner_done:	SUB		r28, 0x01	;sub middle count
					BRN		delay_middle
delay_mid_done:		SUB		r29, 0x01	;sub outer count
					BRN		delay_outer
delay_done:			RET


;--------------------------------------------------------------
; Interrup Service Routine - Handles Interrupts from keyboard
;--------------------------------------------------------------
; Sample ISR that looks for various key presses. When a useful
; key press is found, the program does something useful. The 
; code also handles the key-up code and subsequent re-sending
; of the associated scan-code. 
;
; Tweaked Registers; r6, r15
;--------------------------------------------------------------
ISR:      CMP   r15, int_flag        ; check key-up flag 
          BRNE  continue
          MOV   r15, 0x00            ; clean key-up flag
          BRN   reset_ps2_register       

continue: IN    r6, PS2_KEY_CODE_ID     ; get keycode data
          OUT	r6, SSEG_ID
move_up:  CMP   r6, UP               ; decode keypress value
          BRNE  move_down 		  
          CALL  sub_y                ; verify move is possible
          CALL  update_obj             ; draw object
          BRN   reset_ps2_register

move_down:
          CMP   r6, DOWN
          BRNE  move_left 		  
          CALL  add_y                ; verify move
          CALL  update_obj             ; draw object
          BRN   reset_ps2_register

move_left:
          CMP   r6, LEFT
          BRNE  move_right 		  
          CALL  sub_x                ; verify move
          CALL  update_obj             ; draw object
          BRN   reset_ps2_register

move_right:
          CMP   r6, RIGHT
          BRNE  key_up_check		  		  
          CALL  add_x                ; verify move
          CALL  update_obj             ; draw object
          BRN   reset_ps2_register

    
key_up_check:  
          CMP   r6,KEY_UP            ; look for key-up code 
		 
          BRNE  reset_ps2_register   ; branch if not found

set_skip_flag:
          ADD   r15, 0x01            ; indicate key-up found


reset_ps2_register:                  ; reset PS2 register 
          MOV    r6, 0x01
          OUT    r6, PS2_CONTROL_ID 
          MOV    r6, 0x00
          OUT    r6, PS2_CONTROL_ID
		  RETIE
;-------------------------------------------------------------------

;---------------------------------------------------------------------
; interrupt vector 
;---------------------------------------------------------------------
.CSEG
.ORG 0x3FF
           BRN   ISR
;---------------------------------------------------------------------