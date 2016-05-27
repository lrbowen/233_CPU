;---------------------------------------------------------------------
;- This program is the famous etch-a-sketch program. The idea 
;- originated from Bridget Benson. This is an official working 
;- program. The main purpose of this program is to demonstrate how 
;- a line can be formed under control of the keyboard, much like
;- the "etch-a-sketch" toys from days gone by. 
;- 
;- This programs does the following: 
;-   1) draws the background color on the display
;-   2) draws a dot in the middle of display
;-   3) allows movement of the dot using a PS/2 keyboard. 
;-   3) does not allow the object to move off the screen. 
;-   4) does not continually redraw the screen; it only redraws the
;-        parts where a new dot is added based on key presses.  
;- 
;- This program uses keys 'w', 'a', 's', & 'd' to move the associated 
;- object up, left, down, and right, respectively. 

;- This program also allows the user to use the switches on the 
;- development board to interactively change the background color
;- on the etch-a-sketch background. There are eight switches which 
;- correspond nicely to the 256 color possibilities on the monitor. 
;- Additionally, when a background color is changed, the dot color
;- is assigned to be the complement of the new background color in 
;- a lame attempt to keep the dot always as visible as possible. 
;-
;- This code is based on the original draw_dot program, which was 
;- written by bryan mealy based on modified code from Bridget Benson. 
;- This code draws heavily upon the modifications made to the 
;- PS/2 driver made by Alfredo Medina and Gabriel Ordonez. 
;- 
;- date: 11-21-2013
;---------------------------------------------------------------------

;------------------------------------------------------------
; Various key parameter constants
;------------------------------------------------------------ 
.EQU Low_C	  = 0x1C     ; 'a'
.EQU Low_D    = 0x1B     ; 's'
.EQU Low_E    = 0x23     ; 'd'
.EQU Mid_F	  = 0x2B     ; 'f'
.EQU Mid_G    = 0x34     ; 'g'
.EQU Mid_A    = 0x33     ; 'h'
.EQU Mid_B	  = 0x3B     ; 'j'
.EQU Mid_C    = 0x42     ; 'k'
.EQU Mid_D    = 0x4B     ; 'l'
.EQU Mid_E    = 0x4C     ; ';'

.EQU Low_C_S  = 0x1D     ; 'w'
.EQU Low_D_S  = 0x24     ; 'e'

.EQU F_Sharp  = 0x2C     ; 't'
.EQU G_Sharp  = 0x35     ; 'y'
.EQU A_Sharp  = 0x3C     ; 'u'

.EQU High_C_S  = 0x44     ; 'o'
.EQU High_D_S  = 0x4D     ; 'p'
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen parameter constants for 40x30 screen
;------------------------------------------------------------
.EQU LO_X    = 0x00
.EQU HI_X    = 0x27
.EQU LO_Y    = 0x00
.EQU HI_Y    = 0x1D
;------------------------------------------------------------

;------------------------------------------------------------
; Various screen I/O constants
;------------------------------------------------------------
.EQU LEDS                = 0x40     ; LED array
.EQU SSEG                = 0x81     ; 7-segment decoder 
.EQU SWITCHES            = 0x20     ; switches 

.EQU PS2_CONTROL         = 0x46     ; ps2 control register 
.EQU PS2_KEY_CODE        = 0x44     ; ps2 data register
.EQU PS2_STATUS          = 0x45     ; ps2 status register

.EQU VGA_HADD            = 0x90     ; high address register
.EQU VGA_LADD            = 0x91     ; low address register
.EQU VGA_COLOR           = 0x92     ; color value register
;------------------------------------------------------------

;------------------------------------------------------------------
; Various drawing constants
;------------------------------------------------------------------
.EQU BG_COLOR     = 0x29            ; Background:  red
.EQU RED          = 0xE0            ; color data: red
.EQU BLUE         = 0x03            ; color data: blue 
.EQU GREEN        = 0x1C            ; color data: green
.EQU WHITE		  = 0xFF
.EQU BLACK		  = 0x00
.EQU L_Grey       = 0x92
.EQU D_Grey       = 0xDB
.EQU Pink         = 0xF2
;------------------------------------------------------------------

;------------------------------------------------------------------
; Various Constant Definitions
;------------------------------------------------------------------
.EQU KEY_UP     = 0xF0        ; key release data
.EQU int_flag   = 0x01        ; interrupt hello from keyboard
;------------------------------------------------------------------

