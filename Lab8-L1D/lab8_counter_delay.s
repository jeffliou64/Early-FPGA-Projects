	.include "address_map_arm.s"
	.text
	.globl _start
_start:
	 LDR R1, =LEDR_BASE
	 MOV R2, #0
	 MOV R4, #134217728
	 
L1:	 ADD R2, R2,#1
	 STR R2, [R1]
	 MOV R3, #0
	 
L2:	 CMP R3, R4
	 BGE L3
	 ADD R3, #1
	 B   L2
	 
L3:	 B L1