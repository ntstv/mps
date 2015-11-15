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
	
END

