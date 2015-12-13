;*******************************************************************************
; configuring interrupt vectors
;*******************************************************************************
    #define offset 8000h

    ORG 0h + offset
    LJMP MAIN
	
	ORG 03h + offset
    LJMP ENTER_N ; INT0
	
    ORG 0Bh + offset
    LJMP ON_TIMER0 ; TR0
	
    ORG 013h + offset
    LJMP KEY_READ_AND_DISPLAY ; INT1


    ORG 01Bh + offset
    LJMP ON_TIMER1 ; TR1

    ;ORG 0100h + offset
;*******************************************************************************
; include section
;*******************************************************************************
    $INCLUDE (equ.a51)
    $INCLUDE (display.a51)
    $INCLUDE (arifmetic.a51)
    $INCLUDE (keyboard.a51)
    $INCLUDE (signal.a51)

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
MAIN:
    LCALL   MAIN_INIT

    MOV     CurN,        #0h
    MOV     CurNPos,     #0h
    MOV     IsStarted,   #0h
    MOV     TMP_N_2,     #2h


    LCALL   DISPLAY_ENTER
    LCALL   TEST_SUM
    LCALL   CLEAR_ARRAY

    SETB     EA ;enable interrupts
	MOV		 SP,50h
	LJMP    $
;*******************************************************************************


;*******************************************************************************
; Helper function
;*******************************************************************************


;-------------------------------------------------------------------------------
; Main initialization
;-------------------------------------------------------------------------------
MAIN_INIT:
    MOV     IE,       #00001111b  ;enable ET1 and ET0 and EX0 and EX1
    MOV     TCON,     #00000101b ; front 10 IT1 IT0
    MOV     TMOD,     #00010001b ; enable  T1 and T0 16bit timer
	MOV 	P4,		  #11110000b


    LCALL   INIT_TIMER0
    LCALL   INIT_TIMER1
    LCALL   KEY_BOARD_INIT
    RET

;-------------------------------------------------------------------------------
; Prepareing test sum
;-------------------------------------------------------------------------------
TEST_SUM:
    MOV     DPTR,   #ArrayN
    MOV     R1,     #MaxN

TEST_SUM_CYCLE_:
    MOV     A,      #0h
    MOVX    @DPTR,  A
    INC     DPTR
    DJNZ    R1,     TEST_SUM_CYCLE_

    ; Seting test case
    MOV     DurA,   #10d
    MOV     CurTime,#0h
	MOV		LocTime,#0h
    MOV     CurN,   #0h
	MOV		State, #1h
    RET

;-------------------------------------------------------------------------------
; Prepareing test sum
;-------------------------------------------------------------------------------
CLEAR_ARRAY:
    MOV     DPTR,   #ArrayN
    MOV     R1,     #MaxN

CLEAR_ARRAY_CYCLE_:
    MOV     A,      #0h
    MOVX    @DPTR,  A
    INC     DPTR
    DJNZ    R1,     CLEAR_ARRAY_CYCLE_

    RET

;-------------------------------------------------------------------------------
; Init timer0
;-------------------------------------------------------------------------------

INIT_TIMER0:
    MOV     TL0, #018h ;initial value
    MOV     TH0, #0FCh ;initial value
    CLR     TF0
    RET

;-------------------------------------------------------------------------------
; Init timer0
;-------------------------------------------------------------------------------
INIT_TIMER1:
    MOV     TL1, #00h
    MOV     TH1, #06h
    CLR     TF1
    RET

;-------------------------------------------------------------------------------
; Starts timer0
;-------------------------------------------------------------------------------
TIMER0_START:
    LCALL   INIT_TIMER0
    CLR     TF0
    SETB    TR0
    RET


;-------------------------------------------------------------------------------
; Starts timer1
;-------------------------------------------------------------------------------
TIMER1_START:
    LCALL   INIT_TIMER1
    CLR     TF1
    MOV     Timer1L, #DispDelay
    SETB    TR1
    RET

;-------------------------------------------------------------------------------
; Displays welcome text
;-------------------------------------------------------------------------------
DISPLAY_ENTER:
    LCALL   DISPLAY_CLEAR
    MOV     R4, #042h                ;B
    LCALL   DISPLAY
    MOV     R4, #0B3h                ;в
    LCALL   DISPLAY
    MOV     R4, #065h                ;е
    LCALL   DISPLAY
    MOV     R4, #0E3h                ;д
    LCALL   DISPLAY
    MOV     R4, #0B8h                ;и
    LCALL   DISPLAY
    MOV     R4, #0BFh                ;т
    LCALL   DISPLAY
    MOV     R4, #065h                ;е
    LCALL   DISPLAY
    MOV     R4, #020h                ;
    LCALL   DISPLAY
    MOV     R4, #041h                ;A
    LCALL   DISPLAY
    SETB    EX1
    RET

