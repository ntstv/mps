;==============================
SUM_N:
; R1 offset
; R2 length
; R3 sumH
; R4 sumL

	MOV 	R3, #0h
	MOV 	R4, #0h
	MOV 	R5, #0h
	MOV 	DPTR, #ArrayN


;setting offset
	MOV 	A, R1
	JZ 		S2
S1:
	INC 	DPTR
	DJNZ 	R1,  S1
S2:


_sum_n_loop:
	MOVX 	A, @DPTR
	ADDC 	A, R4
	MOV 	R4, A
	JNC 	_sum_n_1
	INC 	R3
	CLR 	C

_sum_n_1:
	INC 	R5

	INC 	DPTR
	DJNZ 	R2, _sum_n_loop

	RET
;===================================
DIVIDE:
; R1 dividentH
; R2 dividentL
; R3 divider
; R4 quotientH
; R5 quotientL
; R6 == 8d

	MOV 	R4, #0h
	MOV 	R5, #0h
	MOV 	R6, #09h


_div_cycle:

	MOV 	A, R1
	SUBB 	A, R3
	CPL 	C; C = ^C
	CLR 	PSW.6 ;HACK
	MOV 	PSW.7, C

	JNC 	_d2
	MOV 	R1, A

_d2:
	MOV 	A, R5
	RLC 	A
	MOV 	R5, A
	MOV 	A, R4
	RLC 	A
	MOV 	R4, A

	CLR 	C
	MOV 	A, R2
	RLC 	A
	MOV 	R2, A
	MOV 	A, R1
	RLC 	A
	MOV 	R1, A

	DJNZ 	R6, _div_cycle
	RET
;===========================
