	ORG 0h
	LJMP MAIN

	ORG 03h
	LJMP ENTER_N

	ORG 0Bh
	LJMP ON_TIMER ; timer interrupt handler
	
	ORG 0Fh
	LJMP ON_TIMER1 ; timer TF1


	ORG 30h
	
	CurTime 	EQU 030h
	State 		EQU 031h
	DurA 		EQU 032h
	CurN 		EQU 033h
	LocTime 	EQU 035h
	DurB 		EQU 036h
	DurCHigh 	EQU 037h
	DurCLow 	EQU 038h
	P4 			EQU 0C0h
	Tmp 		EQU 020h
	;DurD 		EQU #50d
	
	;ArrayN 		EQU #1000d
	;MaxN 		EQU #100d

	CurNPos 	EQU 039h
	IsStarted	EQU 03Ah
	Timer1H		EQU 03Bh
	Timer1L		EQU 03Ch

MAIN:
MAIN_INIT:
	CLR 	TF0
	CLR 	TR0
	CLR		TR1
	MOV 	IE, 	#10001011b  ;enable TF1 and TF0 and IT0 interrupt only
	MOV 	TMOD, 	#00010001b ; enable  T1 and T0 16bit timer
	MOV 	TL0, 	#018h ;initial value
	MOV 	TH0, 	#0FCh ;initial value
	
	MOV		TL1, 	#00h 
	MOV		TH1, 	#06h
	
	MOV 	TCON, #01h ; front

	MOV 	CurN, 		#0h
	MOV 	CurNPos, 	#0h
	MOV		IsStarted, 	#0h
	
	LCALL	KEY_BOARD_INIT

;=================================
	; Prepareing test sum
	MOV		DPTR, #1000d
	MOV		R1, #100d;
	
_main1:

	MOV 	A, #0Fh
	MOVX 	@DPTR, A
	INC 	DPTR
	DJNZ 	R1, _main1

	; Seting test case
	MOV		DurA, #9d
	MOV 	CurTime, #0d
	MOV 	CurN, #15d
;====================================

	SETB 	TR0 ;enable timer0
	SETB 	EA ;enable interrupts

	; Infinite loop
	LJMP 	$
		
DISPLAY_ENTER:		
	LCALL 	DISPLAY_CLEAR
	MOV 	R4, #042h 				;B
	LCALL 	DISPLAY
	MOV 	R4, #0B3h				;в
	LCALL 	DISPLAY
	MOV 	R4, #065h				;е
	LCALL 	DISPLAY						
	MOV 	R4, #0E3h				;д
	LCALL	DISPLAY
	MOV		R4, #05Fh				;_
	LCALL 	DISPLAY
	MOV		R4, #041h				;A
	LCALL	DISPLAY
	RET
	
DISPLAY_WORKING:
	LCALL 	DISPLAY_CLEAR
	SETB 	TR1
	RET
	
ENTER_A:
	MOV		DurA,#10h
	RET
	
	
ENTER_N:
	MOV 	A, P4;
	ANL 	A, #0Fh
	MOV 	CurN, A
	MOV 	DPTR, #1000d

	MOV 	A, CurNPos
	MOV 	R1, A
	JZ 		_enter_next
	
_enter_ptr_set:

	INC 	DPTR
	DJNZ 	R1,  _enter_ptr_set
	
_enter_next:

	MOV 	A, CurN
	MOVX 	@DPTR, A
	MOV 	A, CurNPos
	INC 	A
	CJNE 	A, #100d, _enter_end
	MOV 	A, #0h
	
_enter_end:

	MOV 	CurNPos, A
	RETI	


;=======================================
ON_TIMER1:
	CLR		TF1
	MOV		A, Timer1H
	CJNE	A, #07h, _timer1_inc
	MOV		A, Timer1L
	CJNE	A, #0D0h, _timer1_inc
	
	CLR		TR1
	LCALL	ENTER_A
	LCALL	DISPLAY_WORKING
	SETB	TR0
	LJMP	TIMER1_EXIT
	
_timer1_inc:
	CLR		C
	INC 	Timer1L
	JNC		TIMER1_EXIT
	INC		Timer1H
	
TIMER1_EXIT:	
	RETI
	


