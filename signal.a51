;=======================================
ON_TIMER0:

	LCALL   INIT_TIMER0

	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
    CJNE 	R7, #1h, _timer_state_2
	CJNE 	A, DurA, _timer_res
	MOV 	State, #2h
	MOV 	LocTime, #0h
	MOV 	DurB, CurN
	LJMP 	_timer_res

_timer_state_2:

	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
    CJNE 	R7, #2h, _timer_state_3
	CJNE 	A, DurB, _timer_res
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
	
	MOV	R4,DurCLow
	MOV	A,R4
	ADD	A,#30h
	MOV	R4,A
	LCALL	DISPLAY2
	
	LJMP 	_timer_res

_timer_state_3:
	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
    CJNE 	R7, #4h, _timer_res
	CJNE 	A, DurCLow, _timer_res
	MOV 	State, #8h
	MOV 	LocTime, #0h
	LJMP 	_timer_res

_timer_res:
    MOV     R7, State
    CJNE    R7, #2h, _tim1
    LJMP    _timer_res_0
    _tim1:
    CJNE    R7, #8h, _tim2
    LJMP    _timer_res_0
    _tim2:
    CJNE    R7, #1h, _tim3
    LJMP    _timer_res_begin
    _tim3:
    CJNE    R7, #4h, _timer_res_0
    LJMP    _timer_res_1
	
_timer_res_begin:
	SETB  Result
	SETB	Impulse
	CLR 	Impulse
	LJMP _timer_inc

_timer_res_0:
	CLR 	Result
	LJMP 	_timer_inc

_timer_res_1:
	SETB 	Result
	LJMP 	_timer_inc

_timer_inc:
	MOV 	A, CurTime
	CJNE 	A, #DurD, _t_next
	LJMP	_timer_clear
	_t_next:
	INC 	CurTime
	INC 	LocTime
	LJMP 	_timer_exit

_timer_clear:
	MOV 	CurTime, #0d
	MOV 	LocTime, #0d
	MOV		State, #1h
	CLR 	Result

_timer_exit:
	;MOV	R4,DurA
	;MOV	A,R4
	;ADD	A,#40h
	;MOV	R4,A
	;LCALL	DISPLAY2
	;CLR	TF0
	RETI