;------------------------------------------------------------------
;- Register Usage Key
;------------------------------------------------------------------
;- r2 --- holds keyboard input
;- r3 --- holds temp value for black keys
;- r4 --- holds temp value for white note, x start
;- r5 --- holds temp value for white note, x end
;- r6 --- holds drawing color
;- r7 --- main Y location value
;- r8 --- main X location value
;- r9 --- used for something?
;- r10 --- holds temp value for white note, y end
;- r11 --- hold temp value for ivory
;- r15 -- for interrupt flag 
;- r21 -- saves current switch settings
;------------------------------------------------------------------

;------------------------------------------------------------------
.CSEG
.ORG 0x20
;------------------------------------------------------------------

;------------------------------------------------------------------
; Foreground Task
;------------------------------------------------------------------
init:

         MOV    r15,0x00         ;- clear interrupt flag register

         MOV    r6, BG_COLOR     ;- Dark Grey Background
         CALL   draw_background  ;- draw using default color
		
		 CALL   draw_b_notes_in
		 CALL   draw_piano
		 CALL	Q_P_Rat

         IN     r20,SWITCHES     ;- store current switch settings	
		 
         SEI                     ;- allow interrupts 


main:  
         BRN    main             ;- dumb poll waiting for interrupts
;--------------------------------------------------------------------
   
 
;--------------------------------------------------------------------
;-  Subroutine: draw_horizontal_line
;-
;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
;-
;-  Parameters:
;-   r8  = starting x-coordinate
;-   r7  = y-coordinate
;-   r9  = ending x-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r8,r9
;--------------------------------------------------------------------
draw_horizontal_line:
        ADD    r9,0x01          ; go from r8 to r9 inclusive

draw_horiz1:
        CALL   draw_dot         ; draw tile
        ADD    r8,0x01          ; increment column (X) count
        CMP    r8,r9            ; see if there are more columns
        BRNE   draw_horiz1      ; branch if more columns
        RET
;--------------------------------------------------------------------


;---------------------------------------------------------------------
;-  Subroutine: draw_vertical_line
;-
;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
;-
;-  Parameters:
;-   r8  = x-coordinate
;-   r7  = starting y-coordinate
;-   r9  = ending y-coordinate
;-   r6  = color used for line
;- 
;- Tweaked registers: r7,r9
;--------------------------------------------------------------------
draw_vertical_line:
         ADD    r9,0x01         ; go from r7 to r9 inclusive

draw_vert1:          
         CALL   draw_dot        ; draw tile
         ADD    r7,0x01         ; increment row (y) count
         CMP    r7,r9           ; see if there are more rows
         BRNE   draw_vert1      ; branch if more rows
         RET
;--------------------------------------------------------------------

;---------------------------------------------------------------------
;-  Subroutine: draw_background
;-
;-  Fills the 30x40 grid with one color using successive calls to 
;-  draw_horizontal_line subroutine. 
;- 
;-  Tweaked registers: r13,r7,r8,r9
;----------------------------------------------------------------------
draw_background: 
         PUSH  r7                       ; save registers
         PUSH  r8
;        MOV   r6,BG_COLOR              ; use default color
         MOV   r13,0x00                 ; r13 keeps track of rows
start:   MOV   r7,r13                   ; load current row count 
         MOV   r8,0x00                  ; restart x coordinates
         MOV   r9,0x27 
 
         CALL  draw_horizontal_line     ; draw a complete line
         ADD   r13,0x01                 ; increment row count
         CMP   r13,0x1E                 ; see if more rows to draw
         BRNE  start                    ; branch to draw more rows
         POP   r8                       ; restore registers
         POP   r7
         RET
;---------------------------------------------------------------------
    
;---------------------------------------------------------------------
;- Subrountine: draw_dot
;- 
;- This subroutine draws a dot on the display the given coordinates: 
;- 
;- (X,Y) = (r8,r7)  with a color stored in r6  
;- 
;- Tweaked registers: 
;---------------------------------------------------------------------
draw_dot: 


           OUT   r8,VGA_LADD   ; write bot 8 address bits to register
           OUT   r7,VGA_HADD   ; write top 3 address bits to register
           OUT   r6,VGA_COLOR  ; write data to frame buffer
           RET

