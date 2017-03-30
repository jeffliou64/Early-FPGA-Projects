numbers_1: .word 18
numbers_2: .word 5
		   .word 10
		   .word 15
		   .word 20
		   .word 25
		   .word 30
		   .word 31
		   .word 32
numbers_3: .word 1
		   .word 2
		   .word 3
		   .word 4
		   .word 5
		   .word 6
		   .word 7
		   .word 8
		   .word 9
		   .word 10
		   .word 11
		   .word 12
		   .word 13
		   .word 14
		   .word 15
		   .word 16
		   .word 17
		   .word 18
		   .word 19
		   .word 20
	       .word 21
		   .word 22
		   .word 23
		   .word 24
		   .word 25
		   .word 26
		   .word 27
		   .word 28
		   .word 29
		   .word 30   
	.include "address_map_arm.s"
	.text
	.globl _start
	
_start: 
		LDR R10, =SW_BASE
		LDR R11, =LEDR_BASE
		SUB SP,SP, #4

		MOV R4, #0	
		LDR R0, =numbers_1
		MOV R1, #18
		MOV R2, #0
		MOV R3, #0
		BL BINARY_SEARCH
		STR R0, [R11]
		
		//MOV R4, #0
		LDR R0, =numbers_2
		MOV R1, #25
		MOV R2, #0
		MOV R3, #7
		BL BINARY_SEARCH
		STR R0, [R11]
CALL_3:	
		LDR R9, [R10]
		CMP R9, #0
		BEQ CALL_3
		
		//MOV R4, #0	
		LDR R0, =numbers_3
		MOV R1, #18
		MOV R2, #0
		MOV R3, #29
		BL BINARY_SEARCH
		STR R0, [R11]
		B DONE
		
DONE: 	B DONE

//r0 is numbers, r1 is key, r2 is startIndex, r3 is endIndex
BINARY_SEARCH: 
		SUB SP, SP, #24
		STR R8, [SP, #20]
		STR R6, [SP, #16]
		STR R0, [SP, #12]
		STR R4, [SP, #8] //numcalls
		STR R5, [SP, #4] //middleindex
		STR LR, [SP, #0] //lr
		ADD R4, R4, #1
		SUB R5, R3, R2	 //r5 is middleindex
		MOV R5, R5, LSR#1
		ADD R5, R5, R2
		
		CMP R2, R3
		BLE START_LESSTHAN_END
		MOV R0, #1
		SUB R0, R0, R0, LSL#1 //subtracting 1 by 2, gives -1
		LDR LR, [SP,#0]
		ADD SP, SP, #8
		MOV PC, LR		//checking for startIndex > endIndex
		
START_LESSTHAN_END: 
		LDR R8, [R0, R5, LSL #2]
		CMP R1, R8
		BNE	NOT_EQUAL
		MOV R0, R5
		B RETURN
	
NOT_EQUAL:
		CMP R8, R1
		BGT BIGGER_THAN //if not bigger than, it is less than, so it just continues below
		ADD R5, R5, #1  
		MOV R2, R5
		BL BINARY_SEARCH
		B RETURN
		
BIGGER_THAN:
		SUB R5, R5, #1
		MOV R3, R5
		BL BINARY_SEARCH
		B RETURN
				
RETURN:	
		LDR R6, [SP, #12]
		LDR R4, [SP,#8]
		SUB R4, R4, R4, LSL#1 //subtracting numcalls by 2x numcalls, gives -numcalls
		STR R4, [R6, R5, LSL#2]
		LDR R8, [SP, #20]
		LDR R6, [SP, #16]
		LDR R5, [SP, #4]
		LDR LR, [SP,#0]
		ADD SP, SP, #24
		MOV PC, LR