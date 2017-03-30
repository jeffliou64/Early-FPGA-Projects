	.include "address_map_arm.s"
	.text
	.globl _start
_start:
	 LDR R0, =SW_BASE
	 LDR R1, =LEDR_BASE
	 MOV R2, #0
	 
L1:	 ADD R2, R2,#1
	 STR R2, [R1]
	 B L1