; --------------------------------------------------------------------
 
;---------------------------------------------------------------------
;- Subrountine: Draw Letter A
;- 
;- Call to draw the letter A
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_A:
		MOV 	r8, 0x15
		MOV 	r9, 0x19
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x19
		MOV 	r7, 0x07
		CALL  	draw_horizontal_line
		MOV 	r7, 0x03
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line
		MOV 	r7, 0x03
		MOV 	r9, 0x0B
		MOV		r8, 0x1A
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter B
;- 
;- Call to draw the letter B
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_B:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x06
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x0B
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line
		MOV 	r7, 0x03
		MOV 	r9, 0x05
		MOV		r8, 0x1B
		CALL  	draw_vertical_line
		MOV 	r7, 0x07
		MOV 	r9, 0x0A
		MOV		r8, 0x1B
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter C
;- 
;- Call to draw the letter C
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_C:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x0B
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter D
;- 
;- Call to draw the letter D
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_D:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x0B
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line
		MOV 	r7, 0x03
		MOV 	r9, 0x0A
		MOV		r8, 0x1B
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter E
;- 
;- Call to draw the letter E
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_E:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x06
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x0B
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter F
;- 
;- Call to draw the letter F
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_F:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x06
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line

		RET

;---------------------------------------------------------------------
;- Subrountine: Draw Letter G
;- 
;- Call to draw the letter G
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_G:
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x02
		CALL  	draw_horizontal_line
		MOV 	r8, 0x17
		MOV 	r9, 0x1A
		MOV 	r7, 0x06
		CALL  	draw_horizontal_line
		MOV 	r8, 0x15
		MOV 	r9, 0x1A
		MOV 	r7, 0x0B
		CALL  	draw_horizontal_line
		MOV 	r7, 0x02
		MOV 	r9, 0x0B
		MOV		r8, 0x14
		CALL  	draw_vertical_line
		MOV 	r7, 0x07
		MOV 	r9, 0x0A
		MOV		r8, 0x1B
		CALL  	draw_vertical_line

		RET
;---------------------------------------------------------------------
;- Subrountine: Draw Letter #
;- 
;- Call to draw the letter #
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Draw_S:
		MOV 	r8, 0x1D
		MOV 	r9, 0x24
		MOV 	r7, 0x05
		CALL  	draw_horizontal_line
		MOV 	r8, 0x1D
		MOV 	r9, 0x24
		MOV 	r7, 0x08
		CALL  	draw_horizontal_line
		MOV 	r7, 0x03
		MOV 	r9, 0x0A
		MOV		r8, 0x1F
		CALL  	draw_vertical_line
		MOV 	r7, 0x03
		MOV 	r9, 0x0A
		MOV		r8, 0x22
		CALL  	draw_vertical_line


		RET
;---------------------------------------------------------------------
;- Subrountine: Draw Quiet_Rat
;- 
;- Call to the not playing piano rat
;
;- Tweaked registers: 
;---------------------------------------------------------------------

Q_P_Rat:
		MOV			r6, WHITE

		MOV			r8, 0x03
		MOV			r9, 0x09
		MOV			r7, 0x09
		CALL  		draw_horizontal_line
		MOV			r8, 0x03
		MOV			r9, 0x0A
		MOV			r7, 0x08
		CALL  		draw_horizontal_line
		MOV			r8, 0x08
		MOV			r7, 0x07
		CALL		draw_dot
		MOV			r7, 0x0A
		CALL		draw_dot
		MOV			r8, 0x03
		CALL		draw_dot 			;End Piano

		MOV			r6, L_Grey			;eye and nose skipped
		MOV			r7, 0x01
		MOV			r9, 0x0A
		MOV			r8, 0x0D
		CALL  		draw_vertical_line
		MOV			r8, 0x0E
		MOV			r7, 0x01
		CALL		draw_dot
		MOV			r7, 0x02
		CALL		draw_dot
		MOV			r7, 0x03
		CALL		draw_dot
		MOV			r8, 0x0F
		CALL		draw_dot
		MOV			r7, 0x02
		CALL		draw_dot
		MOV			r8, 0x0A  		;start arm
		MOV			r7, 0x06
		CALL		draw_dot
		MOV			r8, 0x0B
		CALL		draw_dot
		MOV			r8, 0x0C
		CALL		draw_dot		; End arm
		MOV			r7, 0x08
		CALL		draw_dot
		MOV			r7, 0x09
		CALL		draw_dot
		MOV			r8, 0x0B
		CALL		draw_dot
		MOV			r7, 0x0A
		CALL		draw_dot
		MOV			r7, 0x04
		MOV			r8, 0x0C
		CALL		draw_dot

		MOV			r6, BLUE		; eye
		MOV			r7, 0x03
		CALL		draw_dot

		MOV			r6, Pink		; nose
		MOV			r7, 0x04
		MOV			r8, 0x0B
		CALL		draw_dot

		MOV			r7, 0x09
		MOV			r8, 0x0E
		CALL		draw_dot
		MOV			r8, 0x0F
		CALL		draw_dot
		MOV			r7, 0x0A
		CALL		draw_dot
		MOV			r8, 0x10
		CALL		draw_dot

		RET


