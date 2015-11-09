ORG 0h
AJMP main
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


main:
MOV DPTR,#1000d
MOV R1,#100d;
_main1:
MOV A, #0Fh
MOVX @DPTR,A
INC DPTR
DJNZ R1,_main1

;summing
;MOV R1,#0h
;MOV R2,#21d

;CALL sum_n


;; dividing
;MOV A,R3
;MOV R1,A
;MOV A,R4
;MOV R2,A
;MOV R3,#21d

;CALL division

;loop: JMP loop

;=======================================
MOV DurA,#9d
MOV CurTime,#0d
MOV CurN,#15d
;=======================================
timer_interrupt:
; each ms
;  current time I:0x30
;  STATE 0,1,3,7 (0,1) - HIGH, (3,7) - LOW I:0x31
;  a1 first period time I:0x32
;  current N I:0x33
;  local time I:0x35
;  b - captured N I:0x36
;  c - averege 100 N I:0x37 (H) 0x38 (L)

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
RET
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
