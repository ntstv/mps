KEY_BOARD_INIT:
	MOV 		DPTR,#7FFFh
	MOV 		A,#01h
	MOVX 		@DPTR,A ;ввод символа слева, декодированный режим

	MOV 		DPTR,#7FFFh
	MOV 		A,#90h
	MOVX 		@DPTR,A ;разрешение записи в видеопамять с автоинкрементированием адреса

	RET


KEY_READ_AND_DISPLAY:
; R0 has readed value
	MOV 		DPTR,#7FFFh
	MOV 		A,#40h
	MOVX 		@DPTR,A ;разрешение чтения FIFO клавиатуры
	MOV 		DPTR,#7FFEh
	MOVX 		A,@DPTR ;чтение скан-кода

K0:
	CJNE 		A, #11011001B, K1;проверка скан-кода клавиши «0»
	MOV 		R0,#0h
	MOV			R4,#030h
	LCALL   DISPLAY2
	LJMP 		EXIT


K1:
	CJNE 		A, #11000000B, K2 ;проверка скан-кода клавиши «1»
	MOV 		DPTR,#7FFEh
	MOV 		R0,#0h
	MOV			R4,#031h
	LCALL   DISPLAY2
	LJMP 		EXIT

K2:
	CJNE 		A, #11000001B, K3 ;проверка скан-кода клавиши «2»
	MOV			R0,#2h
	MOV			R4,#032h
	LCALL   DISPLAY2
	LJMP 		EXIT

K3:
	CJNE 		A, #11000010B, K4 ;проверка скан-кода клавиши «3»
	MOV 		DPTR,#7FFEh
	MOV			R0,#3h
	MOV			R4,#033h
	LCALL   DISPLAY2
	LJMP 		EXIT

K4:
	CJNE 		a,#11001000b,K5; клавиши «4»
	MOV			R0,#4h
	MOV			R4,#034h
	LCALL   DISPLAY2
	LJMP 		EXIT

K5:
	CJNE 		A, #11001001B, K6 ;проверка скан-кода клавиши «5»
	MOV			R0,#5h
	MOV			R4,#035h
	LCALL   DISPLAY2
	LJMP 		EXIT

K6:
	CJNE 		A, #11001010B, K7 ;проверка скан-кода клавиши «6»
	MOV			R0,#6h
	MOV			R4,#036h
	LCALL   DISPLAY2
	LJMP 		EXIT

K7:
	CJNE 		A, #11010000B, K8 ;проверка скан-кода клавиши «7»
	MOV			R0,#7h
	MOV			R4,#037h
	LCALL   DISPLAY2
	LJMP 		EXIT

K8:
	CJNE 		A, #11010001B, K9 ;проверка скан-кода клавиши «8»
	MOV			R0,#8h
	MOV			R4,#038h
	LCALL   DISPLAY2
	LJMP 		EXIT

K9:
	CJNE 		A, #11010010B, K10 ;проверка скан-кода клавиши «9»
	MOV			R0,#9h
	MOV			R4,#039h
	LCALL   DISPLAY2
	LJMP 		EXIT

K10:
	CJNE 		A,#11000011B, K11; клавиши «A»
	MOV			R0,#0Ah
	MOV			R4,#041h
	LCALL   DISPLAY2
	LJMP 		EXIT

K11:
	CJNE 		A, #11001011B, K12 ;проверка скан-кода клавиши «B»
	RETI

K12:
	CJNE 		A, #11010011B, K13 ;проверка скан-кода клавиши «C»
	RETI

K13:
	CJNE 		A, #11011011B, K14 ;проверка скан-кода клавиши «D»
	RETI

K14:
	CJNE 		A, #11011000B, K15 ;проверка скан-кода клавиши «*»
	LCALL		ENTER_N
	RETI

K15:
	CJNE 		A, #11011010B, EXIT ;проверка скан-кода клавиши «#»
	MOV			R0,#0Fh
	MOV			R4,#023h
    LCALL       DISPLAY2
    LCALL       ACCEPT_A
	RETI

EXIT:
  MOV 		A, R0
  MOV 		TmpDurA, A
  RETI
