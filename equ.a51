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
	#define DurD 	50d

	#define ArrayN	6000h
	#define MaxN	100d

	CurNPos 	EQU 039h
	IsStarted	EQU 03Ah
	Timer1H		EQU 03Bh
	Timer1L		EQU 03Ch
	TmpDurA   	EQU 03Dh
	Result		EQU P4.6
	Impulse		EQU P4.7
	N_High		EQU	P4.5
	N_Low		EQU P4.4
	TMP_N		EQU 03Eh
	TMP_N_2		EQU 03Fh
	
	#define DispDelay 20d