;---------------------------------------------------------------------
;- Subrountine: Move Arm
;- 
;- Call to move the rat arm
;
;- Tweaked registers: 
;---------------------------------------------------------------------
arm_move:
		MOV			r6, BG_COLOR
		MOV			r8, 0x0A  		;start arm
		MOV			r7, 0x06
		CALL		draw_dot
		MOV			r8, 0x0B
		CALL		draw_dot
		MOV			r8, 0x0C
		CALL		draw_dot		; End arm
		MOV		    r6, L_Grey
	    MOV			r8, 0x0A  		;start arm
		MOV			r7, 0x07
		CALL		draw_dot
		MOV			r8, 0x0B
		CALL		draw_dot
		MOV			r8, 0x0C
		CALL		draw_dot		; End arm

		RET
;---------------------------------------------------------------------
;- Subrountine: Draw_Back_Notes
;- 
;- Call to draw the white notes in the background
;
;- Tweaked registers: r4,r5
;---------------------------------------------------------------------

draw_b_notes_in:
		MOV			r6, WHITE

draw_b_notes:
		MOV			r4, 0x01
		MOV			r5, 0x03
		MOV			r10,0x1B
		CALL		draw_note

		MOV			r4, 0x01
		MOV			r5, 0x03
		MOV			r10, 0x16
		CALL		draw_note

		MOV			r4, 0x05
		MOV			r5, 0x07
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x0A
		MOV			r5, 0x0C
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x0F
		MOV			r5, 0x11
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x14
		MOV			r5, 0x16
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x19
		MOV			r5, 0x1B
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x1E
		MOV			r5, 0x20
		MOV			r10,0x12
		CALL		draw_note

		MOV			r4, 0x24
		MOV			r5, 0x26
		MOV			r10,0x16
		CALL		draw_note

		MOV			r4, 0x24
		MOV			r5, 0x26
		MOV			r10,0x1B
		CALL		draw_note


		MOV			r7, 0x0F
		MOV			r8, 0x07
		MOV			r9,	0x0C
		CALL  		draw_horizontal_line

		MOV			r7, 0x0F
		MOV			r8, 0x11
		MOV			r9,	0x16
		CALL  		draw_horizontal_line

		MOV			r7, 0x0F
		MOV			r8, 0x1B
		MOV			r9,	0x20
		CALL  		draw_horizontal_line

		RET
		
;---------------------------------------------------------------------
;- Subrountine: Draw_Note
;- 
;- Call to draw the white note itself 
;
;- Tweaked registers: 
;---------------------------------------------------------------------
draw_note: 


draw_note_1:
		MOV   		r7,r10             	     ; load y-value 
        MOV   		r8,r4                    ; restart x coordinates
        MOV   		r9,r5 					 ; r4 is start of x, r5 is end
 
        CALL  		draw_horizontal_line     ; draw a complete line
		SUB			r7, 0x01
		MOV   		r8,r4                    ; restart x coordinates
        MOV   		r9,r5 					 ; r4 is start of x, r5 is end
		CALL  		draw_horizontal_line
	    
		SUB			r10, 0x02
		MOV			r8, r5
		MOV			r7, r10
		CALL		draw_dot
		SUB			r7, 0x01
		CALL		draw_dot
		
		RET


;---------------------------------------------------------------------
;- Subrountine: Draw_White_Key
;- 
;- Call to draw the Black Keyboard Keys 
;
;- Tweaked registers: r11, start of x range for ivory
;---------------------------------------------------------------------

