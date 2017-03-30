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
		MOV	r1,	#0x00100000				//	base	of	array
		MOV	r2,	#0x100					//	iterations	of	inner	loop
		MOV	r3,	#2						//	iterations	of	outer	loop
		MOV	r4,	#0						//	i=0	(outer	loop	counter)
L_outer_loop:
		MOV	r5,	#0						//	j=0	(inner	loop	counter)
L_inner_loop:
		LDR	r6,	[r1, r5, LSL #4]		//	read	data	from	memory
		ADD	r5,	r5,	#1					//	j=j+1
		CMP	r5,	r2						//	compare	j	with	256
		BLT	L_inner_loop				//	branch	if	less	than
		ADD	r4,	r4,	#1					//	i=i+1
		CMP	r4,	r3						//	compare	i	with	2
		BLT	L_outer_loop				//	branch	if	less	than
		
		//	Step	7:	stop	counters
		MOV	r0,	#0
		MCR	p15,	0,	r0,	c9,	c12, 0	//	Write	0	to	PMCR	to	stop	counters
		
		//	Step	8-10:	Select	PMN0	and	read	out	result	into	R3
		MOV	r0,	#0						//	PMN0	
		MCR	p15,	0,	R0,	c9,	c12, 5	//	Write	0	to	PMSELR		
		MRC	p15,	0,	R1,	c9,	c13, 2	//	Read	PMXEVCNTR	into	R1
		MOV	r0,	#1						//	PMN1	
		MCR	p15,	0,	R0,	c9,	c12, 5	//	Write	1	to	PMSELR
		MRC	p15,	0,	R2,	c9,	c13, 2	//	Read	PMXEVCNTR	into	R2
		MOV	r0,	#2						//	PMN2	
		MCR	p15,	0,	R0,	c9,	c12, 5	//	Write	2	to	PMSELR
		MRC	p15,	0,	R3,	c9,	c13, 2	//	Read	PMXEVCNTR	into	R3
end:	B	end							//	wait	here