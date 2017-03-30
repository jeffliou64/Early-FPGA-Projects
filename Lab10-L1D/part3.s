CHAR_FLAG: .word 0
CHAR_BUFFER: .word 0
CLOCK: .word 0
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
				
				//Adding A9 timer counter
				LDR R0, =0xFF709000 		// GPIO1 base address
				LDR R1, =0xFFFEC600 		// MPCore private timer base address
				LDR R3, =150000000 			// timeout = 1/(200 MHz) x 200×10∧6 = 1 sec
				STR R3, [R1] 				// write to timer load register
				MOV R3, #0b111 				// set bits: mode = 1 (auto), enable = 1
				STR R3, [R1, #0x8]			// write to timer control register			
			
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
				LDR R9, [R8,#0]
				CMP R9, #1
				BEQ CHARBUFFER
				B 			IDLE				// main program simply idles
				
CHARBUFFER:		
				LDR R7, =CHAR_BUFFER
				LDR R0, [R7,#0]
				BL PUT_JTAG
				MOV R9, #0
				STR R9, [R8,#0]
				B IDLE
				
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
				
				LDR R1, =0xFF201000
				LDR R7, =CHAR_BUFFER
				LDRB R2, [R1]
				STR R2, [R7, #0]
				LDR R8, =CHAR_FLAG
				MOV R2, #1
				STR R2, [R8,#0]
				
				CMP R5, #KEYS_IRQ
				BEQ FPGA_IRQ1_HANDLER
				LDR R6, =0xFF200000					//led base
				LDR R9, =CLOCK
				LDR R2, [R9, #0]
				ADD R2, R2, #1
				STR R2, [R9,#0]
				STR R2, [R6]
				B EXIT_IRQ
				
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