;=======================================
ON_TIMER:

	MOV 	TL0, #018h ;initial value
	MOV 	TH0, #0FCh ;initial value
	CLR 	TF0

	MOV 	A, CurTime
	JNZ 	_timer_non_start
	MOV 	CurTime, #0h
	MOV 	State, #1h
	MOV 	DurB, #0Fh

_timer_non_start:

_timer_state_1:
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
	MOV 	R2, #100d
	LCALL 	SUM_N
	MOV 	A, R3
	MOV 	R1, A
	MOV 	A, R4
	MOV 	R2, A
	MOV 	R3, #100d
	LCALL 	DIVIDE
	MOV 	DurCHigh, R4
	MOV 	DurCLow, R5
	LJMP 	_timer_res

_timer_state_3:
	MOV 	R4, LocTime
	MOV 	R7, State
	MOV 	A, R4
	CJNE 	A, DurCLow, _timer_res
	CJNE 	R7, #3h, _timer_res
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
	CLR 	P4.0
	LJMP 	_timer_inc

_timer_res_1:
	SETB 	P4.0
	LJMP 	_timer_inc

_timer_inc:
	MOV 	A, CurTime
	CJNE 	A, #50d, _timer_clear
	INC 	CurTime
	INC 	LocTime
	LJMP 	_timer_exit

_timer_clear:
	MOV 	CurTime, #0d
	MOV 	LocTime, #0d
	CLR 	P4.0

_timer_exit:
	RETI
	
	

SUM_N:
; R1 offset
; R2 length
; R3 sumH
; R4 sumL

	MOV 	R3, #0h
	MOV 	R4, #0h
	MOV 	R5, #0h
	MOV 	DPTR, #1000d


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

		PUBLIC 		KEY_BOARD_INIT
	PUBLIC		KEY_READ	



KEY_BOARD_INIT:
	IEN0 EQU 	0A8h
	MOV 		IEN0, #84h
	MOV 		DPTR,#7FFFh
	MOV 		A,#01h
	MOVX 		@DPTR,A ;ввод символа слева, декодированный режим

	MOV 		DPTR,#7FFFh
	MOV 		A,#90h
	MOVX 		@DPTR,A ;разрешение записи в видеопамять с автоинкрементированием адреса

	RET
	
	
KEY_READ:	
; R0 has readed value
	MOV 		DPTR,#7FFFh
	MOV 		A,#40h
	MOVX 		@DPTR,A ;разрешение чтения FIFO клавиатуры
	MOV 		DPTR,#7FFEh
	MOVX 		A,@DPTR ;чтение скан-кода
	
K0:
	CJNE 		A, #11011001B, K1;проверка скан-кода клавиши «0»
	MOV 		R0,#0h
	MOV 		DPTR,#7FFEh
	MOV 		A,#11110011b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «0»
	LJMP 		EXIT
	
	
K1:
	CJNE 		A, #11000000B, K2 ;проверка скан-кода клавиши «1»
	MOV 		DPTR,#7FFEh
	MOV 		A,#01100000b
	MOV			R0,#1h
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «1»
	LJMP 		EXIT

K2:
	CJNE 		A, #11000001B, K3 ;проверка скан-кода клавиши «2»
	MOV			R0,#2h
	MOV 		DPTR,#7FFEh
	MOV 		A,#10110101b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «2»
	LJMP 		EXIT

K3:
	CJNE 		A, #11000010B, K4 ;проверка скан-кода клавиши «3»
	MOV 		DPTR,#7FFEh
	MOV			R0,#3h
	MOV 		A,#11110100b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «3»
	LJMP 		EXIT

K4:
	CJNE 		a,#11001000b,K5; клавиши «4»
	MOV			R0,#4h
	MOV 		DPTR,#7FFEh
	MOV 		A,#01100110b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «4»
	LJMP 		EXIT

K5:
	CJNE 		A, #11001001B, K6 ;проверка скан-кода клавиши «5»
	MOV			R0,#5h
	MOV 		DPTR,#7FFEh
	MOV 		A,#11010110b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «5»
	LJMP 		EXIT

K6:
	CJNE 		A, #11001010B, K7 ;проверка скан-кода клавиши «6»
	MOV			R0,#6h
	MOV 		DPTR,#7FFEh
	MOV 		A,#11010111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «6»
	LJMP 		EXIT

K7:
	CJNE 		A, #11010000B, K8 ;проверка скан-кода клавиши «7»
	MOV			R0,#7h
	MOV 		DPTR,#7FFEh
	MOV 		A,#01110000b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «7»
	LJMP 		EXIT