Draw_Grey_Key:
		MOV			r6, L_GREY
		BRN			Draw_Ivory

Draw_White_Key:
		MOV			r6, White
		BRN			Draw_Ivory

Draw_Ivory:	
		MOV   		r7,0x15             	 ; start y 
        MOV   		r8,r11                   ; set x coord
        MOV   		r9,0x1C					 ; set end of y				
		CALL		draw_vertical_line
		MOV   		r7,0x15   
		ADD			r8, 0x01
		MOV   		r9,0x1C
		CALL		draw_vertical_line
		MOV   		r7,0x15
		ADD			r8, 0x01
		MOV   		r9,0x1C
		CALL		draw_vertical_line   

		RET
;---------------------------------------------------------------------	
		

;---------------------------------------------------------------------
;- Subrountine: Draw_Black_Key
;- 
;- Call to draw the Black Keyboard Keys 
;
;- Tweaked registers: r3, black key range
;---------------------------------------------------------------------

Draw_Black_Key:
		MOV			r6, BLACK
Draw_Ebony:	
		
		MOV   		r7,0x15             	 ; load current col count 
        MOV   		r8,r3                  	 ; set x coord
        MOV   		r9,0x18					 ; set end of y				
		CALL		draw_vertical_line   
		ADD			r3, 0x01
		MOV   		r7,0x15             	 ; load current col count 
        MOV   		r8,r3                  	 ; set x coord
        MOV   		r9,0x18					 ; set end of y				
		CALL		draw_vertical_line   

		RET
;---------------------------------------------------------------------
;- Subrountine: draw_piano
;- 
;- Call Once, draw the initial piano 
;- 
;-  
;- 
;- Tweaked registers: 
;---------------------------------------------------------------------

draw_piano:
White_Keys:
		MOV			r11, 0x05
		CALL		Draw_White_Key
		ADD			r11, 0x03
		CALL		Draw_Grey_Key
		ADD			r11, 0x03
		CALL		Draw_White_Key
		ADD			r11, 0x03
		CALL		Draw_Grey_Key
		ADD			r11, 0x03
		CALL		Draw_White_Key
		ADD			r11, 0x03
		CALL		Draw_Grey_Key
		ADD			r11, 0x03
		CALL		Draw_White_Key
		ADD			r11, 0x03
		CALL		Draw_Grey_Key
		ADD			r11, 0x03
		CALL		Draw_White_Key
		ADD			r11, 0x03
		CALL		Draw_Grey_Key
		
Black_Row:
		MOV   		r6, BLACK
		MOV			r7, 0x14
		MOV   		r8, 0x05                   
        MOV   		r9, 0x22
		CALL  		draw_horizontal_line
Black_Keys:
		MOV			r3, 0x07
		CALL		Draw_Black_Key
		MOV			r3, 0x0A
		CALL		Draw_Black_Key
		MOV			r3, 0x10
		CALL		Draw_Black_Key
		MOV			r3, 0x13
		CALL		Draw_Black_Key
		MOV			r3, 0x16
		CALL		Draw_Black_Key
		MOV			r3, 0x1C
		CALL		Draw_Black_Key
		MOV			r3, 0x1F
		CALL		Draw_Black_Key

		RET
;--------------------------------------------------------------
; Rat Piano Notes
;--------------------------------------------------------------
; Makes the notes for the Rat's Piano
;
; Tweaked Registers; 
;--------------------------------------------------------------

Rat_Note:
		  MOV	r10,0x06
		  MOV   r4, 0x01
		  MOV	r5, 0x03
		  CALL	draw_note
		  MOV	r10,0x05
		  MOV   r4, 0x06
		  MOV	r5, 0x08
		  CALL	draw_note
		  MOV   r8, 0x04
		  MOV   r7, 0x03
		  CALL  draw_dot
		  MOV   r8, 0x08
		  MOV   r7, 0x02
		  CALL  draw_dot
		  MOV	r10,0x10
		  MOV   r4, 0x01
		  MOV	r5, 0x03
		  CALL	draw_note
		  MOV   r8, 0x04
		  MOV   r7, 0x0D
		  CALL  draw_dot
		  MOV	r4, 0x24
		  MOV	r5, 0x26
		  MOV	r10,0x10
		  CALL	draw_note
		  MOV   r8, 0x27
		  MOV   r7, 0x0D
		  CALL  draw_dot		

		  RET	
