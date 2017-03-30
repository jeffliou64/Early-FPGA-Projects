      .equ  TRANS_TABLE_0_BASE, 0x10000000
      .equ  UNCACHABLE_START, 0x400
      .equ  TRANS_TABLE_N, 0
      .equ  SECTION_SIZE, 0x100000

      .global CONFIG_VIRTUAL_MEMORY
CONFIG_VIRTUAL_MEMORY:
      PUSH {R4-R9}

      /* Verify System Control Register contents */
      MRC p15, 0, R0, c1, c0, 0 /* Read SCTLR into Rt */
      LDR R1, =0x00C5187A
      CMP R0, R1
      BNE CPT_ERROR
	  
      LDR R6, =0x100000 /* address to try to read after MMU configured */
      LDR R7, [R6]      /* R7 is contents of word at physical address 0x100000 */
      LDR R8, =0x200000 /* address to try to read after MMU configured */
      LDR R9, [R8]      /* R9 has contents of word at physical address 0x200000 */

      /* initialize level 1 translation table */
               /*1111111111          */
               /*98765432109876543210*/
      LDR R1, =0b10000001110000001110    /* lower 20 bits of section descriptor for cacheable sections */
      LDR R2, =0b10000000110000000010    /* lower 20 bits of section descriptor for device sections */
      LDR R3, =SECTION_SIZE
      LDR R4, =TRANS_TABLE_0_BASE
      MOV R0, #0  /* loop counter */
CPT_L1: 
      MUL   R5, R0, R3                     /* physical address of section */
      CMP   R0, #UNCACHABLE_START 
      ORRLT R5, R5, R1
      ORRGE R5, R5, R2
      STR   R5, [R4, R0, LSL #2]
      ADD   R0, R0, #1
      CMP   R0, #0x1000
      BLT   CPT_L1

      /* for testing address translation: remap second two pages */
      ADD R5, R1, R3
      STR R5, [R4, #8]  /* virtual page 2 => physical page 1 */
      ADD R5, R1, R3, LSL #1
      STR R5, [R4, #4]  /* virtual page 1 => physical page 2 */

      /* set Translation Table Base Control Register */
      MOV R0, #TRANS_TABLE_N
      MCR p15, 0, R0, c2, c0, 2 /* TTBCR.N = 0 */

      /* set Translation Table Base Register 0 */
      LDR R0,=TRANS_TABLE_0_BASE 
      MCR p15, 0, R0, c2, c0, 0 /* TTBR0 = TRANS_TABLE_0_BASE */

      /* set Domain Access Control Register */
      MOV R0, #1
      MCR p15, 0, R0, c3, c0, 0 /* Domain 0 is client */

      /* set Context ID Register */
      MOV R0, #0
      MCR p15, 0, R0, c13, c0, 1 /* PROCID = 0, ACID = 0 */

      /* enable data cache and MMU */
      MRC p15, 0, R0, c1, c0, 0 /* Read SCTLR into Rt */
      ORR R0, R0, #0b101
      MCR p15, 0, R0, c1, c0, 0 /* Write Rt to SCTLR */ 

      ISB

      LDR   R1, [R6] /* R1 has contents of memory at virtual address 0x100000 
                        which should be physical address 0x200000 */

      CMP   R1, R9   /* R1 should match R9 if address translation worked */
      BNE   CPT_ERROR 

      MOV   R0, #0
      B     CPT_RETURN
CPT_ERROR:
      MOV   R0, #1
CPT_RETURN:
      POP   {R4-R9}
      BX    LR
