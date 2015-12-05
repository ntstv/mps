;*******************************************************************************
; configuring interrupt vectors
;*******************************************************************************
    #define offset 8000h

    ORG 0h + offset
    LJMP MAIN

    ORG 03h + offset
    LJMP ENTER_N              ; INT0

    ORG 0Bh + offset
    LJMP ON_TIMER0 ; TR0

    ORG 013h + offset
    LJMP KEY_READ_AND_DISPLAY ; INT1

    ORG 01Bh + offset
    LJMP ON_TIMER1 ; TR1

    ORG 030h + offset
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
MAIN_INIT:
    CLR     TF0
    CLR     TR0
    CLR     TR1
    MOV     IE,       #00001111b  ;enable ET1 and ET0 and EX0 and EX1
    MOV     TCON,     #00000101b ; front 10 IT1 IT0
    MOV     TMOD,     #00010001b ; enable  T1 and T0 16bit timer


    MOV     TL0,     #018h ;initial value
    MOV     TH0,     #0FCh ;initial value

    MOV        TL1,     #00h
    MOV        TH1,     #06h



    MOV     CurN,         #0h
    MOV     CurNPos,     #0h
    MOV        IsStarted,     #0h
    MOV     TMP_N_2,     #2h


    LCALL    KEY_BOARD_INIT
    LCALL     DISPLAY_ENTER
    SETB      EX1
;-------------------------------------------------------------------------------
; Prepareing test sum
;-------------------------------------------------------------------------------
    MOV        DPTR,     #ArrayN
    MOV        R1,     #MaxN

MAIN1_:

    MOV     A, #0Fh
    MOVX     @DPTR, A
    INC     DPTR
    DJNZ     R1, MAIN1_

    ; Seting test case
    MOV        DurA,         #9d
    MOV     CurTime,     #0d
    MOV     CurN,         #15d
;-------------------------------------------------------------------------------

    SETB     EA ;enable interrupts
    LJMP     $ ; Infinite loop
;*******************************************************************************


;*******************************************************************************
; Helper function
;*******************************************************************************


;-------------------------------------------------------------------------------
; Starts timer1
;-------------------------------------------------------------------------------
TIMER1_START:
    MOV        TL1,         #00h
    MOV     TH1,         #06h
    CLR        TF1
    MOV     Timer1L,     #020d
    SETB    TR1
    RET

;-------------------------------------------------------------------------------
; Displays welcome text
;-------------------------------------------------------------------------------
DISPLAY_ENTER:
    LCALL     DISPLAY_CLEAR
    MOV     R4, #042h                 ;B
    LCALL     DISPLAY
    MOV     R4, #0B3h                ;в
    LCALL     DISPLAY
    MOV     R4, #065h                ;е
    LCALL     DISPLAY
    MOV     R4, #0E3h                ;д
    LCALL    DISPLAY
    MOV     R4, #0B8h                 ;и
    LCALL     DISPLAY
    MOV     R4, #0BFh                 ;т
    LCALL     DISPLAY
    MOV     R4, #065h                 ;е
    LCALL     DISPLAY
    MOV        R4, #020h                ;
    LCALL     DISPLAY
    MOV        R4, #041h                ;A
    LCALL    DISPLAY
    SETB     EX1
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
DISPLAY_PR:
    LCALL     DISPLAY_CLEAR
    MOV     R4, #0A8h                 ;П
    LCALL     DISPLAY
    MOV     R4, #070h                 ;р
    LCALL     DISPLAY
    RET

;-------------------------------------------------------------------------------
; Accepts A
;-------------------------------------------------------------------------------
ACCEPT_A:
    LCALL   DISPLAY2
    CLR     EX1 ;disbale INT1
    CLR     EX0 ;disable INT0
    CLR     TR0 ;disable TR0
    CLR        TR1

    LCALL   DISPLAY_WORKING
    LCALL    TIMER1_START
    MOV     A, TmpDurA
    MOV     DurA, A
    CLR        Result
    RET


;*******************************************************************************
; Enters N (INT0 handler)
;*******************************************************************************
ENTER_N:
    LCALL    DISPLAY_PR
    MOV     A, P4;
    ANL     A, #030h

    DJNZ     TMP_N_2, MEMO_N_
    LJMP    ENTER_N_

MEMO_N_:
    MOV     R7, TMP_N_2
    CJNE    R7, #1h, MEMO_N_2_
    RR        A
    RR        A
    RR        A
    RR        A
    MOV        TMP_N, A
    RETI

MEMO_N_2_:
    RR        A
    RR        A
    ADD        A, TMP_N
    MOV        TMP_N_2, #2h


ENTER_N_:
    MOV     CurN, A
    MOV     DPTR, #ArrayN

    MOV     A, CurNPos
    MOV     R1, A
    JZ         ENTER_NEXT_

ENTER_PTR_SET_:

    INC     DPTR
    DJNZ     R1,  ENTER_PTR_SET_

ENTER_NEXT_:

    MOV     A, CurN
    MOVX     @DPTR, A
    MOV     A, CurNPos
    INC     A
    CJNE     A, #MaxN, ENTER_END_
    MOV     A, #0h

ENTER_END_:

    MOV     CurNPos, A
    RETI


;*******************************************************************************
; On timer1 handler
; Generate 1 second delay
;*******************************************************************************
ON_TIMER1:
    MOV          TL1, #00h
    MOV       TH1, #06h
    CLR        TF1
    DJNZ    Timer1L, TIMER1_EXIT


    CLR        TR1
    MOV     TL0, #018h ;initial value
    MOV     TH0, #0FCh ;initial value
    CLR       TF0
    LCALL    DISPLAY_ENTER
    SETB      EX0 ; enable INT0
    SETB      EX1 ; enable INT1
    SETB    TR0 ; enable on_timer
    LJMP    TIMER1_EXIT

TIMER1_EXIT:
    RETI
;*******************************************************************************


END