;--------------------------------------------------------------
; Note Clear
;--------------------------------------------------------------
; Clears the note display
;
; Tweaked Registers; 
;--------------------------------------------------------------

Note_Clear:
		MOV	   r6, BG_COLOR
		MOV	   r3, 0x12
		MOV	   r4, 0x25
		MOV	   r5, 0x02
Note_Clear_1:
		MOV	   r8, r3
		MOV    r9, r4
        MOV	   r7, r5
		CALL   draw_horizontal_line
	    ADD	   r5, 0x01
		CMP    r5, 0x0C
		BRNE   Note_Clear_1
		RET

;--------------------------------------------------------------
; Interrup Service Routine - Handles Interrupts from keyboard
;--------------------------------------------------------------
; Sample ISR that looks for various key presses. When a useful
; key press is found, the program does something useful. The 
; code also handles the key-up code and subsequent re-sending
; of the associated scan-code. 
;
; Tweaked Registers; r2,r3,r15
;--------------------------------------------------------------
ISR:      CMP   r15, int_flag        ; check key-up flag 
          BRNE  continue
          MOV   r15, 0x00            ; clean key-up flag
          BRN   reset_ps2_register       

continue: IN    r2, PS2_KEY_CODE     ; get keycode data
          OUT	r2, SSEG
P_Low_C:
          CMP   r2, Low_C
          BRNE  P_Low_D		  
		  MOV	r11, 0x05
		  MOV	r6, 0xE0			 	; Red e0
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_C
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x07
		  CALL	Draw_Black_Key
		  CALL	arm_move
          
          BRN   reset_ps2_register

P_Low_D:
          CMP   r2, Low_D
		  BRNE  P_Low_E	
		  MOV	r11, 0x08
		  MOV	r6, 0xE2			 	; Pinkish ec
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_D
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x07
		  CALL	Draw_Black_Key
		  MOV	r3, 0x0A
		  CALL	Draw_Black_Key
		  CALL	arm_move
          
          BRN   reset_ps2_register

P_Low_E: 
		  CMP   r2, Low_E
		  BRNE  P_Mid_F	
		  MOV	r11, 0x0B
		  MOV	r6, 0xE3			 	; Magenta fc
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_E
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x0A
		  CALL	Draw_Black_Key
		  CALL	arm_move
          
          BRN   reset_ps2_register
P_Mid_F: 
		  CMP   r2, Mid_F
		  BRNE  P_Mid_G	
		  MOV	r11, 0x0E
		  MOV	r6, 0x83			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_F
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x10
		  CALL	Draw_Black_Key
		  CALL	arm_move
          
          BRN   reset_ps2_register

P_Mid_G: 
		  CMP   r2, Mid_G
		  BRNE  P_Mid_A	
		  MOV	r11, 0x11
		  MOV	r6, 0x43			 	
		  CALL  Rat_Note
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_G
		  MOV	r6, BLACK
		  MOV	r3, 0x10
		  CALL	Draw_Black_Key
		  MOV	r3, 0x13
		  CALL	Draw_Black_Key
		  CALL	arm_move
          
          BRN   reset_ps2_register

P_Mid_A: 
		  CMP   r2, Mid_A
		  BRNE  P_Mid_B				
		  MOV	r11, 0x14
		  MOV	r6, 0x2f			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_A
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x13
		  CALL	Draw_Black_Key
		  MOV	r3, 0x16
		  CALL	Draw_Black_Key
		  CALL	arm_move
          BRN   reset_ps2_register

P_Mid_B:
		  CMP   r2, Mid_B
		  BRNE  P_Mid_C
		  MOV	r11, 0x17
		  MOV	r6, 0x33			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_B
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x16
		  CALL	Draw_Black_Key
		  CALL	arm_move
		  BRN   reset_ps2_register

P_Mid_C:
		  CMP   r2, Mid_C
		  BRNE  P_Mid_D
		  MOV	r11, 0x1A
		  MOV	r6, 0x3e			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_C
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x1C
		  CALL	Draw_Black_Key
		  CALL	arm_move
		  BRN   reset_ps2_register

