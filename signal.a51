;=======================================
ON_TIMER0:

	LCALL   INIT_TIMER0

	MOV 	A, CurTime
	;MOV 	CurTime, #0h
	;MOV 	State, #1h
	MOV 	DurB, CurN
	

	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
	CJNE 	A, DurA, _timer_state_2
	CJNE 	R7, #0d, _timer_state_2
	MOV 	State, #2h
	MOV 	LocTime, #0h
	MOV 	DurB, CurN
	LJMP 	_timer_res

_timer_state_2:

	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
	CJNE 	A, DurB, _timer_state_3
	CJNE 	R7, #1d, _timer_state_3
	MOV 	State, #4h
	MOV 	LocTime, #0h
	;calculating average
	MOV 	R1, #0h
	MOV 	R2, #MaxN
	LCALL 	SUM_N
	MOV 	A, R3
	MOV 	R1, A
	MOV 	A, R4
	MOV 	R2, A
	MOV 	R3, #MaxN
	LCALL 	DIVIDE
	MOV 	DurCHigh, R4
	MOV 	DurCLow, R5
	LJMP 	_timer_res

_timer_state_3:
	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
	CJNE 	A, DurCLow, _timer_res
	CJNE 	R7, #4h, _timer_res
	MOV 	State, #8h
	MOV 	LocTime, #0h
	LJMP 	_timer_res

_timer_res:
	MOV 	A, State
	ANL 	A, #2d
	MOV 	Tmp, A
	JB 		Tmp.1,  _timer_res_1

	MOV 	A, State
	ANL 	A, #8d
	MOV 	Tmp, A
	JB 		Tmp.4,  _timer_res_1

	MOV 	A, State
	ANL 	A, #2d
	JB 		Tmp.2,  _timer_res_0

	MOV 	A, State
	ANL 	A, #1d
	MOV 	Tmp, A
	JNB 	Tmp.1,  _timer_res_0

_timer_res_0:
	CLR 	Result
	LJMP 	_timer_inc

_timer_res_1:
	SETB 	Result
	LJMP 	_timer_inc

_timer_inc:
	MOV 	A, CurTime
	CJNE 	A, #DurD, _timer_clear
	INC 	CurTime
	INC 	LocTime
	LJMP 	_timer_exit

_timer_clear:
	MOV 	CurTime, #0d
	MOV 	LocTime, #0d
	SETB	Impulse
	CLR 	Impulse
	CLR 	Result

_timer_exit:
	;MOV		A, State
	;ADD		A,#30h
	;MOV		R4,A
	;LCALL	DISPLAY2

	RETI
