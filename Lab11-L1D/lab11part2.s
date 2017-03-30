sums: .double 0.0
array_a: .double 1.0
		 .double 1.0
		 .double 2.0
		 .double 2.0
array_b: .double 3.0
		 .double 3.0
		 .double 4.0
		 .double 4.0
array_c:


	.text
	.global		_start
_start:
		BL	CONFIG_VIRTUAL_MEMORY
		
		//	Step	1-3:	configure	PMN0,PMN1,PMN2	to	count	cycles
		MOV	R0,	#0							//	Write	0	into	R0	then	PMSELR
		MCR	p15,	0,	R0,	c9,	c12,	5	//	Write	0	into	PMSELR	selects	PMN0
		MOV	R1,	#0x3						//	Event	0x3 	is Level 1 data cache misses
		MCR	p15,	0,	R1,	c9,	c13,	1	//	Write	0x11	into	PMXEVTYPER	(PMN0	measure	CPU	cycles)
		
		MOV	R1,	#1							
		MCR	p15,	0,	R1,	c9,	c12,	5	//	Write	1	into	PMSELR	selects	PMN1
		MOV	R1,	#0x6						//	Event	0x6		is number of load instructions executed
		MCR	p15,	0,	R1,	c9,	c13,	1	
		
		MOV	R2,	#2							
		MCR	p15,	0,	R2,	c9,	c12,	5	//	Write	2	into	PMSELR	selects	PMN2
		MOV	R1,	#0x11						//	Event	0x11	is	CPU	cycles
		MCR	p15,	0,	R1,	c9,	c13,	1	
		
		//	Step	4:	enable	PMN0,PMN1,PMN2
		MOV	R0,	#0b111						//	PMN0,1,2 is bits 0,1,2 of PMCNTENSET
		MCR	p15,	0,	R0,	c9,	c12,	1	//	Setting bit 0 of PMCNTENSET enables PMN0,PMN1,PMN2
		
		//	Step	5:	clear	all	counters	and	start	counters
		MOV	r0,	#3							//	bits 0 (start counters) and 1 (reset counters)
		MCR	p15,	0,	r0,	c9,	c12,	0	//	Setting	PMCR	to	3
		
		//	Step	6:	code	we	wish	to	profile	using	hardware	counters 
		LDR	r0,	=array_a					//  base of array a
		LDR r1, =array_b					//  base of array b
		LDR r2, =array_c					//  base of array c
		MOV r6, #0
		LDR r7, =sums						//  sum=0.0
		.word 0xED076B00					//	STR r6, [r7,#0]
		MOV	r3,	#2							//	n
		MOV	r4,	#0							//	i=0 (outer loop counter)
L_i_loop:
		MOV	r5,	#0							//	j=0
L_j_loop:
		mov r6, #0
		LDR r7, =sums						//  sum=0.0
		.word 0xED076B00					//	STR r6, [r7,#0]
		MOV r11, #0							//  k=0
L_k_loop:
		MUL r10, r4, r3
		ADD r10, r10, r11
		MOV r10, r10, LSL #3
		ADD r7, r0, r10
		.word 0xED178B00					//	FLDD r8, [r7, #0]
		
		MUL r10, r11, r3
		ADD r10, r10, r5
		MOV r10, r10, LSL #3
		ADD r7, r1, r10
		.word 0xED179B00					//	FLDD r9, [r7, #0]
		
		LDR r7, =sums
		.word 0xED176B00					//	LDR r6, [r7, #0]
		.word 0xEE287B09					//	MUL r7, r8, r9
		.word 0xEE366B07					//	ADD r6, r6, r7
		LDR r7, =sums
		.word 0xED076B00					//	STR r6, [r7, #0]
		ADD r11, r11, #1
		CMP	r11, r3
		BLT	L_k_loop
		
		LDR r7, =sums
		.word 0xED176B00					//	LDR r6, [r7, #0]
		MUL r10, r4, r3
		ADD r10, r10, r5
		MOV r10, r10, LSL #3
		ADD r7, r2, r10
		.word 0xED076B00  					//	FSTD r6, [r7, #0]
		
		ADD r5, r5, #1
		CMP	r5,	r3
		BLT	L_j_loop
		ADD	r4,	r4,	#1
		CMP	r4,	r3
		BLT	L_i_loop
		
		//	Step	7:	stop	counters
		MOV	r0,	#0
		MCR	p15,	0,	r0,	c9,	c12, 0		//	Write	0	to	PMCR	to	stop	counters
		
		//	Step	8-10:	Select	PMN0	and	read	out	result	into	R3
		MOV	r0,	#0							//	PMN0	
		MCR	p15,	0,	R0,	c9,	c12, 5		//	Write	0	to	PMSELR		
		MRC	p15,	0,	R1,	c9,	c13, 2		//	Read	PMXEVCNTR	into	R1
		MOV	r0,	#1							//	PMN1	
		MCR	p15,	0,	R0,	c9,	c12, 5		//	Write	1	to	PMSELR
		MRC	p15,	0,	R2,	c9,	c13, 2		//	Read	PMXEVCNTR	into	R2
		MOV	r0,	#2							//	PMN2	
		MCR	p15,	0,	R0,	c9,	c12, 5		//	Write	2	to	PMSELR
		MRC	p15,	0,	R3,	c9,	c13, 2		//	Read	PMXEVCNTR	into	R3
end:	B	end								//	wait	here