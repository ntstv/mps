ORG 0h
LJMP main

ORG 03h
LJMP enterN

ORG 0Bh
LJMP payload ; timer interrup handler


ORG 30h
	
CurTime EQU 030h
State EQU 031h
DurA EQU 032h
CurN EQU 033h
LocTime EQU 035h
DurB EQU 036h
DurCHigh EQU 037h
DurCLow EQU 038h
P4 EQU 0C0h
Tmp EQU 020h
;DurD EQU #50d
	
;ArrayN EQU #1000d
;MaxN EQU #100d

CurNPos EQU 039h

main:
CLR TF0
CLR TR0
MOV IE,#03h  ;enable TF0 and IT0 interrupt only
MOV TMOD,#01h ; enable T0 16bit timer
MOV TL0,#018h ;initial value
MOV TH0,#0FCh ;initial value

MOV CurN,#0h
MOV CurNPos,#0h


; Prepareing test sum
MOV DPTR,#1000d
MOV R1,#100d;
_main1:
MOV A, #0Fh
MOVX @DPTR,A
INC DPTR
DJNZ R1,_main1

; Seting test case
MOV DurA,#9d
MOV CurTime,#0d
MOV CurN,#15d


SETB TR0 ;enable timer0
SETB EA ;enable interrupts

; Infinite loop
LJMP $
	
	
enterN:
MOV A,P4;
ANL A,#0Fh
MOV CurN,A
MOV DPTR,#1000d

MOV A,CurNPos
MOV R1,A
JZ _enter_next
_enter_ptr_set:
INC DPTR
DJNZ R1, _enter_ptr_set
_enter_next:
MOV A,CurN
MOVX @DPTR,A
MOV A,CurNPos
INC A
CJNE A,#100d,_enter_end
MOV A,#0h
_enter_end:
MOV CurNPos,A
RETI	


;=======================================
payload:

MOV A,CurTime
JNZ _timer_non_start
MOV CurTime,#0h
MOV State,#1h
MOV DurB,#0Fh

_timer_non_start:

_timer_state_1:
MOV R4,LocTime
MOV R7,State
MOV A,R4
CJNE A,DurA,_timer_state_2
CJNE R7,#0d,_timer_state_2
MOV State,#2h
MOV LocTime,#0h
MOV DurB,CurN
LJMP _timer_res

_timer_state_2:
MOV R4,LocTime
MOV R7,State
MOV A,R4
CJNE A,DurB,_timer_state_3
CJNE R7,#1d,_timer_state_3
MOV State,#4h
MOV LocTime,#0h
;calculating average
MOV R1,#0h
MOV R2,#100d
CALL sum_n
MOV A,R3
MOV R1,A
MOV A,R4
MOV R2,A
MOV R3,#100d
CALL division
MOV DurCHigh,R4
MOV DurCLow,R5
LJMP _timer_res

_timer_state_3:
MOV R4,LocTime
MOV R7,State
MOV A,R4
CJNE A,DurCLow,_timer_res
CJNE R7,#3h,_timer_res
MOV State,#8h
MOV LocTime,#0h
LJMP _timer_res

_timer_res:
MOV A,State
ANL A,#2d
MOV Tmp,A
JB Tmp.1, _timer_res_1

MOV A,State
ANL A,#8d
MOV Tmp,A
JB Tmp.4, _timer_res_1

MOV A,State
ANL A,#2d
JB Tmp.2, _timer_res_0

MOV A,State
ANL A,#1d
MOV Tmp,A
JNB Tmp.1, _timer_res_0

_timer_res_0:
CLR P4.0
LJMP _timer_inc

_timer_res_1:
SETB P4.0
LJMP _timer_inc

_timer_inc:
MOV A,CurTime
CJNE A,#50d,_timer_clear
INC CurTime
INC LocTime
LJMP _timer_exit

_timer_clear:
MOV CurTime,#0d
MOV LocTime,#0d
CLR P4.0

_timer_exit:
MOV TL0,#018h ;initial value
MOV TH0,#0FCh ;initial value
CLR TF0
RETI




;===============================
sum_n:
; R1 offset
; R2 length
; R3 sumH
; R4 sumL

MOV R3,#0h
MOV R4,#0h
MOV R5,#0h
MOV DPTR,#1000d


;setting offset
MOV A,R1
JZ _sum_next
_sum_ptr_set:
INC DPTR
DJNZ R1, _sum_ptr_set
_sum_next:


_sum_n_loop:
MOVX A,@DPTR
ADDC A,R4
MOV R4,A
JNC _sum_n_1
INC R3
CLR C

_sum_n_1:
INC R5

INC DPTR
DJNZ R2,_sum_n_loop

RET
;===================================
division:
; R1 dividentH
; R2 dividentL
; R3 divider
; R4 quotientH
; R5 quotientL
; R6 == 8d

MOV R4,#0h
MOV R5,#0h
MOV R6,#09h


_div_cycle:

MOV A,R1
SUBB A,R3
CPL C; C = ^C
CLR PSW.6 ;HACK
MOV PSW.7,C

JNC _d2
MOV R1,A

_d2:
MOV A,R5
RLC A
MOV R5,A
MOV A,R4
RLC A
MOV R4,A

CLR C
MOV A,R2
RLC A
MOV R2,A
MOV A,R1
RLC A
MOV R1,A

DJNZ R6,_div_cycle
RET
;===========================

END