K8:
	CJNE 		A, #11010001B, K9 ;проверка скан-кода клавиши «8»
	MOV			R0,#8h
	MOV 		DPTR,#7FFEh
	MOV 		A,#11110111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «8»
	LJMP 		EXIT

K9:
	CJNE 		A, #11010010B, K10 ;проверка скан-кода клавиши «9»
	MOV			R0,#9h
	MOV 		DPTR,#7FFEh
	MOV 		A,#11110110b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «9»
	LJMP 		EXIT

K10:
	CJNE 		A,#11000011B,K11; клавиши «A»
	MOV			R0,#0Ah
	MOV 		DPTR,#7FFEh
	MOV 		A,#01110111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «A»
	LJMP 		EXIT

K11:
	CJNE 		A, #11001011B, K12 ;проверка скан-кода клавиши «B»
	MOV			R0,#0Bh
	MOV 		DPTR,#7FFEh
	MOV 		A,#11000111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «B»
	LJMP 		EXIT

K12:
	CJNE 		A, #11010011B, K13 ;проверка скан-кода клавиши «C»
	MOV			R0,#0Ch
	MOV 		DPTR,#7FFEh
	MOV 		A,#10010011b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «C»
	LJMP 		EXIT

K13:
	CJNE 		A, #11011011B, K14 ;проверка скан-кода клавиши «D»
	MOV			R0,#0Dh
	MOV 		DPTR,#7FFEh
	MOV 		A,#11100101b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «D»
	LJMP 		EXIT

K14:
	CJNE 		A, #11011000B, K15 ;проверка скан-кода клавиши «*»
	MOV			R0,#0Eh
	MOV 		DPTR,#7FFEh
	MOV 		A,#10010111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «E»
	LJMP 		EXIT

K15:
	CJNE 		A, #11011010B, EXIT ;проверка скан-кода клавиши «#»
	MOV			R0,#0Fh
	MOV 		DPTR,#7FFEh
	MOV 		A,#00010111b
	MOVX 		@DPTR,A ;вывод в видеопамять кода символа «F»

EXIT:
	RET
	

	PUBLIC	DISPLAY

;******************************************************************************************
;подпрограмма вывода на ЖКИ символа в первое знакоместо первой строки
;код символа в R4

;******************************************************************************************
;подпрограмма вывода на ЖКИ символа в первое знакоместо первой строки
;код символа в R4
DISPLAY:
	MOV 	A,#38H ;две строки размер символа 5*8 точек
	LCALL 	DINIT ;вызов подпрограммы записи команды в управляющий регистр дисплея
	MOV 	A,#0CH ;включение дисплея
	LCALL 	DINIT
	MOV 	A,#06H ;сдвиг курсора вправо после вывода символа
	LCALL 	DINIT
	MOV 	A,#02H
	LCALL 	DINIT
	;LCALL 	DISPLAY_CLEAR
	MOV 	A,R4 ;код символа из R4 в аккумулятор
	LCALL 	DISP ;вызов подпрограммы записи кода символа в регистр данных дисплея
	RET
;------------------------------------------------------------------------------------------

DISPLAY_CLEAR:
	MOV 	A,#01H ;очистка дисплея
	LCALL 	DINIT
	RET

;подпрограмма записи команды в управляющий регистр дисплея

DINIT:
	MOV 	R0,A
	MOV 	DPTR,#7FF6H ;ожидание установки флага завершения записи в память дисплея
BF:
	MOVX 	A,@DPTR
	ANL 	A,#80H
	JNZ 	BF
	MOV 	DPTR,#7FF4H ;запись кода команды в управляющий регистр дисплея
	MOV 	A,R0
	MOVX 	@DPTR,A
	RET
;------------------------------------------------------------------------------------------
;подпрограмма записи кода символа в регистр данных дисплея
DISP:
	MOV 	R0,A
	MOV 	DPTR,#7FF6H ;ожидание установки флага завершения записи в память дисплея
BF1:
	MOVX 	A,@DPTR
	ANL 	A,#80H
	JNZ 	BF1
	MOV 	DPTR,#7FF5H ;запись значения кода символа в регистр данных дисплея
	MOV 	A,R0
	MOVX 	@DPTR,A
	RET
;------------------------------------------------------------------------------------------







END