P_Mid_D:
		  CMP   r2, Mid_D
		  BRNE  P_Mid_E
		  MOV	r11, 0x1D
		  MOV	r6, 0x1d			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_D
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x1C
		  CALL	Draw_Black_Key
		  MOV	r3, 0x1F
		  CALL	Draw_Black_Key
		  CALL	arm_move
		  BRN   reset_ps2_register

P_Mid_E:
		  CMP   r2, Mid_E
		  BRNE  P_L_C_S
		  MOV	r11, 0x20
		  MOV	r6, 0x9C			 	
		  Call  draw_b_notes
		  Call	Draw_Ivory
		  CALL  Draw_E
		  CALL  Rat_Note
		  MOV	r6, BLACK
		  MOV	r3, 0x1F
		  CALL	Draw_Black_Key
		  CALL	arm_move
		  BRN   reset_ps2_register
P_L_C_S:
		  CMP   r2, Low_C_S
		  BRNE  P_L_D_S
		  MOV	r6, 0x9C			 	; Purple
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_C
		  CALL  Draw_S
		  MOV	r3, 0x07
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_L_D_S:
		  CMP   r2, Low_D_S
		  BRNE  P_F_Sharp
		  MOV	r6, 0x1d			 	; Indigo
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_D
		  CALL  Draw_S
		  MOV	r3, 0x0A
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_F_Sharp:
		  CMP   r2, F_Sharp
		  BRNE  P_G_Sharp
		  MOV	r6, 0x33			 	; Blue
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_F
		  CALL  Draw_S
		  MOV	r3, 0x10
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_G_Sharp:
		  CMP   r2, G_Sharp
		  BRNE  P_A_Sharp
		  MOV	r6, 0x1D			 	; Green
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_G
		  CALL  Draw_S
		  MOV	r3, 0x13
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_A_Sharp:
		  CMP   r2, A_Sharp
		  BRNE  P_H_C_S
		  MOV	r6, 0xF8			 	; Yellow
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_A
		  CALL  Draw_S
		  MOV	r3, 0x16
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_H_C_S:
		  CMP   r2, High_C_S
		  BRNE  P_H_D_S
		  MOV	r6, 0xf0			 	; Orange
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_C
		  CALL  Draw_S
		  MOV	r3, 0x1C
		  CALL	Draw_Ebony
		  CALL	arm_move
		  BRN   reset_ps2_register
P_H_D_S:
		  CMP   r2, High_D_S 
		  BRNE  key_up_check
		  MOV	r6, 0xE0			 	; Red
		  CALL  Rat_Note
		  Call  draw_b_notes
		  CALL  Draw_D
		  CALL  Draw_S
		  MOV	r3, 0x1F
		  CALL	Draw_Ebony
		  CALL	arm_move	
		  BRN   reset_ps2_register

;BRNE  key_up_check		 ; This goes on the last key as branch check    
key_up_check:  
          CMP   r2,KEY_UP            ; look for key-up code 
		  CALL	draw_b_notes_in
		  MOV	r6, L_Grey
		  MOV	r8, 0x0A  		;start arm
		  MOV	r7, 0x06
		  CALL	draw_dot
		  MOV	r8, 0x0B
		  CALL	draw_dot
		  MOV	r8, 0x0C
		  CALL  draw_dot		; End arm
		  MOV	r6, BG_COLOR
		  CALL  Rat_Note
		  MOV	r8, 0x0A  		;start arm
		  MOV	r7, 0x07
		  CALL	draw_dot
		  MOV	r8, 0x0B
		  CALL	draw_dot
		  MOV	r8, 0x0C
		  CALL	draw_dot		; End arm
		  CALL	Note_Clear
		  ;CALL  draw_piano

          BRNE  reset_ps2_register   ; branch if not found

set_skip_flag:
          ADD   r15, 0x01            ; indicate key-up found


reset_ps2_register:                  ; reset PS2 register 
          MOV    r3, 0x01
          OUT    r3, PS2_CONTROL 
          MOV    r3, 0x00
          OUT    r3, PS2_CONTROL
		  EXOR	r16, 0x20
		  OUT	r16, LEDS
		  
          RETIE
;-------------------------------------------------------------------

;---------------------------------------------------------------------
; interrupt vector 
;---------------------------------------------------------------------
.CSEG
.ORG 0x3FF
           BRN   ISR
;---------------------------------------------------------------------
