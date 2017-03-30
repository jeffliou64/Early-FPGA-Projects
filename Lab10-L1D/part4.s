CHAR_FLAG: .word 0
CHAR_BUFFER: .word 0
CLOCK: .word 0
CURRENT_PID: .WORD 0
PD_ARRAY:	.fill 17,4,0xDEADBEEF
			.fill 13,4,0xDEADBEE1
			.word 0x3F000000		//SP
			.word 0					//LR
			.word PROC1+4			//PC
			.word 0x53				//CPSR (0x53 means IRQ enabled, mode=SVC)
			
				.include	"address_map_arm.s"
				.include	"interrupt_ID.s"

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly language code. 
 * The program responds to interrupts from the pushbutton KEY port in the FPGA.
 *
 * The interrupt service routine for the pushbutton KEYs indicates which KEY has 
 * been pressed on the HEX0 display.
 ********************************************************************************/

				.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

				.text
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #0b11010010					// interrupts masked, MODE = IRQ
				MSR		CPSR_c, R1							// change to IRQ mode
				LDR		SP, =A9_ONCHIP_END - 3			// set IRQ stack to top of A9 onchip memory
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #0b11010011					// interrupts masked, MODE = SVC
				MSR		CPSR, R1								// change to supervisor mode
				LDR		SP, =DDR_END - 3					// set SVC stack to top of DDR3 memory

				BL			CONFIG_GIC							// configure the ARM generic interrupt controller

				// write to the pushbutton KEY interrupt mask register
				LDR		R0, =KEY_BASE						// pushbutton KEY base address
				MOV		R1, #0xF								// set interrupt mask bits
				STR		R1, [R0, #0x8]						// interrupt mask register is (base + 8)

				// enable IRQ interrupts in the processor
				MOV		R0, #0b01010011					// IRQ unmasked, MODE = SVC
				MSR		CPSR_c, R0
				
				/* read and echo characters */
CONT:			BL GET_JTAG 				// read from the JTAG UART
				CMP R0, #0 					// check if a character was read
				BEQ CONT
				BL PUT_JTAG
				B CONT
				
PUT_JTAG:		LDR R1, =0xFF201000			// JTAG UART base address
				LDR	R2, [R1, #4] 			// read the JTAG UART control register
				LDR R3, =0xFFFF
				ANDS R2, R2, R3
				BEQ END_PUT
				STR R0, [R1] 				// send the character
END_PUT:		BX LR
				
GET_JTAG:		LDR R1, =0xFF201000 		// JTAG UART base address
				LDR R0, [R1] 				// read the JTAG UART data register
				ANDS R2, R0, #0x8000 		// check if there is new data
				BEQ RET_NULL 				// if no data, return 0
				AND R0, R0, #0x00FF 		// return the character
				B END_GET
RET_NULL:		MOV R0, #0
END_GET:		BX LR
	
IDLE:
				LDR R8, =CHAR_FLAG
				LDR R8, [R8,#0]
				CMP R8, #1
				BEQ CHARBUFFER
				LDR R1, =CURRENT_PID
				LDR R2, [R1]
				CMP R2, #0
				BNE	PROC1
				B 	IDLE				// main program simply idles
CHARBUFFER:		
				MOV R0, R7
				MOV R8, #0
				BL PUT_JTAG
				B IDLE
				
PROC1:
				LDR R1, =LEDR_BASE
				MOV R2, #0
				LDR R4, =150000000
L1:				ADD R2, R2,#1
				STR R2, [R1]
				MOV R3, #0
L2:				CMP R3, R4
				BGE L3
				ADD R3, #1
				B   L2
L3:				B L1

				
/* Define the exception service routines */

/*--- Undefined instructions --------------------------------------------------*/
SERVICE_UND:
    			B SERVICE_UND 
 
/*--- Software interrupts -----------------------------------------------------*/
SERVICE_SVC:			
    			B SERVICE_SVC 

/*--- Aborted data reads ------------------------------------------------------*/
SERVICE_ABT_DATA:
    			B SERVICE_ABT_DATA 

/*--- Aborted instruction fetch -----------------------------------------------*/
SERVICE_ABT_INST:
    			B SERVICE_ABT_INST 
 
/*--- IRQ ---------------------------------------------------------------------*/
SERVICE_IRQ:
				
				PUSH		{R0-R7, LR}
    			/* Read the ICCIAR from the CPU interface */
    			LDR		R4, =MPCORE_GIC_CPUIF
    			LDR		R5, [R4, #ICCIAR]				// read from ICCIAR
				
				
				MRS R0, SPSR
				MOV R0, #0B10011
				LDR R1, =CURRENT_PID
				LDR R2, [R1]
				CMP R2, #0
				BEQ PID_ZERO
				LDR R3, =PD_ARRAY
				ADD R3, R3, #68
				STM R3!, {R0-R15}
				MOV R2, #0
				STR R2, [R1]
				B PID_UPDATED_TO0
PID_ZERO:		LDR R3, =PD_ARRAY
				STM R3!, {R0-R15}	
				MOV R2, #1
				STR R2, [R1]
				B PID_UPDATED_TO1
PID_UPDATED_TO0:
				LDR R1, =PD_ARRAY
				LDM R1!, {R0-R14}
				SUBS PC, LR, #4
				LDR R0, =PD_ARRAY //loads saved CPSR value into register
				B PID_CONTINUE
PID_UPDATED_TO1:
				LDR R1, =PD_ARRAY
				ADD R1, R1, #68  //the second half starts 17 addresses later (17*4=68)
				LDM R1!, {R0-R14}
				SUBS PC, LR, #4
				LDR R0, =PD_ARRAY
				ADD R0, R0, #68 //loads saved CPSR value into register
PID_CONTINUE:
				MSR SPSR, R0 //moves it into SPSR
				
				LDR R1, =0xFF201000
				LDR R7, =CHAR_BUFFER
				LDRB R2, [R1]
				STR R2, [R7, #0]
				LDR R8, =CHAR_FLAG
				MOV R2, #1
				STR R2, [R8,#0]
				
FPGA_IRQ1_HANDLER:
    			CMP		R5, #KEYS_IRQ
UNEXPECTED:		BNE		UNEXPECTED    					// if not recognized, stop here
    
    			BL			KEY_ISR
EXIT_IRQ:
    			/* Write to the End of Interrupt Register (ICCEOIR) */
    			STR		R5, [R4, #ICCEOIR]			// write to ICCEOIR
    
    			POP		{R0-R7, LR}
    			SUBS		PC, LR, #4

/*--- FIQ ---------------------------------------------------------------------*/
SERVICE_FIQ:
    			B			SERVICE_FIQ 

				.end   