;-------------------------------------------------------------------------------
; Displays accepting A text
;-------------------------------------------------------------------------------
DISPLAY_WORKING:
    LCALL     DISPLAY_CLEAR
    MOV     R4, #0A8h                 ;П
    LCALL     DISPLAY
    MOV     R4, #070h                 ;р
    LCALL     DISPLAY
    MOV     R4, #0B8h                 ;и
    LCALL     DISPLAY
    MOV     R4, #0BDh                 ;н
    LCALL     DISPLAY
    MOV     R4, #0C7h                 ;я
    LCALL     DISPLAY
    MOV     R4, #0BFh                 ;т
    LCALL     DISPLAY
    MOV     R4, #06Fh                 ;о
    LCALL     DISPLAY
    RET

;-------------------------------------------------------------------------------
; Displays accepting N text
;-------------------------------------------------------------------------------
DISPLAY_ACCEPT_N:
    LCALL     DISPLAY_CLEAR
    MOV     R4, #0A8h                 ;П
    LCALL     DISPLAY
    MOV     R4, #070h                 ;р
    LCALL     DISPLAY
    MOV     R4, #0B8h                 ;и
    LCALL     DISPLAY
    MOV     R4, #0BDh                 ;н
    LCALL     DISPLAY
    MOV     R4, #0C7h                 ;я
    LCALL     DISPLAY
    MOV     R4, #0BFh                 ;т
    LCALL     DISPLAY
    MOV     R4, #06Fh                 ;о
    LCALL     DISPLAY
    MOV     R4, #020h                 ;
    LCALL     DISPLAY
    MOV     R4, #04Eh                 ;N
    LCALL     DISPLAY
    MOV     A, CurN
    ADD     A, #30h
	CJNE	A, #3Ah, DSN1
	LJMP	PLUS7
	DSN1:
	CJNE	A, #3Bh, DSN2
	LJMP	PLUS7
	DSN2:
	CJNE	A, #3Ch, DSN3
	LJMP	PLUS7
	DSN3:
	CJNE	A, #3Dh, DSN4
	LJMP	PLUS7
	DSN4:
	CJNE	A, #3Eh, DSN5
	LJMP	PLUS7
	DSN5:
	CJNE	A, #3Fh, DSN6
	LJMP	PLUS7
	PLUS7:
	ADD		A,#7h
	DSN6:
    MOV     R4, A
    LCALL      DISPLAY2
    RET

;-------------------------------------------------------------------------------
; Accepts A
;-------------------------------------------------------------------------------
ACCEPT_A:
    ;CLR     EX1 ;disbale INT1
    CLR     EX0 ;disable INT0
    LCALL   TIMER0_STOP
    
    
    LCALL   DISPLAY_WORKING
    LCALL   TIMER1_START
    LCALL   CLEAR_ARRAY
	MOV		A,TmpDurA
	SUBB	A,#30h
	
	MOV		DurA, A
    RET

;-------------------------------------------------------------------------------
; Stops timer1
;-------------------------------------------------------------------------------
TIMER1_STOP:
    CLR     TR1
    MOV     Timer1L, #DispDelay
    RET
    
;-------------------------------------------------------------------------------
; Stops timer0
;-------------------------------------------------------------------------------
TIMER0_STOP:
    CLR     TR0
    CLR     Result
    RET


;*******************************************************************************
; Enters N (INT0 handler)
;*******************************************************************************
ENTER_N:
    ;CLR     EX1
    MOV     A, P4;
    ANL     A, #030h

    MOV		R7, TMP_N_2
	ENTER_N2:
	CJNE	R7, #2h, ENTER_N1;
	LJMP	MEMO_N_;
	ENTER_N1:
    LJMP    MEMO_N_2_

MEMO_N_:
    DEC		TMP_N_2
	CLR		C
    RR      A
    RR      A
    RR      A
    RR      A
    MOV     TMP_N, A
    LJMP 	ENTER_EX

MEMO_N_2_:
	CLR		C
    RR      A
    RR      A
    ADD     A, TMP_N
    MOV     TMP_N_2, #2h


ENTER_N_:
    MOV     CurN, A
    LCALL   DISPLAY_ACCEPT_N
    LCALL   TIMER1_START
    MOV     DPTR, #ArrayN

    MOV     A, CurNPos
    MOV     R1, A
    JZ      ENTER_NEXT_

ENTER_PTR_SET_:

    INC     DPTR
    DJNZ    R1, ENTER_PTR_SET_

ENTER_NEXT_:

    MOV     A, CurN
    MOVX    @DPTR, A
    MOV     A, CurNPos
    INC     A
    CJNE    A, #MaxN, ENTER_END_
    MOV     A, #0h

ENTER_END_:

    MOV     CurNPos, A
    ;SETB    EX1
	
	ENTER_EX:	
    RETI


;*******************************************************************************
; On timer1 handler
; Generate 1 second delay
;*******************************************************************************
ON_TIMER1:
    LCALL   INIT_TIMER1
    DJNZ    Timer1L, TIMER1_EXIT_

    
    LCALL   TIMER1_STOP
    LCALL   DISPLAY_ENTER
    SETB    EX0 ; enable INT0
    SETB    EX1 ; enable INT1

    LCALL   TIMER0_START
    LJMP    TIMER1_EXIT_

TIMER1_EXIT_:
    RETI
;*******************************************************************************


END
