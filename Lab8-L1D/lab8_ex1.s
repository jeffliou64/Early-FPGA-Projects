	.include "address_map_arm.s"
	.text
	.globl _start
_start:
	 LDR R0, =SW_BASE
	 LDR R1, =LEDR_BASE
L1:	 LDR R2, [R0]
	 MOV R3, R2, LSL #1
	 STR R3, [R1]
	 B L1